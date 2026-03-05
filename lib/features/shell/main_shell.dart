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
    _NavItem(icon: Icons.dashboard_rounded,      activeIcon: Icons.dashboard,        label: 'Inicio'),
    _NavItem(icon: Icons.sports_soccer_outlined, activeIcon: Icons.sports_soccer,    label: 'Partidos'),
    _NavItem(icon: Icons.bar_chart_outlined,     activeIcon: Icons.bar_chart_rounded, label: 'Stats'),
    _NavItem(icon: Icons.emoji_events_outlined,  activeIcon: Icons.emoji_events,     label: 'Torneos'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,   label: 'Perfil'),
  ];

  void _onDestinationSelected(int index) {
    if (_currentIndex == index) return; // evita rebuild innecesario
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
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
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
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          animationDuration: const Duration(milliseconds: 300),
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          onDestinationSelected: _onDestinationSelected,
          destinations: _navItems.asMap().entries.map((entry) {
            final i = entry.key;
            final n = entry.value;
            final isSelected = _currentIndex == i;
            return NavigationDestination(
              icon: Icon(n.icon, size: 22, color: const Color(0xFF00f5ff)),
              selectedIcon: Icon(n.activeIcon, size: 24, color: const Color(0xFF00f5ff)),
              label: n.label,
              tooltip: isSelected ? '' : n.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
