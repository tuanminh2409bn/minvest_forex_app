// lib/features/signals/widgets/running_signals_view.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minvest_forex_app/features/signals/models/signal_model.dart';
import 'package:minvest_forex_app/features/signals/services/signal_service.dart';
import 'package:minvest_forex_app/features/signals/widgets/signal_card.dart';

class RunningSignalsView extends StatelessWidget {
  const RunningSignalsView({super.key});

  @override
  Widget build(BuildContext context) {
    final SignalService signalService = SignalService();
    return StreamBuilder<QuerySnapshot>(
      stream: signalService.getRunningSignals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No running signals available.'));
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