import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  File? _imageFile;
  bool _isLoading = false;
  String _statusMessage = 'Tải lên ảnh chụp tài khoản Exness với số dư mới.';

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _statusMessage = 'Đã chọn ảnh. Nhấn "Gửi đi" để xác thực.';
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
        _statusMessage = 'Tải lên thành công! Vui lòng chờ quản trị viên xét duyệt trong vài giờ.';
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
      appBar: AppBar(title: const Text('Upgrade Account Tier')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Compare Tiers',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Table(
              border: TableBorder.all(color: Colors.grey.shade700, width: 0.5, borderRadius: BorderRadius.circular(8)),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.2),
                2: FlexColumnWidth(1.2),
                3: FlexColumnWidth(1.2),
              },
              children: [
                _buildTableHeader(['Feature', 'Demo', 'VIP', 'Elite']),
                _buildTableRow(['Balance', '< 200', '>= 200', '>= 500']),
                _buildTableRow(['Signal Time', '8h-17h', '8h-17h', 'Fulltime']),
                _buildTableRow(['Signal Qty', '7-8', 'Full', 'Full']),
                // =========== SỬA LỖI Ở ĐÂY ===========
                // Thay thế ký tự đặc biệt bằng chuỗi 'YES'/'NO'
                _buildTableRow(['Analysis', 'NO', 'NO', 'YES']),
                _buildTableRow(['Mobile & Web App', 'NO', 'YES', 'YES']),
                // ======================================
              ],
            ),
            const SizedBox(height: 40),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 16),
            if (_imageFile != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_imageFile!, height: 250, fit: BoxFit.contain),
              ),
              const SizedBox(height: 16),
            ],
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _pickImage,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Select New Screenshot'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (_imageFile == null || _isLoading) ? null : _uploadImage,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16)
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                  : const Text('Submit for Review', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableHeader(List<String> cells) => TableRow(
    decoration: BoxDecoration(color: Colors.grey.shade800),
    children: cells.map((cell) => Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(cell, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
    )).toList(),
  );

  // =========== SỬA LỖI Ở ĐÂY ===========
  // Cập nhật logic để kiểm tra chuỗi 'YES'/'NO'
  TableRow _buildTableRow(List<String> cells) => TableRow(
    children: cells.map((cell) {
      Widget child;
      if (cell == 'YES') {
        child = const Icon(Icons.check_circle, color: Colors.green, size: 20);
      } else if (cell == 'NO') {
        child = const Icon(Icons.cancel, color: Colors.red, size: 20);
      } else {
        child = Text(cell, textAlign: TextAlign.center);
      }
      return Padding(padding: const EdgeInsets.all(12.0), child: child);
    }).toList(),
  );
// ======================================
}