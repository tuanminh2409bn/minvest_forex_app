// lib/app/auth_gate.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minvest_forex_app/features/auth/screens/login_screen.dart';
import 'package:minvest_forex_app/features/signals/screens/signal_dashboard_screen.dart';
import 'package:minvest_forex_app/features/verification/screens/verification_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (authSnapshot.hasData) {
          // Người dùng đã đăng nhập, bây giờ kiểm tra quyền trong Firestore
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(authSnapshot.data!.uid).snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              // Nếu document user chưa tồn tại hoặc không có quyền
              if (!userSnapshot.hasData || !userSnapshot.data!.exists || userSnapshot.data!.get('subscriptionTier') == null) {
                return const VerificationScreen(); // Chuyển đến màn hình xác thực
              }
              // Nếu đã có quyền, vào màn hình chính
              return const SignalDashboardScreen();
            },
          );
        }

        // Nếu người dùng chưa đăng nhập
        return const LoginScreen();
      },
    );
  }
}