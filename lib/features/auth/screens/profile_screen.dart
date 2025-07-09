// lib/features/auth/screens/profile_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minvest_forex_app/core/providers/user_provider.dart';
import 'package:minvest_forex_app/features/verification/screens/upgrade_screen.dart';
import 'package:provider/provider.dart';
import 'package:minvest_forex_app/features/auth/services/auth_service.dart';
import 'package:minvest_forex_app/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userProvider = Provider.of<UserProvider>(context);
    final l10n = AppLocalizations.of(context)!; // Lấy instance l10n

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
                  const SizedBox(height: 16),
                  Text(user?.email ?? 'No email', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      userProvider.userTier?.toUpperCase() ?? 'DEMO',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.blueGrey,
                  ),
                ],
              ),
            ),
            const Divider(height: 40),
            Text(l10n.upgradeAccount, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.upgrade),
              title: Text(l10n.upgradeAccount), // Dùng l10n
              subtitle: Text(l10n.upgradeAccountSubtitle), // Dùng l10n
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UpgradeScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}