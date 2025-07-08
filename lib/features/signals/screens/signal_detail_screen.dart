// lib/features/signals/screens/signal_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:minvest_forex_app/features/signals/models/signal_model.dart';

class SignalDetailScreen extends StatelessWidget {
  final Signal signal;
  const SignalDetailScreen({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${signal.type.toUpperCase()} ${signal.symbol}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDetailRow('Status', signal.status, color: signal.status == 'running' ? Colors.amber : Colors.grey),
          _buildDetailRow('Entry Price', signal.entryPrice.toString()),
          _buildDetailRow('Stop Loss', signal.stopLoss.toString()),
          _buildDetailRow('Take Profit 1', signal.takeProfits.isNotEmpty ? signal.takeProfits[0].toString() : '—'),
          _buildDetailRow('Take Profit 2', signal.takeProfits.length > 1 ? signal.takeProfits[1].toString() : '—'),
          _buildDetailRow('Take Profit 3', signal.takeProfits.length > 2 ? signal.takeProfits[2].toString() : '—'),
          if (signal.status == 'closed') ...[
            const Divider(height: 32),
            _buildDetailRow('Result', signal.result ?? 'N/A', color: Colors.blue.shade300),
            _buildDetailRow('PIPs', signal.pips?.toString() ?? 'N/A', color: (signal.pips ?? 0) >= 0 ? Colors.green : Colors.red),
          ],
          // TODO: Thêm phần "Lý do vào lệnh" cho tài khoản Ultimate
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}