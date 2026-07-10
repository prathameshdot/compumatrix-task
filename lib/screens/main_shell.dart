import 'package:flutter/material.dart';
import '../icons.dart';
import '../theme.dart';
import 'add_edit_task_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tabIndex = 0;
  static const _tabs = [DashboardScreen(), ProfileScreen()];
  void _openAddTask() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddEditTaskScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: _tabs),
      bottomNavigationBar: _BottomBar(
        selectedIndex: _tabIndex,
        onSelectHome: () => setState(() => _tabIndex = 0),
        onSelectProfile: () => setState(() => _tabIndex = 1),
        onAdd: _openAddTask,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback onSelectHome;
  final VoidCallback onSelectProfile;
  final VoidCallback onAdd;
  const _BottomBar({
    required this.selectedIndex,
    required this.onSelectHome,
    required this.onSelectProfile,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: onSurface.withValues(alpha: 0.1))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: selectedIndex == 0 ? AppIcons.home : AppIcons.homeOutline,
                label: 'Home',
                selected: selectedIndex == 0,
                onTap: onSelectHome,
              ),
              _AddButton(onTap: onAdd),
              _NavItem(
                icon: AppIcons.profile,
                label: 'Profile',
                selected: selectedIndex == 1,
                onTap: onSelectProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final color = selected ? onSurface : onSurface.withValues(alpha: 0.45);
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.primary),
        child: Icon(AppIcons.add, color: colorScheme.onPrimary),
      ),
    );
  }
}
