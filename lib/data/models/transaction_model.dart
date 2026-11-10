// Transaction Model with Chronological Tracking
// Path: lib/data/models/transaction_model.dart

enum TransactionStatus {
  created,
  approved,
  completed,
  failed,
  denied,
}

class TrackingEvent {
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isCompleted;

  const TrackingEvent({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isCompleted,
  });
}

class TransactionModel {
  final String id;
  final String? paypalOrderId;
  final String? paypalCaptureId;
  final String senderEmail;
  final String recipientIdentifier;
  final String sourceCurrency;
  final String targetCurrency;
  final double sendAmount;
  final double feeAmount;
  final double exchangeRate;
  final double recipientAmount;
  final String paymentMethod;
  final TransactionStatus status;
  final DateTime createdAt;
  final List<TrackingEvent> timeline;

  const TransactionModel({
    required this.id,
    this.paypalOrderId,
    this.paypalCaptureId,
    required this.senderEmail,
    required this.recipientIdentifier,
    required this.sourceCurrency,
    required this.targetCurrency,
    required this.sendAmount,
    required this.feeAmount,
    required this.exchangeRate,
    required this.recipientAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.timeline,
  });

  String get statusDisplay => switch (status) {
    TransactionStatus.created => 'Created',
    TransactionStatus.approved => 'Approved',
    TransactionStatus.completed => 'Completed',
    TransactionStatus.failed => 'Failed',
    TransactionStatus.denied => 'Denied',
  };
}
