// Transaction Centre & Ledger Screen
// Path: lib/presentation/screens/transactions/transactions_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/veltro_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/services/paypal_sandbox_service.dart';
import 'widgets/transaction_detail_modal.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();
  TransactionStatus? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTransactions = PayPalSandboxService().transactions;
    final query = _searchController.text.trim().toLowerCase();

    final filtered = allTransactions.where((tx) {
      if (_statusFilter != null && tx.status != _statusFilter) {
        return false;
      }
      if (query.isNotEmpty) {
        final matchesRecipient = tx.recipientIdentifier.toLowerCase().contains(query);
        final matchesOrder = tx.paypalOrderId?.toLowerCase().contains(query) ?? false;
        final matchesCapture = tx.paypalCaptureId?.toLowerCase().contains(query) ?? false;
        return matchesRecipient || matchesOrder || matchesCapture;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Centre & Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Export Comprehensive Ledger',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Consolidated transaction audit report exported.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Metrics Overview Card
                _buildMetricsCard(allTransactions),
                const SizedBox(height: 24.0),

                // Search Bar & Filter Chips
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by PayPal Order ID, Capture ID, or Recipient...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => _searchController.clear());
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14.0),

                Wrap(
                  spacing: 8.0,
                  children: [
                    FilterChip(
                      label: const Text('All Statuses'),
                      selected: _statusFilter == null,
                      onSelected: (_) => setState(() => _statusFilter = null),
                    ),
                    FilterChip(
                      label: const Text('Completed'),
                      selected: _statusFilter == TransactionStatus.completed,
                      onSelected: (_) => setState(() => _statusFilter = TransactionStatus.completed),
                    ),
                    FilterChip(
                      label: const Text('Approved'),
                      selected: _statusFilter == TransactionStatus.approved,
                      onSelected: (_) => setState(() => _statusFilter = TransactionStatus.approved),
                    ),
                    FilterChip(
                      label: const Text('Created'),
                      selected: _statusFilter == TransactionStatus.created,
                      onSelected: (_) => setState(() => _statusFilter = TransactionStatus.created),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),

                // Transactions List
                if (filtered.isEmpty)
                  _buildEmptyState()
                else
                  ...filtered.map((tx) => _buildTransactionCard(tx)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsCard(List<TransactionModel> transactions) {
    final totalUsd = transactions.fold<double>(0.0, (acc, tx) => acc + tx.sendAmount);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: VeltroTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: VeltroTheme.borderSubtle),
        boxShadow: VeltroTheme.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricCol('Total Transacted', CurrencyFormatter.format(totalUsd, 'USD'), Icons.account_balance_outlined),
          Container(width: 1.0, height: 40.0, color: VeltroTheme.borderSubtle),
          _buildMetricCol('Settled Transactions', '${transactions.length}', Icons.check_circle_outline),
          Container(width: 1.0, height: 40.0, color: VeltroTheme.borderSubtle),
          _buildMetricCol('Active Provider', 'PayPal Sandbox', Icons.verified_outlined),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String title, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16.0, color: VeltroTheme.textSecondary),
            const SizedBox(width: 6.0),
            Text(title, style: const TextStyle(fontSize: 12.0, color: VeltroTheme.textSecondary)),
          ],
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: VeltroTheme.primaryNavy),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(TransactionModel tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(18.0),
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.send_outlined, color: VeltroTheme.primaryNavy, size: 18.0),
                    const SizedBox(width: 8.0),
                    Text(
                      tx.recipientIdentifier,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: VeltroTheme.accentEmeraldLight,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    tx.statusDisplay,
                    style: const TextStyle(color: VeltroTheme.primaryNavy, fontSize: 11.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            const Divider(height: 1.0),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Send Amount', style: const TextStyle(fontSize: 11.0, color: VeltroTheme.textSecondary)),
                    Text(
                      CurrencyFormatter.format(tx.sendAmount, tx.sourceCurrency),
                      style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Delivered Amount', style: const TextStyle(fontSize: 11.0, color: VeltroTheme.textSecondary)),
                    Text(
                      CurrencyFormatter.format(tx.recipientAmount, tx.targetCurrency),
                      style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: VeltroTheme.accentEmerald),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Order ID: ${tx.paypalOrderId ?? 'Pending'}', style: const TextStyle(fontSize: 11.0, fontFamily: 'monospace')),
                    Text(CurrencyFormatter.formatDate(tx.createdAt), style: const TextStyle(fontSize: 11.0, color: VeltroTheme.textMuted)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: VeltroTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: VeltroTheme.borderSubtle),
      ),
      child: Column(
        children: const [
          Icon(Icons.search_off_outlined, size: 40.0, color: VeltroTheme.textMuted),
          SizedBox(height: 12.0),
          Text('No matching transactions found', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4.0),
          Text('Try searching with a different order ID or clearing active status filters.', style: TextStyle(fontSize: 13.0, color: VeltroTheme.textSecondary)),
        ],
      ),
    );
  }
}
