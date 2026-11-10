// WisePilot Message & Tool Execution Models
// Path: lib/data/models/wisepilot_message_model.dart

enum MessageSender {
  user,
  wisePilot,
}

class WisePilotToolOutput {
  final String toolName;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> result;
  final String? actionButtonText;
  final String? actionRoute;

  const WisePilotToolOutput({
    required this.toolName,
    required this.parameters,
    required this.result,
    this.actionButtonText,
    this.actionRoute,
  });
}

class WisePilotMessage {
  final String id;
  final MessageSender sender;
  final String text;
  final DateTime timestamp;
  final WisePilotToolOutput? toolOutput;

  const WisePilotMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.toolOutput,
  });
}
