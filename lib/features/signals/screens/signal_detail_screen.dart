// lib/features/signals/screens/signal_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:minvest_forex_app/features/signals/models/signal_model.dart';
import 'package:minvest_forex_app/core/providers/user_provider.dart';
import 'package:provider/provider.dart';

class SignalDetailScreen extends StatelessWidget {
  final Signal signal;
  const SignalDetailScreen({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar( /* ... */ ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDetailRow('Status', signal.status, color: signal.status == 'running' ? Colors.amber : Colors.grey),
          _buildDetailRow('Entry Price', signal.entryPrice.toString()),
          _buildDetailRow('Stop Loss', signal.stopLoss.toString()),
          _buildDetailRow('Take Profit 1', signal.takeProfits.isNotEmpty ? signal.takeProfits[0].toString() : '—'),
          _buildDetailRow('Take Profit 2', signal.takeProfits.length > 1 ? signal.takeProfits[1].toString() : '—'),
          _buildDetailRow('Take Profit 3', signal.takeProfits.length > 2 ? signal.takeProfits[2].toString() : '—'),
          if (userProvider.userTier == 'elite' && signal.reason != null && signal.reason!.isNotEmpty) ...[
            const Divider(height: 32),
            Text(
              'Analysis & Reason',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber.shade300),
            ),
            const SizedBox(height: 8),
            Text(
              signal.reason!,
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey.shade300),
            ),
          ]
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