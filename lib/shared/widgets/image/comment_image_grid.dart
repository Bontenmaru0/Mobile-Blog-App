import 'package:flutter/material.dart';
import 'image_gallery_page.dart';
import '../loading/skeleton.dart';

class CommentImageGrid extends StatelessWidget {
  final List<String> images;

  const CommentImageGrid({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox();

    final displayImages = images.length > 2 ? images.take(2).toList() : images;

    final extraCount = images.length - 2;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayImages.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final isLast = index == 1 && images.length > 2;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ImageGalleryPage(images: images, initialIndex: index),
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const SkeletonShimmer(
                        child: SkeletonBox(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      Image.network(
                        displayImages[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox.shrink();
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFE0E0E0),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              color: Colors.black54,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // +X overlay
                if (isLast)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Center(
                      child: Text(
                        '+$extraCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
