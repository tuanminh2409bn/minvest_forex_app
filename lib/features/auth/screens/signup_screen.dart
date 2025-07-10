import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minvest_forex_app/features/auth/services/auth_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    // Ẩn bàn phím nếu đang mở
    FocusScope.of(context).unfocus();

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final displayName = _usernameController.text.trim();

    // Kiểm tra xem các trường có rỗng không
    if (email.isEmpty || password.isEmpty || displayName.isEmpty) {
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final User? user = await _authService.signUpWithEmailAndPassword(
      email,
      password,
      displayName,
    );

    // Kiểm tra widget còn tồn tại không
    if (!mounted) return;

    // Nếu đăng ký thành công
    if (user != null) {
      // Đóng màn hình đăng ký để quay lại màn hình trước đó
      // AuthGate sẽ tự động phát hiện trạng thái đăng nhập mới và điều hướng
      Navigator.of(context).pop();
    } else {
      // Hiển thị thông báo lỗi đăng ký thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign up failed. The email might already be in use.')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white,))
                    : const Text('Sign Up', style: TextStyle(fontSize: 16)),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('OR', style: TextStyle(color: Colors.grey.shade400)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
              ),

              // Nút Đăng nhập Apple (chỉ hiển thị trên iOS)
              if (Platform.isIOS)
                SignInWithAppleButton(
                  onPressed: () {
                    if (_isLoading) return;
                    AuthService().signInWithApple();
                  },
                  style: SignInWithAppleButtonStyle.black,
                  borderRadius: BorderRadius.circular(12),
                  height: 50,
                ),
            ],
          ),
        ),
      ),
    );
  }
}