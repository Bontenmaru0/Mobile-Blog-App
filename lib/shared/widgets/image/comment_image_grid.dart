import 'package:flutter/material.dart';
import 'image_gallery_page.dart';

class CommentImageGrid extends StatelessWidget {
  final List<String> images;

  const CommentImageGrid({
    super.key,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox();

    final displayImages =
        images.length > 2 ? images.take(2).toList() : images;

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
                  builder: (_) => ImageGalleryPage(
                    images: images,
                    initialIndex: index,
                  ),
                ),
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: Image.network(
                    displayImages[index],
                    fit: BoxFit.cover,
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