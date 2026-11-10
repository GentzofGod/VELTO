// WisePilot Conversational Financial Assistant Screen
// Path: lib/presentation/screens/wisepilot/wisepilot_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/veltro_theme.dart';
import '../../../data/models/wisepilot_message_model.dart';
import '../../../data/services/wisepilot_service.dart';

class WisePilotScreen extends StatefulWidget {
  const WisePilotScreen({super.key});

  @override
  State<WisePilotScreen> createState() => _WisePilotScreenState();
}

class _WisePilotScreenState extends State<WisePilotScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isAwaitingResponse = false;

  final List<String> _suggestionChips = [
    'How much to send \$250 USD to Kenya?',
    'What does it cost to send \$180 USD to Nigeria?',
    'Someone claims they sent \$200 extra and wants a refund. Is this safe?',
    'What should I check before accepting international payments?',
  ];

  Future<void> _handleSend([String? presetText]) async {
    final text = presetText ?? _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    setState(() => _isAwaitingResponse = true);
    _scrollToBottom();

    await WisePilotService().sendMessage(text);

    setState(() => _isAwaitingResponse = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = WisePilotService().conversation;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880.0),
        child: Column(
          children: [
            // Conversational Stream
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return _buildMessageItem(msg);
                },
              ),
            ),

            if (_isAwaitingResponse)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: const [
                    SizedBox(
                      width: 14.0,
                      height: 14.0,
                      child: CircularProgressIndicator(strokeWidth: 2.0, color: VeltroTheme.primaryNavy),
                    ),
                    SizedBox(width: 10.0),
                    Text(
                      'WisePilot is computing payment routes and security heuristics...',
                      style: TextStyle(fontSize: 12.0, color: VeltroTheme.textMuted),
                    ),
                  ],
                ),
              ),

            // Suggestion Chips
            Container(
              height: 44.0,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _suggestionChips.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8.0),
                itemBuilder: (context, index) {
                  final chip = _suggestionChips[index];
                  return ActionChip(
                    backgroundColor: VeltroTheme.surfaceWhite,
                    side: const BorderSide(color: VeltroTheme.borderSubtle),
                    label: Text(chip, style: const TextStyle(fontSize: 12.0, color: VeltroTheme.primaryNavy)),
                    onPressed: () => _handleSend(chip),
                  );
                },
              ),
            ),
            const SizedBox(height: 10.0),

            // Input Bar
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: VeltroTheme.surfaceWhite,
                border: Border(top: BorderSide(color: VeltroTheme.borderSubtle)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: const InputDecoration(
                        hintText: 'Ask WisePilot about rates, fees, or suspicious requests...',
                        prefixIcon: Icon(Icons.psychology_outlined),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16.0),
                      backgroundColor: VeltroTheme.primaryNavy,
                    ),
                    onPressed: _handleSend,
                    child: const Icon(Icons.send, size: 18.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(WisePilotMessage msg) {
    final isUser = msg.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: VeltroTheme.primaryNavy,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Icon(Icons.psychology_outlined, color: Colors.white, size: 20.0),
            ),
            const SizedBox(width: 12.0),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: isUser ? VeltroTheme.primaryNavy : VeltroTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: isUser ? VeltroTheme.primaryNavy : VeltroTheme.borderSubtle,
                    ),
                    boxShadow: isUser ? [] : VeltroTheme.cardShadow,
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: isUser ? VeltroTheme.surfaceWhite : VeltroTheme.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),

                // Structured Tool Execution Cards
                if (msg.toolOutput != null) ...[
                  const SizedBox(height: 10.0),
                  _buildStructuredToolCard(msg.toolOutput!),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12.0),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: VeltroTheme.surfaceMuted,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Icon(Icons.person_outline, color: VeltroTheme.textPrimary, size: 20.0),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStructuredToolCard(WisePilotToolOutput tool) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: VeltroTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: VeltroTheme.accentEmerald, width: 1.2),
        boxShadow: VeltroTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_outlined, color: VeltroTheme.accentEmerald, size: 18.0),
              const SizedBox(width: 8.0),
              Text(
                'Tool Output: ${tool.toolName}',
                style: const TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                  color: VeltroTheme.primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          const Divider(height: 1.0),
          const SizedBox(height: 10.0),
          ...tool.result.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(fontSize: 11.0, color: VeltroTheme.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      entry.value.toString(),
                      style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: VeltroTheme.textPrimary),
                    ),
                  ],
                ),
              )),
          if (tool.actionButtonText != null) ...[
            const SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: VeltroTheme.primaryNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                ),
                icon: const Icon(Icons.arrow_forward, size: 14.0),
                label: Text(tool.actionButtonText!, style: const TextStyle(fontSize: 12.0)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Navigating to ${tool.actionRoute}...')),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
