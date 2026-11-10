// Actionable Error Banner with Retrial Action
// Path: lib/presentation/widgets/error_banner.dart

import 'package:flutter/material.dart';
import '../../core/errors/app_error.dart';
import '../../core/theme/veltro_theme.dart';

class ErrorBanner extends StatelessWidget {
  final AppError error;
  final VoidCallback onRetry;
  final VoidCallback? onDismiss;

  const ErrorBanner({
    super.key,
    required this.error,
    required this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: VeltroTheme.riskCriticalContainer,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: VeltroTheme.riskCritical.withOpacity(0.4),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline,
                color: VeltroTheme.riskCritical,
                size: 24.0,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      error.humanMessage,
                      style: const TextStyle(
                        color: VeltroTheme.textPrimary,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (error.technicalDetails != null) ...[
                      const SizedBox(height: 6.0),
                      Text(
                        error.technicalDetails!,
                        style: const TextStyle(
                          color: VeltroTheme.textSecondary,
                          fontSize: 12.0,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                    const SizedBox(height: 4.0),
                    Text(
                      'Code: ${error.errorCode} • Ref: ${error.correlationId}',
                      style: const TextStyle(
                        color: VeltroTheme.textMuted,
                        fontSize: 11.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onDismiss != null)
                TextButton(
                  onPressed: onDismiss,
                  child: const Text('Dismiss'),
                ),
              const SizedBox(width: 8.0),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: VeltroTheme.primaryNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                ),
                icon: const Icon(Icons.refresh_outlined, size: 16.0),
                label: const Text('Retry Operation'),
                onPressed: onRetry,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
