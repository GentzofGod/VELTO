// WisePilot Financial AI Assistant Service
// Path: lib/data/services/wisepilot_service.dart

import '../models/wisepilot_message_model.dart';
import 'paypal_sandbox_service.dart';

class WisePilotService {
  static final WisePilotService _instance = WisePilotService._internal();
  factory WisePilotService() => _instance;
  WisePilotService._internal();

  final List<WisePilotMessage> _conversation = [
    WisePilotMessage(
      id: 'msg_welcome',
      sender: MessageSender.wisePilot,
      text: 'Hello, Alex. I am WisePilot, your international payments and transaction security assistant. How can I assist you with your cross-border transfers today?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  List<WisePilotMessage> get conversation => List.unmodifiable(_conversation);

  /// Processes user message, executes appropriate tool heuristics, and returns structured response
  Future<WisePilotMessage> sendMessage(String text) async {
    final userMessage = WisePilotMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.user,
      text: text,
      timestamp: DateTime.now(),
    );
    _conversation.add(userMessage);

    await Future.delayed(const Duration(milliseconds: 750));

    final lower = text.toLowerCase();
    WisePilotMessage botResponse;

    // Pattern 1: Transfer Cost / Fee Calculation
    if (lower.contains('send') || lower.contains('cost') || lower.contains('fee') || lower.contains('how much')) {
      double amount = 200.0;
      final amountMatch = RegExp(r'\$?(\d+(\.\d+)?)').firstMatch(text);
      if (amountMatch != null) {
        amount = double.tryParse(amountMatch.group(1)!) ?? 200.0;
      }

      String targetCurrency = 'KES';
      if (lower.contains('nigeria') || lower.contains('ngn') || lower.contains('naira')) {
        targetCurrency = 'NGN';
      } else if (lower.contains('india') || lower.contains('inr') || lower.contains('rupee')) {
        targetCurrency = 'INR';
      } else if (lower.contains('philippines') || lower.contains('php') || lower.contains('peso')) {
        targetCurrency = 'PHP';
      } else if (lower.contains('europe') || lower.contains('eur') || lower.contains('euro')) {
        targetCurrency = 'EUR';
      }

      final calcRes = PayPalSandboxService().calculateCorridor(
        sourceCurrency: 'USD',
        targetCurrency: targetCurrency,
        sendAmount: amount,
      );

      final calc = calcRes.dataOrNull;
      final provider = calc?.recommendedProvider;

      botResponse = WisePilotMessage(
        id: 'msg_ai_${DateTime.now().millisecondsSinceEpoch}',
        sender: MessageSender.wisePilot,
        text: 'I calculated the transfer breakdown for sending \$${amount.toStringAsFixed(2)} USD to $targetCurrency. The recipient will receive approximately ${provider?.recipientAmount.toStringAsFixed(2)} $targetCurrency after transparent fees.',
        timestamp: DateTime.now(),
        toolOutput: WisePilotToolOutput(
          toolName: 'calculate_transfer_fee',
          parameters: {
            'source_currency': 'USD',
            'target_currency': targetCurrency,
            'send_amount': amount,
          },
          result: {
            'send_amount': '\$${amount.toStringAsFixed(2)} USD',
            'transparent_fee': '\$${provider?.fee.toStringAsFixed(2)} USD',
            'applied_rate': '1 USD = ${provider?.effectiveRate.toStringAsFixed(2)} $targetCurrency',
            'recipient_gets': '${provider?.recipientAmount.toStringAsFixed(2)} $targetCurrency',
            'estimated_time': provider?.estimatedDelivery ?? 'Instant',
          },
          actionButtonText: 'Configure Payment in Payments Hub',
          actionRoute: '/payments',
        ),
      );
    }
    // Pattern 2: Suspicious Payment / Scam Question
    else if (lower.contains('suspicious') || lower.contains('scam') || lower.contains('safe') || lower.contains('receipt') || lower.contains('invoice')) {
      botResponse = WisePilotMessage(
        id: 'msg_ai_${DateTime.now().millisecondsSinceEpoch}',
        sender: MessageSender.wisePilot,
        text: 'Financial safety notice: You should never rely on digital screenshots, push notification images, or unverified emails as confirmation of funds arrival. Real payment arrival must always be confirmed directly through your official PayPal balance.',
        timestamp: DateTime.now(),
        toolOutput: const WisePilotToolOutput(
          toolName: 'scan_security_threat',
          parameters: {'module': 'Veltro Shield Security'},
          result: {
            'advisory': 'High-risk indicators should be inspected using Veltro Shield before releasing any deliverables or sending refund payments.',
            'threat_status': 'Scanner Ready',
          },
          actionButtonText: 'Open Veltro Shield Scanner',
          actionRoute: '/shield',
        ),
      );
    }
    // Pattern 3: General Financial Assistance
    else {
      botResponse = WisePilotMessage(
        id: 'msg_ai_${DateTime.now().millisecondsSinceEpoch}',
        sender: MessageSender.wisePilot,
        text: 'I can help you evaluate international transfer corridors, compare PayPal Sandbox with wire options, and run threat assessments on payment requests. What corridor or transaction would you like to review?',
        timestamp: DateTime.now(),
      );
    }

    _conversation.add(botResponse);
    return botResponse;
  }
}
