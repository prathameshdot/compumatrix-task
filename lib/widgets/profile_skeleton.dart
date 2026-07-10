import 'package:flutter/material.dart';
import '../theme.dart';
import 'skeleton.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Center(
            child: Column(
              children: [
                const SkeletonBox.circle(size: 72),
                const SizedBox(height: AppSizes.sm),
                const SkeletonBox(height: 16, width: 140),
                const SizedBox(height: AppSizes.xs),
                const SkeletonBox(height: 12, width: 180),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          const SkeletonBox(height: 12, width: 90),
          const SizedBox(height: AppSizes.sm),
          SkeletonBox(height: AppSizes.buttonHeight, borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
          const SizedBox(height: AppSizes.lg),
          const SkeletonBox(height: 12, width: 160),
          const SizedBox(height: AppSizes.md),
          const SkeletonBox(height: 48, width: double.infinity),
          const SizedBox(height: AppSizes.sm),
          const SkeletonBox(height: 48, width: double.infinity),
        ],
      ),
    );
  }
}
