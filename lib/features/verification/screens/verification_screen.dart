// lib/features/verification/screens/verification_screen.dart
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:minvest_forex_app/features/auth/services/auth_service.dart'; // Thêm import

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  File? _imageFile;
  bool _isLoading = false;
  String _statusMessage = 'Vui lòng tải lên ảnh chụp màn hình tài khoản Exness của bạn để được phân quyền.';

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null || _currentUser == null) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang tải ảnh lên, vui lòng chờ...';
    });

    try {
      final ref = _storage.ref().child('verification_images/${_currentUser!.uid}.jpg');
      await ref.putFile(_imageFile!);

      setState(() {
        _statusMessage = 'Tải lên thành công! Vui lòng chờ...';
        _imageFile = null;
      });

    } catch (e) {
      setState(() {
        _statusMessage = 'Tải lên thất bại. Vui lòng thử lại.';
      });
      print('Lỗi tải ảnh: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác Thực Tài Khoản'),
        automaticallyImplyLeading: false, // Ẩn nút back
        // =========== THÊM MỚI Ở ĐÂY ===========
        actions: [
          IconButton(
            onPressed: () => AuthService().signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
        // ======================================
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.amber),
            const SizedBox(height: 24),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            if (_imageFile != null) ...[
              Image.file(_imageFile!, height: 200),
              const SizedBox(height: 16),
            ],
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('Chọn ảnh từ thư viện'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (_imageFile == null || _isLoading) ? null : _uploadImage,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16)
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Gửi Đi', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}