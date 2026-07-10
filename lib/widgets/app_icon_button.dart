import 'package:flutter/material.dart';
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;
  final double size;
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 44,
  });
  @override
  Widget build(BuildContext context) {
    final cardTheme = Theme.of(context).cardTheme;
    final button = SizedBox(
      width: size,
      height: size,
      child: Material(
        color: cardTheme.color,
        shape: cardTheme.shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 20),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}
