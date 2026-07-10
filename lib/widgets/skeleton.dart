import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme.dart';

class SkeletonShimmer extends StatelessWidget {
  final Widget child;
  const SkeletonShimmer({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkShimmerBase : AppColors.shimmerBase,
      highlightColor: isDark ? AppColors.darkShimmerHighlight : AppColors.shimmerHighlight,
      child: child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  const SkeletonBox({super.key, this.width, this.height = 14, this.borderRadius});
  const SkeletonBox.circle({super.key, required double size})
      : width = size,
        height = size,
        borderRadius = null;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkShimmerBase : AppColors.shimmerBase,
        shape: borderRadius == null && width == height ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: borderRadius == null && width == height
            ? null
            : (borderRadius ?? BorderRadius.circular(AppSizes.radiusSm)),
      ),
    );
  }
}
