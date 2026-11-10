// Retrial Executor with Jittered Exponential Backoff
// Path: lib/core/utils/retry_executor.dart

import 'dart:math';
import '../errors/app_error.dart';
import '../errors/result.dart';

class RetryExecutor {
  static final Random _random = Random();

  /// Executes an operation with automated retries on transient failures.
  /// If retries exhaust, it returns Failure with full diagnostics.
  static Future<Result<T>> execute<T>({
    required Future<Result<T>> Function() operation,
    required String actionLabel,
    int maxAttempts = 3,
    Duration baseDelay = const Duration(milliseconds: 600),
  }) async {
    int attempt = 0;

    while (attempt < maxAttempts) {
      attempt++;
      try {
        final result = await operation();
        if (result.isSuccess) {
          return result;
        }

        final error = result.errorOrNull!;
        final isLastAttempt = attempt >= maxAttempts;

        if (isLastAttempt || !error.isTransient) {
          return result;
        }

        // Calculate Exponential Backoff with Full Jitter
        final maxDelayMs = baseDelay.inMilliseconds * (1 << (attempt - 1));
        final jitteredDelayMs = _random.nextInt(max(1, maxDelayMs));
        await Future.delayed(Duration(milliseconds: jitteredDelayMs));
      } catch (exception) {
        if (attempt >= maxAttempts) {
          return Failure(
            AppError.network(
              message: 'Failed to $actionLabel after $maxAttempts attempts.',
              details: exception.toString(),
            ),
          );
        }
        final maxDelayMs = baseDelay.inMilliseconds * (1 << (attempt - 1));
        final jitteredDelayMs = _random.nextInt(max(1, maxDelayMs));
        await Future.delayed(Duration(milliseconds: jitteredDelayMs));
      }
    }

    return Failure(
      AppError.network(
        message: 'Network operation timed out for $actionLabel.',
      ),
    );
  }
}
