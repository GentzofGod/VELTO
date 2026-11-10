// Responsive Navigation Shell for Mobile and Desktop
// Path: lib/presentation/widgets/veltro_navigation_shell.dart

import 'package:flutter/material.dart';
import '../../core/theme/veltro_theme.dart';
import '../screens/home/home_screen.dart';
import '../screens/payments/payments_screen.dart';
import '../screens/shield/shield_screen.dart';
import '../screens/wisepilot/wisepilot_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/transactions/transactions_screen.dart';
import '../screens/notifications/notifications_screen.dart';

class VeltroNavigationShell extends StatefulWidget {
  const VeltroNavigationShell({super.key});

  @override
  State<VeltroNavigationShell> createState() => _VeltroNavigationShellState();
}

class _VeltroNavigationShellState extends State<VeltroNavigationShell> {
  int _currentIndex = 0;
  bool _sidebarExpanded = true;

  final List<Widget> _screens = const [
    HomeScreen(),
    PaymentsScreen(),
    ShieldScreen(),
    WisePilotScreen(),
    ProfileScreen(),
  ];

  void _navigateToIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  void _openTransactions() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TransactionsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Collapsible Sidebar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _sidebarExpanded ? 240.0 : 72.0,
              decoration: const BoxDecoration(
                color: VeltroTheme.surfaceWhite,
                border: Border(
                  right: BorderSide(color: VeltroTheme.borderSubtle, width: 1.0),
                ),
              ),
              child: Column(
                children: [
                  // Brand Header
                  Container(
                    height: 64.0,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          color: VeltroTheme.primaryNavy,
                          size: 28.0,
                        ),
                        if (_sidebarExpanded) ...[
                          const SizedBox(width: 12.0),
                          const Text(
                            'Veltro',
                            style: TextStyle(
                              color: VeltroTheme.primaryNavy,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(height: 1.0),

                  // Nav Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      children: [
                        _buildDesktopNavItem(0, 'Home', Icons.home_outlined),
                        _buildDesktopNavItem(1, 'Payments', Icons.send_outlined),
                        _buildDesktopNavItem(2, 'Veltro Shield', Icons.shield_outlined),
                        _buildDesktopNavItem(3, 'WisePilot AI', Icons.psychology_outlined),
                        _buildDesktopNavItem(4, 'Profile & Settings', Icons.person_outline),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Divider(),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _openTransactions,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.receipt_long_outlined, size: 20.0, color: VeltroTheme.textSecondary),
                                  if (_sidebarExpanded) ...[
                                    const SizedBox(width: 12.0),
                                    const Text('Transactions', style: TextStyle(fontSize: 13.0, color: VeltroTheme.textPrimary)),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _openNotifications,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.notifications_outlined, size: 20.0, color: VeltroTheme.textSecondary),
                                  if (_sidebarExpanded) ...[
                                    const SizedBox(width: 12.0),
                                    const Text('Notifications', style: TextStyle(fontSize: 13.0, color: VeltroTheme.textPrimary)),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sidebar Toggle Button
                  IconButton(
                    icon: Icon(_sidebarExpanded ? Icons.chevron_left : Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _sidebarExpanded = !_sidebarExpanded;
                      });
                    },
                  ),
                  const SizedBox(height: 12.0),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(_getTitleForIndex(_currentIndex)),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.receipt_long_outlined),
                      tooltip: 'Transaction Centre',
                      onPressed: _openTransactions,
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      tooltip: 'Notifications',
                      onPressed: _openNotifications,
                    ),
                    const SizedBox(width: 12.0),
                  ],
                ),
                body: _screens[_currentIndex],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile Viewport with Fixed Bottom Navigation Bar
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: VeltroTheme.primaryNavy, size: 24.0),
            const SizedBox(width: 8.0),
            Text(_getTitleForIndex(_currentIndex)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Transactions',
            onPressed: _openTransactions,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: _openNotifications,
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateToIndex,
        backgroundColor: VeltroTheme.surfaceWhite,
        indicatorColor: VeltroTheme.accentEmeraldLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: VeltroTheme.primaryNavy),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.send_outlined),
            selectedIcon: Icon(Icons.send, color: VeltroTheme.primaryNavy),
            label: 'Payments',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield, color: VeltroTheme.primaryNavy),
            label: 'Shield',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology, color: VeltroTheme.primaryNavy),
            label: 'WisePilot',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: VeltroTheme.primaryNavy),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNavItem(int index, String label, IconData icon) {
    final isSelected = _currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
      child: Material(
        color: isSelected ? VeltroTheme.accentEmeraldLight : Colors.transparent,
        borderRadius: BorderRadius.circular(10.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(10.0),
          onTap: () => _navigateToIndex(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20.0,
                  color: isSelected ? VeltroTheme.primaryNavy : VeltroTheme.textSecondary,
                ),
                if (_sidebarExpanded) ...[
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? VeltroTheme.primaryNavy : VeltroTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTitleForIndex(int index) {
    return switch (index) {
      0 => 'Home',
      1 => 'Global Payments',
      2 => 'Veltro Shield',
      3 => 'WisePilot Assistant',
      4 => 'Profile & Settings',
      _ => 'Veltro',
    };
  }
}
