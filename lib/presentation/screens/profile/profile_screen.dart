// Profile & Settings Screen
// Path: lib/presentation/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/veltro_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _biometricEnabled = true;
  bool _hideBalanceByDefault = false;
  bool _securityPushAlerts = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Identity Card
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: VeltroTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: VeltroTheme.borderSubtle),
                  boxShadow: VeltroTheme.cardShadow,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30.0,
                      backgroundColor: VeltroTheme.primaryNavy,
                      child: const Text(
                        'AM',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Alex Morgan',
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: VeltroTheme.primaryNavy),
                          ),
                          SizedBox(height: 2.0),
                          Text(
                            'alex.morgan@veltro.app • Verified Merchant Account',
                            style: TextStyle(fontSize: 13.0, color: VeltroTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Edit Profile'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // Connected Payment Providers
              _buildSectionHeader('Connected Payment Providers', Icons.account_balance_outlined),
              Container(
                decoration: BoxDecoration(
                  color: VeltroTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: VeltroTheme.borderSubtle),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.payment_outlined, color: VeltroTheme.primaryNavy),
                      title: const Text('PayPal Developer Sandbox', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Linked: sandbox-buyer@veltro.app (Orders v2 & Payouts v1)'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: VeltroTheme.accentEmeraldLight,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: const Text('Active Sandbox', style: TextStyle(color: VeltroTheme.primaryNavy, fontSize: 11.0, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // Security & Authentication Settings
              _buildSectionHeader('Security & Cryptographic Verification', Icons.shield_outlined),
              Container(
                decoration: BoxDecoration(
                  color: VeltroTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: VeltroTheme.borderSubtle),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.fingerprint_outlined),
                      title: const Text('Biometric Payment Authorization'),
                      subtitle: const Text('Mandatory confirmation before executing PayPal Sandbox transfers.'),
                      value: _biometricEnabled,
                      activeColor: VeltroTheme.primaryNavy,
                      onChanged: (val) => setState(() => _biometricEnabled = val),
                    ),
                    const Divider(height: 1.0),
                    SwitchListTile(
                      secondary: const Icon(Icons.visibility_off_outlined),
                      title: const Text('Mask Balances by Default'),
                      subtitle: const Text('Hides account balance figures until manually revealed.'),
                      value: _hideBalanceByDefault,
                      activeColor: VeltroTheme.primaryNavy,
                      onChanged: (val) => setState(() => _hideBalanceByDefault = val),
                    ),
                    const Divider(height: 1.0),
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_active_outlined),
                      title: const Text('Critical Security Push Warnings'),
                      subtitle: const Text('Instant alerts when Veltro Shield flags high or critical threat indicators.'),
                      value: _securityPushAlerts,
                      activeColor: VeltroTheme.primaryNavy,
                      onChanged: (val) => setState(() => _securityPushAlerts = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // App Version & Hackathon Info
              Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: Column(
                  children: const [
                    Text('Veltro Platform • Version 1.0.0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0, color: VeltroTheme.primaryNavy)),
                    SizedBox(height: 4.0),
                    Text('Built for the PayPal AI Hackathon 2026', style: TextStyle(fontSize: 12.0, color: VeltroTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 18.0, color: VeltroTheme.primaryNavy),
          const SizedBox(width: 8.0),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: VeltroTheme.primaryNavy,
            ),
          ),
        ],
      ),
    );
  }
}
