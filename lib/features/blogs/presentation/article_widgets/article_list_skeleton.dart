import 'package:flutter/material.dart';
import '../../../../shared/widgets/loading/skeleton.dart';

class ArticleListSkeleton extends StatelessWidget {
  final int itemCount;

  const ArticleListSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.separated(
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(height: 18),
        itemBuilder: (context, index) => _ArticleSkeletonItem(index: index),
      ),
    );
  }
}

class _ArticleSkeletonItem extends StatelessWidget {
  final int index;

  const _ArticleSkeletonItem({required this.index});

  @override
  Widget build(BuildContext context) {
    final imageCount = index % 6; // visual estimate only (0..5)
    final contentLine1 = 210.0 + ((index % 3) * 16.0);
    final contentLine2 = 180.0 + ((index % 2) * 24.0);
    final contentLine3 = 150.0 + ((index % 3) * 14.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: SkeletonBox(height: 18)),
              SizedBox(width: 12),
              SkeletonBox(width: 18, height: 18),
            ],
          ),
          const SizedBox(height: 10),
          const SkeletonBox(height: 18, width: double.infinity),
          const SizedBox(height: 6),
          SkeletonBox(height: 12, width: contentLine1),
          const SizedBox(height: 6),
          SkeletonBox(height: 12, width: contentLine2),
          const SizedBox(height: 6),
          SkeletonBox(height: 12, width: contentLine3),
          if (imageCount > 0) ...[
            const SizedBox(height: 12),
            _ArticleImageSkeleton(imageCount: imageCount),
          ],
          const SizedBox(height: 10),
          const SkeletonBox(height: 10, width: 190),
          const SizedBox(height: 8),
          const SkeletonBox(height: 42, width: double.infinity),
        ],
      ),
    );
  }
}

class _ArticleImageSkeleton extends StatelessWidget {
  final int imageCount;

  const _ArticleImageSkeleton({required this.imageCount});

  @override
  Widget build(BuildContext context) {
    if (imageCount == 1) {
      return const SkeletonBox(height: 120, width: double.infinity);
    }
    if (imageCount == 2) {
      return const Row(
        children: [
          Expanded(child: SkeletonBox(height: 95)),
          SizedBox(width: 4),
          Expanded(child: SkeletonBox(height: 95)),
        ],
      );
    }

    return const Column(
      children: [
        Row(
          children: [
            Expanded(child: SkeletonBox(height: 95)),
            SizedBox(width: 4),
            Expanded(child: SkeletonBox(height: 95)),
          ],
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: SkeletonBox(height: 70)),
            SizedBox(width: 4),
            Expanded(child: SkeletonBox(height: 70)),
            SizedBox(width: 4),
            Expanded(child: SkeletonBox(height: 70)),
          ],
        ),
      ],
    );
  }
}
