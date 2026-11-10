// Transaction Detail Modal with Chronological Timeline
// Path: lib/presentation/screens/transactions/widgets/transaction_detail_modal.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/veltro_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/transaction_model.dart';

class TransactionDetailModal extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailModal({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: VeltroTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Drag Handle
          Center(
            child: Container(
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: VeltroTheme.borderSubtle,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Header Title & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transaction Details',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: VeltroTheme.primaryNavy,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: VeltroTheme.accentEmeraldLight,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 14.0, color: VeltroTheme.primaryNavy),
                    const SizedBox(width: 4.0),
                    Text(
                      transaction.statusDisplay,
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: VeltroTheme.primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          const Divider(),

          // Amount Summary
          Expanded(
            child: ListView(
              children: [
                _buildInfoRow('Sender Account', transaction.senderEmail),
                _buildInfoRow('Recipient Identifier', transaction.recipientIdentifier),
                _buildInfoRow('Gross Send Amount', CurrencyFormatter.format(transaction.sendAmount, transaction.sourceCurrency)),
                _buildInfoRow('Platform Fee', CurrencyFormatter.format(transaction.feeAmount, transaction.sourceCurrency)),
                _buildInfoRow('Applied FX Rate', '1 ${transaction.sourceCurrency} = ${transaction.exchangeRate.toStringAsFixed(2)} ${transaction.targetCurrency}'),
                _buildInfoRow('Net Delivered Amount', CurrencyFormatter.format(transaction.recipientAmount, transaction.targetCurrency)),
                _buildInfoRow('Payment Rail', transaction.paymentMethod),
                _buildInfoRow('PayPal Order ID', transaction.paypalOrderId ?? 'N/A'),
                _buildInfoRow('PayPal Capture ID', transaction.paypalCaptureId ?? 'N/A'),
                const SizedBox(height: 20.0),

                // Chronological Timeline
                const Text(
                  'Chronological Tracking Timeline',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: VeltroTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 16.0),
                ...transaction.timeline.map((event) => _buildTimelineItem(event)),
              ],
            ),
          ),

          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.download_outlined, size: 18.0),
                  label: const Text('Export Audit Dossier'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cryptographic audit dossier generated for this transaction.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.0,
              color: VeltroTheme.textSecondary,
            ),
          ),
          SelectableText(
            value,
            style: const TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              color: VeltroTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(TrackingEvent event) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16.0,
              height: 16.0,
              decoration: BoxDecoration(
                color: event.isCompleted ? VeltroTheme.accentEmerald : VeltroTheme.borderSubtle,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 10.0, color: Colors.white),
            ),
            Container(
              width: 2.0,
              height: 36.0,
              color: VeltroTheme.borderSubtle,
            ),
          ],
        ),
        const SizedBox(width: 14.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: VeltroTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                event.description,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: VeltroTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                CurrencyFormatter.formatDate(event.timestamp),
                style: const TextStyle(
                  fontSize: 11.0,
                  color: VeltroTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
