// lib/features/signals/screens/signal_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:minvest_forex_app/core/providers/language_provider.dart';
import 'package:minvest_forex_app/features/auth/services/auth_service.dart';
import 'package:minvest_forex_app/features/signals/widgets/history_signals_view.dart';
import 'package:minvest_forex_app/features/signals/widgets/running_signals_view.dart';
import 'package:provider/provider.dart';
import 'package:minvest_forex_app/l10n/app_localizations.dart';
import 'package:minvest_forex_app/features/auth/screens/profile_screen.dart';

class SignalDashboardScreen extends StatefulWidget {
  const SignalDashboardScreen({super.key});

  @override
  State<SignalDashboardScreen> createState() => _SignalDashboardScreenState();
}

class _SignalDashboardScreenState extends State<SignalDashboardScreen> {
  // Biến để lưu chỉ số của tab đang được chọn (0: Running, 1: History, 2: Profile)
  int _selectedIndex = 0;

  // Danh sách các widget tương ứng với mỗi tab
  static const List<Widget> _pages = <Widget>[
    RunningSignalsView(), // Giao diện cho tab "Running"
    HistorySignalsView(), // Giao diện cho tab "History"
    ProfileScreen(),      // Giao diện cho tab "Profile"
  ];

  // Hàm được gọi khi người dùng nhấn vào một tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lấy các provider và service cần thiết
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final authService = AuthService();
    final l10n = AppLocalizations.of(context)!;

    // Danh sách các tiêu đề cho AppBar
    final List<String> _appBarTitles = [
      l10n.tabRunning,
      l10n.tabHistory,
      l10n.profile
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        actions: [
          PopupMenuButton<Locale>(
            onSelected: (Locale locale) {
              languageProvider.setLocale(locale);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              const PopupMenuItem<Locale>(
                value: Locale('en'),
                child: Text('English'),
              ),
              const PopupMenuItem<Locale>(
                value: Locale('vi'),
                child: Text('Tiếng Việt'),
              ),
            ],
            icon: const Icon(Icons.language),
            tooltip: "Change Language",
          ),
          // Nút Đăng xuất (chỉ hiển thị ở tab Profile)
          if (_selectedIndex == 2)
            IconButton(
              onPressed: () => authService.signOut(),
              icon: const Icon(Icons.logout),
              tooltip: "Logout",
            ),
        ],
      ),
      // Hiển thị widget tương ứng với tab được chọn
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.show_chart_outlined),
            activeIcon: const Icon(Icons.show_chart),
            label: l10n.tabRunning,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history_outlined),
            activeIcon: const Icon(Icons.history),
            label: l10n.tabHistory,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: l10n.profile, // Dùng l10n
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Gọi hàm khi một tab được nhấn
        type: BottomNavigationBarType.fixed, // Giúp các item hiển thị đúng khi có > 3
      ),
    );
  }
}