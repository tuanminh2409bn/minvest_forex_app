// lib/features/signals/widgets/history_signals_view.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minvest_forex_app/features/signals/models/signal_model.dart';
import 'package:minvest_forex_app/features/signals/services/signal_service.dart';
import 'package:minvest_forex_app/features/signals/widgets/signal_card.dart';

class HistorySignalsView extends StatelessWidget {
  const HistorySignalsView({super.key});

  @override
  Widget build(BuildContext context) {
    final SignalService signalService = SignalService();
    return StreamBuilder<QuerySnapshot>(
      stream: signalService.getClosedSignals(), // Gọi hàm lấy tín hiệu đã đóng
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No signal history available.'));
        }
        final signalsDocs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: signalsDocs.length,
          itemBuilder: (context, index) {
            final signal = Signal.fromFirestore(signalsDocs[index]);
            return SignalCard(signal: signal);
          },
        );
      },
    );
  }
}