import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool filled;
  final Color? color;
  const AppLogo({super.key, this.size = 64, this.filled = true, this.color});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = color ?? (isDark ? AppColors.white : AppColors.black);
    final onInk = ink == AppColors.white ? AppColors.black : AppColors.white;
    final letter = Text(
      'T',
      style: GoogleFonts.poppins(
        fontSize: size * 0.56,
        fontWeight: FontWeight.w800,
        height: 1,
        color: filled ? onInk : ink,
      ),
    );
    if (!filled) return letter;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ink,
        borderRadius: BorderRadius.circular(size * (AppSizes.radiusLg / 64)),
      ),
      child: letter,
    );
  }
}
