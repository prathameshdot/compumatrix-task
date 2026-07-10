import 'package:flutter/material.dart';

import '../theme.dart';
import 'skeleton.dart';

class TaskListSkeleton extends StatelessWidget {
  final int itemCount;
  const TaskListSkeleton({super.key, this.itemCount = 6});
  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.xxl),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: AppSizes.sm),
        itemBuilder: (context, _) => const _TaskCardSkeleton(),
      ),
    );
  }
}

class _TaskCardSkeleton extends StatelessWidget {
  const _TaskCardSkeleton();
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2, right: AppSizes.sm),
              child: SkeletonBox.circle(size: AppSizes.iconMd),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(height: 15, width: 160),
                  const SizedBox(height: AppSizes.xs),
                  const SkeletonBox(height: 12, width: 220),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      SkeletonBox(height: 20, width: 64, borderRadius: BorderRadius.circular(AppSizes.radiusPill)),
                      const SizedBox(width: AppSizes.sm),
                      const SkeletonBox(height: 12, width: 80),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
