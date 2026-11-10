// Veltro Shield Security Dashboard & Threat Detection Suite
// Path: lib/presentation/screens/shield/shield_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/veltro_theme.dart';
import '../../../data/models/shield_scan_model.dart';
import '../../../data/services/shield_service.dart';

class ShieldScreen extends StatefulWidget {
  const ShieldScreen({super.key});

  @override
  State<ShieldScreen> createState() => _ShieldScreenState();
}

class _ShieldScreenState extends State<ShieldScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers
  final _messageController = TextEditingController();
  final _linkController = TextEditingController();
  final _receiptNameController = TextEditingController(text: 'paypal_payment_confirmation.png');
  final _receiptIdController = TextEditingController(text: '5O190127TN364715T');
  final _receiptAmountController = TextEditingController(text: '250.00');

  bool _isScanning = false;
  ShieldScanModel? _activeResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _linkController.dispose();
    _receiptNameController.dispose();
    _receiptIdController.dispose();
    _receiptAmountController.dispose();
    super.dispose();
  }

  Future<void> _scanMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    setState(() => _isScanning = true);
    final res = await ShieldService().analyzeMessage(_messageController.text);
    setState(() {
      _isScanning = false;
      _activeResult = res;
    });
  }

  Future<void> _scanLink() async {
    if (_linkController.text.trim().isEmpty) return;
    setState(() => _isScanning = true);
    final res = await ShieldService().analyzeLink(_linkController.text);
    setState(() {
      _isScanning = false;
      _activeResult = res;
    });
  }

  Future<void> _scanReceipt() async {
    final amount = double.tryParse(_receiptAmountController.text) ?? 0.0;
    setState(() => _isScanning = true);
    final res = await ShieldService().analyzeReceipt(
      receiptName: _receiptNameController.text,
      claimedTransactionId: _receiptIdController.text,
      claimedAmount: amount,
    );
    setState(() {
      _isScanning = false;
      _activeResult = res;
    });
  }

  void _loadExampleMessage(String text) {
    _messageController.text = text;
    _scanMessage();
  }

  void _loadExampleLink(String url) {
    _linkController.text = url;
    _scanLink();
  }

  @override
  Widget build(BuildContext context) {
    final articles = ShieldService().scamArticles;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: VeltroTheme.primaryNavy,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Icon(Icons.shield_outlined, color: Colors.white, size: 28.0),
                  ),
                  const SizedBox(width: 14.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Veltro Shield Security Suite',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: VeltroTheme.primaryNavy,
                          letterSpacing: -0.4,
                        ),
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        'Multi-modal fraud detection, receipt inspection, and threat intelligence',
                        style: TextStyle(fontSize: 14.0, color: VeltroTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // Scanner Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: VeltroTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: VeltroTheme.borderSubtle),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: VeltroTheme.primaryNavy,
                  unselectedLabelColor: VeltroTheme.textSecondary,
                  indicatorColor: VeltroTheme.primaryNavy,
                  indicatorWeight: 3.0,
                  tabs: const [
                    Tab(icon: Icon(Icons.mail_outline, size: 18.0), text: 'Message Scanner'),
                    Tab(icon: Icon(Icons.receipt_long_outlined, size: 18.0), text: 'Receipt Verifier'),
                    Tab(icon: Icon(Icons.link_outlined, size: 18.0), text: 'Link Inspector'),
                    Tab(icon: Icon(Icons.menu_book_outlined, size: 18.0), text: 'Scam Knowledge Hub'),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),

              // Tab View Content
              SizedBox(
                height: 380.0,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMessageScannerTab(),
                    _buildReceiptVerifierTab(),
                    _buildLinkInspectorTab(),
                    _buildScamKnowledgeTab(articles),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // Active Scan Inspection Result
              if (_activeResult != null) _buildScanResultView(_activeResult!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageScannerTab() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: VeltroTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: VeltroTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paste Email, SMS, or Marketplace Chat',
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: VeltroTheme.primaryNavy),
          ),
          const SizedBox(height: 6.0),
          const Text(
            'Checks for urgency tactics, unauthorized escrow, overpayment schemes, and impersonation.',
            style: TextStyle(fontSize: 13.0, color: VeltroTheme.textSecondary),
          ),
          const SizedBox(height: 12.0),
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'e.g. "I have accidentally sent \$500 extra. Please refund the difference urgently..."',
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 8.0,
                children: [
                  OutlinedButton(
                    onPressed: () => _loadExampleMessage(
                      'Hello, I just sent \$500 for your commission. Oh no, I sent \$200 extra by accident! Please wire back the \$200 right now before the bank closes!',
                    ),
                    child: const Text('Sample: Overpayment Scam'),
                  ),
                  OutlinedButton(
                    onPressed: () => _loadExampleMessage(
                      'Your PayPal payment is on hold. To release your \$1,200, you must first send an upfront courier clearance fee of \$80 via Western Union.',
                    ),
                    child: const Text('Sample: Courier Advance Fee'),
                  ),
                ],
              ),
              FilledButton.icon(
                icon: _isScanning
                    ? const SizedBox(width: 16.0, height: 16.0, child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white))
                    : const Icon(Icons.search),
                label: const Text('Analyze Message'),
                onPressed: _isScanning ? null : _scanMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptVerifierTab() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: VeltroTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: VeltroTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Digital Receipt & Confirmation Verification',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: VeltroTheme.primaryNavy),
              ),
              Text(
                'Crucial Rule: Screenshots are never proof of funds arrival.',
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600, color: VeltroTheme.riskHigh),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _receiptNameController,
                  decoration: const InputDecoration(labelText: 'Uploaded File Name', prefixIcon: Icon(Icons.file_present_outlined)),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: TextField(
                  controller: _receiptIdController,
                  decoration: const InputDecoration(labelText: 'Claimed PayPal Transaction ID', prefixIcon: Icon(Icons.tag)),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: TextField(
                  controller: _receiptAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Claimed Amount (USD)', prefixIcon: Icon(Icons.attach_money)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: VeltroTheme.surfaceMuted,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, size: 20.0, color: VeltroTheme.primaryNavy),
                SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    'Veltro Shield queries the PayPal Sandbox API to check whether the claimed Transaction ID exists and whether the settled currency and amount match exactly.',
                    style: TextStyle(fontSize: 13.0, color: VeltroTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 8.0,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      _receiptIdController.text = '5O190127TN364715T'; // Existing in demo ledger
                      _receiptAmountController.text = '250.00';
                      _scanReceipt();
                    },
                    child: const Text('Test Valid Provider Receipt'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      _receiptIdController.text = 'FAKE-998822-FABRICATED';
                      _receiptAmountController.text = '850.00';
                      _scanReceipt();
                    },
                    child: const Text('Test Fabricated Fake Receipt'),
                  ),
                ],
              ),
              FilledButton.icon(
                icon: const Icon(Icons.verified_outlined),
                label: const Text('Verify Against PayPal'),
                onPressed: _isScanning ? null : _scanReceipt,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLinkInspectorTab() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: VeltroTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: VeltroTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phishing & Typosquatting Link Inspector',
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: VeltroTheme.primaryNavy),
          ),
          const SizedBox(height: 6.0),
          const Text(
            'Inspect suspected payment links, invoice download URLs, and dispute redirect pages.',
            style: TextStyle(fontSize: 13.0, color: VeltroTheme.textSecondary),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _linkController,
            decoration: const InputDecoration(
              labelText: 'Destination URL to Inspect',
              hintText: 'https://paypa1-security-verification.xyz',
              prefixIcon: Icon(Icons.link_outlined),
            ),
          ),
          const SizedBox(height: 16.0),
          Wrap(
            spacing: 8.0,
            children: [
              OutlinedButton(
                onPressed: () => _loadExampleLink('https://paypa1-security-verification.xyz/dispute'),
                child: const Text('Test Typosquat Phishing Link'),
              ),
              OutlinedButton(
                onPressed: () => _loadExampleLink('https://paypal.com/checkoutnow'),
                child: const Text('Test Legitimate Link'),
              ),
            ],
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              icon: const Icon(Icons.travel_explore_outlined),
              label: const Text('Inspect Domain Safety'),
              onPressed: _isScanning ? null : _scanLink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScamKnowledgeTab(List<ScamArticle> articles) {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final art = articles[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          decoration: BoxDecoration(
            color: VeltroTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: VeltroTheme.borderSubtle),
          ),
          child: ExpansionTile(
            leading: const Icon(Icons.school_outlined, color: VeltroTheme.primaryNavy),
            title: Text(art.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
            subtitle: Text(art.category, style: const TextStyle(fontSize: 12.0, color: VeltroTheme.textSecondary)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(art.summary, style: const TextStyle(fontSize: 13.0)),
                    const SizedBox(height: 12.0),
                    const Text('Common Red Flags:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
                    ...art.redFlags.map((flag) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(child: Text(flag, style: const TextStyle(fontSize: 12.0))),
                            ],
                          ),
                        )),
                    const SizedBox(height: 10.0),
                    const Text('Prevention Protocol:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0, color: VeltroTheme.accentEmerald)),
                    ...art.preventionSteps.map((step) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: VeltroTheme.accentEmerald)),
                              Expanded(child: Text(step, style: const TextStyle(fontSize: 12.0))),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScanResultView(ShieldScanModel scan) {
    final (badgeColor, containerColor) = switch (scan.riskTier) {
      RiskTier.low => (VeltroTheme.riskLow, VeltroTheme.riskLowContainer),
      RiskTier.medium => (VeltroTheme.riskMedium, VeltroTheme.riskMediumContainer),
      RiskTier.high => (VeltroTheme.riskHigh, VeltroTheme.riskHighContainer),
      RiskTier.critical => (VeltroTheme.riskCritical, VeltroTheme.riskCriticalContainer),
    };

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: badgeColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    scan.riskTier == RiskTier.low ? Icons.shield_outlined : Icons.gpp_bad_outlined,
                    color: badgeColor,
                    size: 28.0,
                  ),
                  const SizedBox(width: 12.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan.riskLabel,
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: badgeColor),
                      ),
                      Text(
                        'Confidence Score: ${(scan.confidenceScore * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 12.0, color: VeltroTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.archive_outlined, size: 16.0),
                label: const Text('Save to Incident Reports'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved to your security incident archive.')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Text(scan.summary, style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: VeltroTheme.textPrimary)),
          const SizedBox(height: 16.0),
          const Divider(),

          // Indicators List
          const Text('Identified Risk Indicators:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
          const SizedBox(height: 8.0),
          ...scan.indicators.map((ind) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        ind.severity,
                        style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: badgeColor),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(child: Text(ind.description, style: const TextStyle(fontSize: 13.0))),
                  ],
                ),
              )),
          const SizedBox(height: 16.0),

          // Recommended Precautions
          const Text('Recommended Precautions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0)),
          const SizedBox(height: 6.0),
          ...scan.recommendedActions.map((action) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(action, style: const TextStyle(fontSize: 13.0))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
