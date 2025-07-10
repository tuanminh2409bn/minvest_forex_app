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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (authSnapshot.hasData) {
          // Người dùng đã đăng nhập, bây giờ kiểm tra quyền trong Firestore
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(authSnapshot.data!.uid).snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              // --- ĐÂY LÀ PHẦN SỬA LỖI ---
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final data = userSnapshot.data!.data() as Map<String, dynamic>?;

                // Logic mới: Kiểm tra xem "subscriptionTier" có tồn tại VÀ giá trị của nó không phải là null
                if (data != null && data['subscriptionTier'] != null) {
                  return const SignalDashboardScreen();
                }
              }

              // Nếu document chưa có, hoặc "subscriptionTier" không tồn tại hoặc là null,
              // thì hiển thị màn hình xác thực.
              return const VerificationScreen();
            },
          );
        }

        // Nếu người dùng chưa đăng nhập
        return const LoginScreen();
      },
    );
  }
}