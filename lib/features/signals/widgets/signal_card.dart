// lib/features/signals/widgets/signal_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minvest_forex_app/features/signals/models/signal_model.dart';
import 'package:minvest_forex_app/features/signals/screens/signal_detail_screen.dart';
import 'package:minvest_forex_app/l10n/app_localizations.dart';

class SignalCard extends StatelessWidget {
  final Signal signal;

  const SignalCard({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isBuy = signal.type.toLowerCase() == 'buy';
    final Color signalColor = isBuy ? Colors.green.shade400 : Colors.red.shade400;
    final String translatedType = isBuy ? l10n.signalTypeBuy : l10n.signalTypeSell;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: signalColor.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SignalDetailScreen(signal: signal),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Hàng đầu tiên: Symbol, Type và Thời gian ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        signal.symbol,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: signalColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          translatedType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    DateFormat('HH:mm dd/MM').format(signal.createdAt.toDate()),
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
              const Divider(height: 24),
              // --- Hàng thứ hai: Entry và Stop Loss ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoColumn(l10n.entry, signal.entryPrice.toString()),
                  _buildInfoColumn(l10n.stopLoss, signal.stopLoss.toString()),
                ],
              ),
              const SizedBox(height: 16),
              // --- Hàng thứ ba: Các mức Take Profit ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoColumn(l10n.takeProfit1, signal.takeProfits.isNotEmpty ? signal.takeProfits[0].toString() : '—', color: Colors.blue.shade300),
                  _buildInfoColumn(l10n.takeProfit2, signal.takeProfits.length > 1 ? signal.takeProfits[1].toString() : '—', color: Colors.blue.shade300),
                  _buildInfoColumn(l10n.takeProfit3, signal.takeProfits.length > 2 ? signal.takeProfits[2].toString() : '—', color: Colors.blue.shade300),
                ],
              ),

              // =========== THÊM MỚI Ở ĐÂY ===========
              const Divider(height: 24, thickness: 0.1),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    l10n.viewDetails,
                    style: TextStyle(
                      color: Colors.blue.shade400,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.blue.shade400,
                  ),
                ],
              ),
              // ======================================
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}