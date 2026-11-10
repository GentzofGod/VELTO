// Global Payments & Route Comparison Screen
// Path: lib/presentation/screens/payments/payments_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/theme/veltro_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/corridor_rate_model.dart';
import '../../../data/services/paypal_sandbox_service.dart';
import '../../widgets/error_banner.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _amountController = TextEditingController(text: '250.00');
  final _recipientController = TextEditingController(text: 'samuel.kamau@nairobi.tech');

  String _sourceCurrency = 'USD';
  String _targetCurrency = 'KES';
  bool _simulateDecline = false;
  bool _isProcessing = false;
  AppError? _currentError;

  CorridorCalculation? _calculation;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  void _recalculate() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final res = PayPalSandboxService().calculateCorridor(
      sourceCurrency: _sourceCurrency,
      targetCurrency: _targetCurrency,
      sendAmount: amount,
    );

    setState(() {
      if (res.isSuccess) {
        _calculation = res.dataOrNull;
        _currentError = null;
      } else {
        _currentError = res.errorOrNull;
        _calculation = null;
      }
    });
  }

  void _showExplicitConfirmationDialog() {
    if (_calculation == null) return;
    final provider = _calculation!.recommendedProvider;
    bool confirmedCheckbox = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              title: Row(
                children: const [
                  Icon(Icons.verified_user_outlined, color: VeltroTheme.primaryNavy),
                  SizedBox(width: 10.0),
                  Text('Confirm Payment Authorization'),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Please verify the transfer breakdown before proceeding with PayPal Sandbox settlement. This action authorizes payment movement.',
                      style: TextStyle(fontSize: 13.0, color: VeltroTheme.textSecondary),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: VeltroTheme.surfaceMuted,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        children: [
                          _buildModalRow('Recipient', _recipientController.text),
                          _buildModalRow('Send Amount', '$_sourceCurrency ${_amountController.text}'),
                          _buildModalRow('Platform Fee', CurrencyFormatter.format(provider.fee, _sourceCurrency)),
                          _buildModalRow('Exchange Rate', '1 $_sourceCurrency = ${provider.effectiveRate.toStringAsFixed(2)} $_targetCurrency'),
                          _buildModalRow('Recipient Yield', CurrencyFormatter.format(provider.recipientAmount, _targetCurrency)),
                          _buildModalRow('Payment Method', 'PayPal Sandbox Instant Payout'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: confirmedCheckbox,
                      activeColor: VeltroTheme.primaryNavy,
                      title: const Text(
                        'I have verified the recipient address and confirm the transaction breakdown.',
                        style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          confirmedCheckbox = val ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: confirmedCheckbox
                      ? () {
                          Navigator.of(context).pop();
                          _executePayment();
                        }
                      : null,
                  child: const Text('Authorize & Pay'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _executePayment() async {
    setState(() {
      _isProcessing = true;
      _currentError = null;
    });

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final res = await PayPalSandboxService().createAndCaptureOrder(
      recipientIdentifier: _recipientController.text,
      sourceCurrency: _sourceCurrency,
      targetCurrency: _targetCurrency,
      sendAmount: amount,
      simulateDecline: _simulateDecline,
    );

    setState(() {
      _isProcessing = false;
      if (res.isFailure) {
        _currentError = res.errorOrNull;
      }
    });

    if (res.isSuccess && mounted) {
      final tx = res.dataOrNull!;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Row(
            children: const [
              Icon(Icons.check_circle_outline, color: VeltroTheme.accentEmerald),
              SizedBox(width: 8.0),
              Text('Payment Completed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your transfer of \$${tx.sendAmount.toStringAsFixed(2)} ${tx.sourceCurrency} has settled.'),
              const SizedBox(height: 8.0),
              Text('PayPal Order ID: ${tx.paypalOrderId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
              Text('PayPal Capture ID: ${tx.paypalCaptureId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
              const SizedBox(height: 8.0),
              const Text('The transaction is recorded in the Transaction Centre with cryptographic webhook verification.', style: TextStyle(fontSize: 12.0, color: VeltroTheme.textSecondary)),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildModalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.0, color: VeltroTheme.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600, color: VeltroTheme.textPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'International Payment Calculator & Comparison',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: VeltroTheme.primaryNavy,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4.0),
              const Text(
                'Compare verified rates, transparent fees, and execute payments via PayPal Sandbox.',
                style: TextStyle(fontSize: 14.0, color: VeltroTheme.textSecondary),
              ),
              const SizedBox(height: 20.0),

              // Active Error Banner (Zero Fallback)
              if (_currentError != null)
                ErrorBanner(
                  error: _currentError!,
                  onRetry: _executePayment,
                  onDismiss: () => setState(() => _currentError = null),
                ),

              // Calculator Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: VeltroTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: VeltroTheme.borderSubtle),
                  boxShadow: VeltroTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount and Source Currency
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'You Send',
                              prefixIcon: Icon(Icons.payment_outlined),
                            ),
                            onChanged: (_) => _recalculate(),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _sourceCurrency,
                            decoration: const InputDecoration(labelText: 'Currency'),
                            items: ApiConstants.supportedCurrencies
                                .map((c) => DropdownMenuItem(value: c.code, child: Text(c.code)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _sourceCurrency = val);
                                _recalculate();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Destination Currency & Recipient
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _recipientController,
                            decoration: const InputDecoration(
                              labelText: 'Recipient Email or Identifier',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _targetCurrency,
                            decoration: const InputDecoration(labelText: 'Receive In'),
                            items: ApiConstants.supportedCurrencies
                                .map((c) => DropdownMenuItem(value: c.code, child: Text('${c.code} (${c.country})')))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _targetCurrency = val);
                                _recalculate();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Negative Testing Simulation Toggle
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: VeltroTheme.surfaceMuted,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.science_outlined, size: 20.0, color: VeltroTheme.primaryNavy),
                              SizedBox(width: 8.0),
                              Text(
                                'Simulate PayPal Sandbox Card Decline (Negative Testing)',
                                style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Switch(
                            value: _simulateDecline,
                            activeColor: VeltroTheme.primaryNavy,
                            onChanged: (val) {
                              setState(() => _simulateDecline = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // Provider Comparison Cards
              if (_calculation != null) ...[
                const Text(
                  'Available Payment Routes & Fee Comparison',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: VeltroTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 12.0),
                ..._calculation!.providers.map((p) => _buildProviderComparisonCard(p)),
                const SizedBox(height: 20.0),

                // Review & Pay Button
                SizedBox(
                  width: double.infinity,
                  height: 52.0,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: VeltroTheme.primaryNavy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 18.0,
                            height: 18.0,
                            child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white),
                          )
                        : const Icon(Icons.lock_outline),
                    label: Text(
                      _isProcessing ? 'Processing with PayPal Sandbox...' : 'Review & Pay with PayPal Sandbox',
                      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                    ),
                    onPressed: _isProcessing ? null : _showExplicitConfirmationDialog,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderComparisonCard(ProviderOption provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: provider.isDirectIntegration ? VeltroTheme.accentEmeraldLight.withOpacity(0.3) : VeltroTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: provider.isDirectIntegration ? VeltroTheme.accentEmerald : VeltroTheme.borderSubtle,
          width: provider.isDirectIntegration ? 1.5 : 1.0,
        ),
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
                    provider.isDirectIntegration ? Icons.verified_outlined : Icons.swap_horiz_outlined,
                    color: provider.isDirectIntegration ? VeltroTheme.primaryNavy : VeltroTheme.textSecondary,
                    size: 20.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    provider.providerName,
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: VeltroTheme.primaryNavy,
                    ),
                  ),
                ],
              ),
              if (provider.isDirectIntegration)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: VeltroTheme.accentEmerald,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const Text(
                    'Recommended Direct',
                    style: TextStyle(color: Colors.white, fontSize: 10.0, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recipient Gets', style: TextStyle(fontSize: 12.0, color: VeltroTheme.textSecondary)),
                  Text(
                    CurrencyFormatter.format(provider.recipientAmount, _targetCurrency),
                    style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: VeltroTheme.primaryNavy),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Platform Fee', style: TextStyle(fontSize: 12.0, color: VeltroTheme.textSecondary)),
                  Text(
                    CurrencyFormatter.format(provider.fee, _sourceCurrency),
                    style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: VeltroTheme.textPrimary),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Estimated Delivery', style: TextStyle(fontSize: 12.0, color: VeltroTheme.textSecondary)),
                  Text(
                    provider.estimatedDelivery,
                    style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600, color: VeltroTheme.accentEmerald),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            provider.note,
            style: const TextStyle(fontSize: 12.0, color: VeltroTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
