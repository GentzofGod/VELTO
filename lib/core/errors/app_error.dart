// App Error Definition
// Path: lib/core/errors/app_error.dart

enum ErrorDomain {
  network,
  paypalGateway,
  aiReasoning,
  authentication,
  validation,
  storage,
}

class AppError {
  final String errorCode;
  final ErrorDomain domain;
  final String humanMessage;
  final String? technicalDetails;
  final String correlationId;
  final bool isTransient;
  final DateTime timestamp;

  AppError({
    required this.errorCode,
    required this.domain,
    required this.humanMessage,
    this.technicalDetails,
    required this.correlationId,
    this.isTransient = true,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AppError.network({
    required String message,
    String? details,
  }) {
    return AppError(
      errorCode: 'ERR_NET_FAILURE',
      domain: ErrorDomain.network,
      humanMessage: message,
      technicalDetails: details,
      correlationId: DateTime.now().millisecondsSinceEpoch.toString(),
      isTransient: true,
    );
  }

  factory AppError.paypal({
    required String errorCode,
    required String message,
    String? details,
    bool isTransient = false,
  }) {
    return AppError(
      errorCode: errorCode,
      domain: ErrorDomain.paypalGateway,
      humanMessage: message,
      technicalDetails: details,
      correlationId: DateTime.now().millisecondsSinceEpoch.toString(),
      isTransient: isTransient,
    );
  }

  factory AppError.ai({
    required String message,
    String? details,
  }) {
    return AppError(
      errorCode: 'ERR_AI_INFERENCE',
      domain: ErrorDomain.aiReasoning,
      humanMessage: message,
      technicalDetails: details,
      correlationId: DateTime.now().millisecondsSinceEpoch.toString(),
      isTransient: true,
    );
  }

  factory AppError.validation({
    required String message,
    String? details,
  }) {
    return AppError(
      errorCode: 'ERR_VALIDATION',
      domain: ErrorDomain.validation,
      humanMessage: message,
      technicalDetails: details,
      correlationId: DateTime.now().millisecondsSinceEpoch.toString(),
      isTransient: false,
    );
  }
}
