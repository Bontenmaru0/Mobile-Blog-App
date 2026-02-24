import 'package:flutter/material.dart';
import '../../../../shared/widgets/loading/skeleton.dart';

class CommentListSkeleton extends StatelessWidget {
  final int itemCount;

  const CommentListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) => _CommentSkeletonItem(index: index),
      ),
    );
  }
}

class _CommentSkeletonItem extends StatelessWidget {
  final int index;

  const _CommentSkeletonItem({required this.index});

  @override
  Widget build(BuildContext context) {
    final hasImage = index.isEven;
    final firstLineWidth = 180.0 + ((index % 3) * 24.0);
    final secondLineWidth = 140.0 + ((index % 2) * 36.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  SkeletonBox(
                    width: 24,
                    height: 24,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  SizedBox(width: 8),
                  SkeletonBox(width: 120, height: 12),
                ],
              ),
              SkeletonBox(width: 18, height: 18),
            ],
          ),
          if (hasImage) ...[
            const SizedBox(height: 8),
            const SkeletonBox(
              height: 118,
              width: double.infinity,
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ],
          const SizedBox(height: 8),
          SkeletonBox(width: firstLineWidth, height: 12),
          const SizedBox(height: 6),
          SkeletonBox(width: secondLineWidth, height: 12),
          const SizedBox(height: 8),
          const SkeletonBox(width: 64, height: 10),
        ],
      ),
    );
  }
}
