import 'package:flutter/material.dart';
import '../icons.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(AppIcons.back, color: Theme.of(context).colorScheme.onSurface),
      onPressed: () => Navigator.of(context).maybePop(),
    );
  }
}
