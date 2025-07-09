import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:minvest_forex_app/l10n/app_localizations.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  File? _imageFile;
  bool _isLoading = false;
  String _statusMessageKey = 'uploadPrompt';

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Hàm để hiển thị thông báo SnackBar
  void _showFeedbackSnackbar(String message, {bool isError = false}) {
    if (!mounted) return; // Kiểm tra widget còn tồn tại trên cây widget không
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
    );
  }

  // Hàm để chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _statusMessageKey = 'statusImageSelected';
      });
    }
  }

  // Hàm để tải ảnh lên Firebase Storage
  Future<void> _uploadImage() async {
    if (_imageFile == null || _currentUser == null) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
      _statusMessageKey = 'statusUploading';
    });

    try {
      final ref = _storage.ref().child('verification_images/${_currentUser!.uid}.jpg');
      await ref.putFile(_imageFile!);

      if (!mounted) return;
      setState(() {
        _statusMessageKey = 'statusUploadSuccess';
        _imageFile = null;
      });
      _showFeedbackSnackbar(l10n.statusUploadSuccess);

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessageKey = 'statusUploadFailed';
      });
      _showFeedbackSnackbar(l10n.statusUploadFailed, isError: true);
      print('Lỗi tải ảnh: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hàm để lấy chuỗi đã dịch từ key
  String _getTranslatedStatus(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'uploadPrompt':
        return l10n.uploadPrompt;
      case 'statusImageSelected':
        return l10n.statusImageSelected;
      case 'statusUploading':
        return l10n.statusUploading;
      case 'statusUploadSuccess':
        return l10n.statusUploadSuccess;
      case 'statusUploadFailed':
        return l10n.statusUploadFailed;
      default:
        return l10n.uploadPrompt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.upgradeScreenTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.compareTiers,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                _buildTableHeader([l10n.feature, l10n.tierDemo, l10n.tierVIP, l10n.tierElite]),
                _buildTableRow([l10n.balance, '< \$200', '>= \$200', '>= \$500']),
                _buildTableRow([l10n.signalTime, '8h-17h', '8h-17h', 'Fulltime']),
                _buildTableRow([l10n.signalQty, '7-8', 'Full', 'Full']),
                _buildTableRow([l10n.analysis, 'NO', 'NO', 'YES']),
                _buildTableRow([l10n.mobileWebApp, 'NO', 'YES', 'YES']),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              _getTranslatedStatus(context, _statusMessageKey),
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
              label: Text(l10n.buttonSelectScreenshot),
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
                  : Text(l10n.buttonSubmitReview, style: const TextStyle(fontSize: 16)),
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
}