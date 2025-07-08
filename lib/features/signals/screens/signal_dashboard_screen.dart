// lib/features/signals/screens/signal_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:minvest_forex_app/core/providers/language_provider.dart';
import 'package:minvest_forex_app/features/auth/services/auth_service.dart';
import 'package:minvest_forex_app/features/signals/widgets/history_signals_view.dart';
import 'package:minvest_forex_app/features/signals/widgets/running_signals_view.dart';
import 'package:provider/provider.dart';
import 'package:minvest_forex_app/l10n/app_localizations.dart'; // Import file ngôn ngữ

class SignalDashboardScreen extends StatefulWidget {
  const SignalDashboardScreen({super.key});

  @override
  State<SignalDashboardScreen> createState() => _SignalDashboardScreenState();
}

class _SignalDashboardScreenState extends State<SignalDashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    RunningSignalsView(),
    HistorySignalsView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final authService = AuthService();
    final l10n = AppLocalizations.of(context)!; // Lấy instance của l10n

    return Scaffold(
      appBar: AppBar(
        // Cập nhật tiêu đề AppBar để dịch tự động
        title: Text(_selectedIndex == 0 ? l10n.tabRunning : l10n.tabHistory),
        actions: [
          PopupMenuButton<Locale>(
            onSelected: (Locale locale) {
              languageProvider.setLocale(locale);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              const PopupMenuItem<Locale>(value: Locale('en'), child: Text('English')),
              const PopupMenuItem<Locale>(value: Locale('vi'), child: Text('Tiếng Việt')),
            ],
            icon: const Icon(Icons.language),
            tooltip: "Change Language",
          ),
          IconButton(
            onPressed: () => authService.signOut(),
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          // Cập nhật các nhãn của tab
          BottomNavigationBarItem(
            icon: const Icon(Icons.show_chart_outlined),
            activeIcon: const Icon(Icons.show_chart),
            label: l10n.tabRunning, // Sử dụng l10n
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history_outlined),
            activeIcon: const Icon(Icons.history),
            label: l10n.tabHistory, // Sử dụng l10n
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}