// Unit & Integration Tests for Core Veltro Services
// Path: test/services_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:veltro/core/errors/app_error.dart';
import 'package:veltro/core/errors/result.dart';
import 'package:veltro/core/utils/retry_executor.dart';
import 'package:veltro/data/models/shield_scan_model.dart';
import 'package:veltro/data/services/paypal_sandbox_service.dart';
import 'package:veltro/data/services/shield_service.dart';
import 'package:veltro/data/services/wisepilot_service.dart';

void main() {
  group('PayPalSandboxService Tests', () {
    final service = PayPalSandboxService();

    test('calculateCorridor computes transparent fees and recipient yield', () {
      final res = service.calculateCorridor(
        sourceCurrency: 'USD',
        targetCurrency: 'KES',
        sendAmount: 250.00,
      );

      expect(res.isSuccess, isTrue);
      final calc = res.dataOrNull!;
      expect(calc.providers.length, equals(3));

      final paypal = calc.recommendedProvider;
      expect(paypal.isDirectIntegration, isTrue);
      expect(paypal.fee, equals(3.50));
      expect(paypal.recipientAmount, greaterThan(0.0));
    });

    test('calculateCorridor rejects negative or zero send amounts without fallback', () {
      final res = service.calculateCorridor(
        sourceCurrency: 'USD',
        targetCurrency: 'KES',
        sendAmount: -50.00,
      );

      expect(res.isFailure, isTrue);
      expect(res.errorOrNull?.domain, equals(ErrorDomain.validation));
    });

    test('createAndCaptureOrder settles payment in ledger and returns confirmed IDs', () async {
      final res = await service.createAndCaptureOrder(
        recipientIdentifier: 'test.recipient@example.com',
        sourceCurrency: 'USD',
        targetCurrency: 'KES',
        sendAmount: 150.00,
      );

      expect(res.isSuccess, isTrue);
      final tx = res.dataOrNull!;
      expect(tx.paypalOrderId, isNotNull);
      expect(tx.paypalCaptureId, isNotNull);
      expect(tx.timeline.length, equals(3));
    });

    test('createAndCaptureOrder with simulateDecline surfaces explicit error without silent fallback', () async {
      final res = await service.createAndCaptureOrder(
        recipientIdentifier: 'declined.user@example.com',
        sourceCurrency: 'USD',
        targetCurrency: 'KES',
        sendAmount: 100.00,
        simulateDecline: true,
      );

      expect(res.isFailure, isTrue);
      final err = res.errorOrNull!;
      expect(err.domain, equals(ErrorDomain.paypalGateway));
      expect(err.errorCode, equals('INSTRUMENT_DECLINED'));
      expect(err.isTransient, isFalse);
    });

    test('verifyTransactionId finds existing record and returns null for fabricated ID', () async {
      final validLookup = await service.verifyTransactionId('5O190127TN364715T');
      expect(validLookup.isSuccess, isTrue);
      expect(validLookup.dataOrNull, isNotNull);

      final invalidLookup = await service.verifyTransactionId('FABRICATED-NONEXISTENT-ID');
      expect(invalidLookup.isSuccess, isTrue);
      expect(invalidLookup.dataOrNull, isNull);
    });
  });

  group('ShieldService Threat Intelligence Tests', () {
    final service = ShieldService();

    test('analyzeMessage detects manufactured urgency and overpayment fraud patterns', () async {
      final scan = await service.analyzeMessage(
        'URGENT: I sent \$500 by accident instead of \$300. Please refund the difference immediately before police are contacted!',
      );

      expect(scan.riskTier == RiskTier.critical || scan.riskTier == RiskTier.high, isTrue);
      expect(scan.indicators.any((i) => i.code == 'IND_MANUFACTURED_URGENCY'), isTrue);
      expect(scan.indicators.any((i) => i.code == 'IND_OVERPAYMENT_INDICATOR'), isTrue);
    });

    test('analyzeMessage marks benign conversational text as LOW risk', () async {
      final scan = await service.analyzeMessage(
        'Hi, could you please send over the project brief when you have time? Thank you.',
      );

      expect(scan.riskTier, equals(RiskTier.low));
    });

    test('analyzeLink identifies typosquatting domain and flags as CRITICAL threat', () async {
      final scan = await service.analyzeLink('https://paypa1-security-verification.xyz/login');

      expect(scan.riskTier, equals(RiskTier.critical));
      expect(scan.indicators.any((i) => i.code == 'IND_TYPOSQUATTING_DOMAIN'), isTrue);
    });

    test('analyzeReceipt cross-references PayPal API and flags non-existent ID as CRITICAL', () async {
      final scan = await service.analyzeReceipt(
        receiptName: 'fake_receipt.jpg',
        claimedTransactionId: 'NONEXISTENT-ID-998822',
        claimedAmount: 500.00,
      );

      expect(scan.riskTier, equals(RiskTier.critical));
      expect(scan.providerVerification?.transactionExists, isFalse);
    });
  });

  group('WisePilotService Agent Tests', () {
    final service = WisePilotService();

    test('sendMessage with transfer question generates structured calculation card', () async {
      final msg = await service.sendMessage('How much does it cost to send \$200 USD to Nigeria?');

      expect(msg.toolOutput, isNotNull);
      expect(msg.toolOutput?.toolName, equals('calculate_transfer_fee'));
      expect(msg.toolOutput?.result['recipient_gets'], contains('NGN'));
    });

    test('sendMessage with suspicious request generates security advisory card', () async {
      final msg = await service.sendMessage('Someone sent me a receipt for an invoice, does it look suspicious?');

      expect(msg.toolOutput, isNotNull);
      expect(msg.toolOutput?.toolName, equals('scan_security_threat'));
    });
  });

  group('RetryExecutor Tests', () {
    test('execute succeeds on first attempt', () async {
      final res = await RetryExecutor.execute(
        actionLabel: 'fetch_data',
        operation: () async => const Success('data_payload'),
      );

      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull, equals('data_payload'));
    });

    test('execute retries transient error and succeeds on subsequent attempt', () async {
      int attempts = 0;
      final res = await RetryExecutor.execute(
        actionLabel: 'transient_call',
        baseDelay: const Duration(milliseconds: 10),
        operation: () async {
          attempts++;
          if (attempts < 2) {
            return Failure(AppError.network(message: 'Temporary socket error'));
          }
          return const Success('recovered_data');
        },
      );

      expect(res.isSuccess, isTrue);
      expect(res.dataOrNull, equals('recovered_data'));
      expect(attempts, equals(2));
    });

    test('execute reports failure with full diagnostics when retries exhaust without silent fallback', () async {
      final res = await RetryExecutor.execute(
        actionLabel: 'exhausting_call',
        maxAttempts: 2,
        baseDelay: const Duration(milliseconds: 10),
        operation: () async {
          return Failure(AppError.network(message: 'Persistent gateway failure'));
        },
      );

      expect(res.isFailure, isTrue);
      expect(res.errorOrNull?.errorCode, equals('ERR_NET_FAILURE'));
    });
  });
}
