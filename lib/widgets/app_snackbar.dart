import 'package:flutter/material.dart';
import '../icons.dart';
import '../theme.dart';
abstract class AppSnackbar {
  AppSnackbar._();
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, AppIcons.checkCircle);
  }
  static void showError(BuildContext context, String message) {
    _show(context, message, AppIcons.error);
  }
  static void _show(BuildContext context, String message, IconData icon) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    final controllerKey = GlobalKey<_TopNoticeState>();
    entry = OverlayEntry(
      builder: (context) => _TopNotice(
        key: controllerKey,
        icon: icon,
        message: message,
        onDismissed: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _TopNotice extends StatefulWidget {
  final IconData icon;
  final String message;
  final VoidCallback onDismissed;
  const _TopNotice({super.key, required this.icon, required this.message, required this.onDismissed});
  @override
  State<_TopNotice> createState() => _TopNoticeState();
}

class _TopNoticeState extends State<_TopNotice> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    Future.delayed(const Duration(seconds: 3), _dismiss);
  }
  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Positioned(
      top: MediaQuery.of(context).padding.top + AppSizes.sm,
      left: AppSizes.md,
      right: AppSizes.md,
      child: SlideTransition(
        position: _slide,
        child: SafeArea(
          bottom: false,
          child: Material(
            color: theme.colorScheme.surface,
            elevation: 6,
            shadowColor: Colors.black38,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              onTap: _dismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.md),
                decoration: BoxDecoration(
                  border: Border.all(color: onSurface.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, color: onSurface, size: 20),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(child: Text(widget.message, style: TextStyle(color: onSurface))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
