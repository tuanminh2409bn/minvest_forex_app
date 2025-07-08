import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minvest_forex_app/features/auth/screens/login_screen.dart';
import 'package:minvest_forex_app/features/signals/screens/signal_dashboard_screen.dart';
import 'package:minvest_forex_app/features/auth/services/auth_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return const SignalDashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}