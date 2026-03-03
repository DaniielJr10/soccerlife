import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../dashboard/presentation/pages/dashboard_page.dart';
import '../matches/presentation/pages/matches_page.dart';
import '../statistics/presentation/pages/statistics_page.dart';
import '../tournaments/presentation/pages/tournaments_page.dart';
import '../profile/presentation/pages/profile_page.dart';

/// Shell principal de la aplicación con navegación inferior y
/// transiciones animadas entre pestañas.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    MatchesPage(),
    StatisticsPage(),
    TournamentsPage(),
    ProfilePage(),
  ];

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard_rounded,       label: 'Dashboard'),
    _NavItem(icon: Icons.sports_soccer_rounded,   label: 'Partidos'),
    _NavItem(icon: Icons.bar_chart_rounded,       label: 'Estadísticas'),
    _NavItem(icon: Icons.emoji_events_rounded,    label: 'Torneos'),
    _NavItem(icon: Icons.person_rounded,          label: 'Perfil'),
  ];

  void _onDestinationSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages.asMap().entries.map((entry) {
          final i = entry.key;
          final page = entry.value;
          return AnimatedOpacity(
            opacity: _currentIndex == i ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: page,
          );
        }).toList(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: Colors.transparent,
        indicatorColor: const Color(0xFF00f5ff).withValues(alpha: 0.15),
        animationDuration: const Duration(milliseconds: 300),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 10,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active ? const Color(0xFF00f5ff) : const Color(0xFF00f5ff).withValues(alpha: 0.5),
          );
        }),
        onDestinationSelected: _onDestinationSelected,
        destinations: _navItems.map((n) => NavigationDestination(
            icon: Icon(n.icon, size: 22, color: const Color(0xFF00f5ff)),
            selectedIcon: Icon(n.icon, size: 25, color: const Color(0xFF00f5ff)),
            label: n.label,
          )).toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
