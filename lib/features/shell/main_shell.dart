import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../dashboard/presentation/pages/dashboard_page.dart';
import '../matches/presentation/pages/matches_page.dart';
import '../statistics/presentation/pages/statistics_page.dart';
import '../profile/presentation/pages/profile_page.dart';

/// Shell principal de la aplicación con navegación inferior.
/// Usa [IndexedStack] para conservar el estado de cada pestaña.
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
    ProfilePage(),
  ];

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.sports_soccer_rounded, label: 'Partidos'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Estadísticas'),
    _NavItem(icon: Icons.person_rounded, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
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
      ),
      child: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? AppColors.primary : AppColors.textSecondary,
          );
        }),
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: _navItems
            .map((n) => NavigationDestination(icon: Icon(n.icon), label: n.label))
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
