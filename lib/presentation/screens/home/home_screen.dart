// Home Dashboard Screen
// Path: lib/presentation/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/veltro_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/services/paypal_sandbox_service.dart';
import '../transactions/widgets/transaction_detail_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hideSensitiveInfo = false;
  final double _connectedBalance = 14850.00;

  @override
  Widget build(BuildContext context) {
    final transactions = PayPalSandboxService().transactions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Welcome back, Alex',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: VeltroTheme.primaryNavy,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          'Intelligent global payments and proactive security',
                          style: TextStyle(
                            fontSize: 13.0,
                            color: VeltroTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _hideSensitiveInfo ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: VeltroTheme.textSecondary,
                    ),
                    tooltip: _hideSensitiveInfo ? 'Show balances' : 'Hide sensitive info',
                    onPressed: () {
                      setState(() {
                        _hideSensitiveInfo = !_hideSensitiveInfo;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // Connected Account Balance & Quick Actions
              _buildBalanceCard(),
              const SizedBox(height: 24.0),

              // Veltro Shield Active Security Alert Banner
              _buildSecurityAlertCard(),
              const SizedBox(height: 24.0),

              // Live Exchange Rates & Insights
              _buildExchangeRateGrid(),
              const SizedBox(height: 28.0),

              // Recent Transactions Header & List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Recent Verified Transactions',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: VeltroTheme.primaryNavy,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_forward, size: 16.0),
                    label: const Text('View All'),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              if (transactions.isEmpty)
                _buildEmptyTransactionsCard()
              else
                ...transactions.take(3).map((tx) => _buildTransactionCard(tx)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: VeltroTheme.primaryNavy,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: VeltroTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: const [
                    Icon(Icons.account_balance_wallet_outlined, color: VeltroTheme.accentEmerald, size: 18.0),
                    SizedBox(width: 6.0),
                    Flexible(
                      child: Text(
                        'PayPal Sandbox Account',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: VeltroTheme.accentEmerald.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle_outline, color: VeltroTheme.accentEmerald, size: 12.0),
                    SizedBox(width: 4.0),
                    Text(
                      'Sandbox Active',
                      style: TextStyle(
                        color: VeltroTheme.accentEmerald,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Text(
            CurrencyFormatter.format(_connectedBalance, 'USD', hideSensitive: _hideSensitiveInfo),
            style: const TextStyle(
              color: VeltroTheme.surfaceWhite,
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 20.0),
          const Divider(color: Color(0xFF1E293B)),
          const SizedBox(height: 12.0),

          // Quick Actions Tray
          Wrap(
            spacing: 12.0,
            runSpacing: 10.0,
            children: [
              _buildActionButton(
                label: 'Send Money',
                icon: Icons.send_outlined,
                onTap: () {},
              ),
              _buildActionButton(
                label: 'Compare Rates',
                icon: Icons.swap_horiz_outlined,
                onTap: () {},
              ),
              _buildActionButton(
                label: 'Shield Inspection',
                icon: Icons.shield_outlined,
                onTap: () {},
              ),
              _buildActionButton(
                label: 'Ask WisePilot',
                icon: Icons.psychology_outlined,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: VeltroTheme.surfaceWhite, size: 16.0),
            const SizedBox(width: 8.0),
            Text(
              label,
              style: const TextStyle(
                color: VeltroTheme.surfaceWhite,
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityAlertCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: VeltroTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: VeltroTheme.borderSubtle),
        boxShadow: VeltroTheme.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: VeltroTheme.accentEmeraldLight,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: VeltroTheme.primaryNavy,
              size: 22.0,
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Veltro Shield Protection Active',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: VeltroTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2.0),
                Text(
                  'Zero unverified receipts detected. Live PayPal Sandbox transaction lookup enabled.',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: VeltroTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeRateGrid() {
    final corridors = [
      {'pair': 'USD / KES', 'rate': '129.50', 'spread': '0.8%', 'trend': 'Stable'},
      {'pair': 'USD / NGN', 'rate': '1620.00', 'spread': '1.2%', 'trend': 'Volatile'},
      {'pair': 'USD / EUR', 'rate': '0.92', 'spread': '0.4%', 'trend': 'Liquid'},
      {'pair': 'USD / INR', 'rate': '83.40', 'spread': '0.5%', 'trend': 'Competitive'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Exchange Rates & Corridors',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: VeltroTheme.primaryNavy,
          ),
        ),
        const SizedBox(height: 12.0),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 260.0,
            mainAxisExtent: 100.0,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
          ),
          itemCount: corridors.length,
          itemBuilder: (context, index) {
            final item = corridors[index];
            return Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: VeltroTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: VeltroTheme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['pair']!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                            color: VeltroTheme.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        item['trend']!,
                        style: const TextStyle(
                          fontSize: 11.0,
                          color: VeltroTheme.accentEmerald,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          item['rate']!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: VeltroTheme.primaryNavy,
                          ),
                        ),
                      ),
                      Text(
                        'Spread: ${item['spread']!}',
                        style: const TextStyle(
                          fontSize: 11.0,
                          color: VeltroTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransactionCard(TransactionModel tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: VeltroTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: VeltroTheme.borderSubtle),
        boxShadow: VeltroTheme.cardShadow,
      ),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => TransactionDetailModal(transaction: tx),
          );
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: VeltroTheme.accentEmeraldLight,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: VeltroTheme.primaryNavy,
                size: 20.0,
              ),
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.recipientIdentifier,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: VeltroTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Order ID: ${tx.paypalOrderId ?? 'Pending'} • ${CurrencyFormatter.formatDate(tx.createdAt)}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: VeltroTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(tx.sendAmount, tx.sourceCurrency, hideSensitive: _hideSensitiveInfo),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: VeltroTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Delivered: ${CurrencyFormatter.format(tx.recipientAmount, tx.targetCurrency, hideSensitive: _hideSensitiveInfo)}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.0,
                      color: VeltroTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTransactionsCard() {
    return Container(
      padding: const EdgeInsets.all(32.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: VeltroTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: VeltroTheme.borderSubtle),
      ),
      child: Column(
        children: const [
          Icon(Icons.receipt_long_outlined, size: 40.0, color: VeltroTheme.textMuted),
          SizedBox(height: 12.0),
          Text(
            'No transactions recorded yet',
            style: TextStyle(fontWeight: FontWeight.w600, color: VeltroTheme.textPrimary),
          ),
          SizedBox(height: 4.0),
          Text(
            'Use the Payments tab to calculate and simulate your first transfer.',
            style: TextStyle(fontSize: 13.0, color: VeltroTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
