// Notifications Screen with Highlighted Security Alerts
// Path: lib/presentation/screens/notifications/notifications_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/veltro_theme.dart';

enum NotificationType {
  securityAlert,
  paymentUpdate,
  exchangeRate,
  wisePilotAdvice,
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      NotificationItem(
        id: 'notif_001',
        type: NotificationType.securityAlert,
        title: 'Critical Threat Alert: Fabricated Receipt Identified',
        description: 'Veltro Shield detected an invalid transaction ID (FAKE-998822) that does not exist in PayPal records.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      NotificationItem(
        id: 'notif_002',
        type: NotificationType.paymentUpdate,
        title: 'PayPal Sandbox Transfer Settled',
        description: 'Your payment of \$250.00 USD to Samuel Kamau was confirmed via webhook.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      NotificationItem(
        id: 'notif_003',
        type: NotificationType.exchangeRate,
        title: 'Corridor Rate Alert: USD / KES',
        description: 'Mid-market rate reached 129.50 KES. Favorable window for East Africa transfers.',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      NotificationItem(
        id: 'notif_004',
        type: NotificationType.wisePilotAdvice,
        title: 'WisePilot Tip: Verifying Freelance Invoices',
        description: 'Always cross-reference client payout details with historical verified invoices before delivery.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications & Alerts'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...notifications.map((item) => _buildNotificationCard(item)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    final isSecurity = item.type == NotificationType.securityAlert;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isSecurity ? VeltroTheme.riskCriticalContainer : VeltroTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isSecurity ? VeltroTheme.riskCritical.withOpacity(0.5) : VeltroTheme.borderSubtle,
          width: isSecurity ? 1.5 : 1.0,
        ),
        boxShadow: VeltroTheme.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: isSecurity ? VeltroTheme.riskCritical.withOpacity(0.15) : VeltroTheme.accentEmeraldLight,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(
              isSecurity ? Icons.gpp_bad_outlined : Icons.notifications_outlined,
              color: isSecurity ? VeltroTheme.riskCritical : VeltroTheme.primaryNavy,
              size: 22.0,
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: isSecurity ? VeltroTheme.riskCritical : VeltroTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  item.description,
                  style: const TextStyle(fontSize: 13.0, color: VeltroTheme.textSecondary),
                ),
                const SizedBox(height: 6.0),
                Text(
                  _formatRelativeTime(item.timestamp),
                  style: const TextStyle(fontSize: 11.0, color: VeltroTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }
}
