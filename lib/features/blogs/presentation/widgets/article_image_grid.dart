import 'package:flutter/material.dart';

class ArticleImageGrid extends StatelessWidget {
  final List<String> images;
  final Function(String imageUrl, int index)? onImageClick;

  const ArticleImageGrid({
    super.key,
    required this.images,
    this.onImageClick,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox();

    const maxShow = 5;
    final displayImages = images.take(maxShow).toList();
    final extraCount = images.length - maxShow;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          /// TOP ROW (first 2)
          Row(
            children: List.generate(
              displayImages.take(2).length,
              (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _ImageBox(
                      imageUrl: displayImages[index],
                      index: index,
                      extraCount: index == 1 ? extraCount : 0,
                      onTap: onImageClick,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 4),

          /// BOTTOM ROW (next 3)
          Row(
            children: List.generate(
              displayImages.skip(2).length,
              (i) {
                final index = i + 2;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _ImageBox(
                      imageUrl: displayImages[index],
                      index: index,
                      onTap: onImageClick,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class _ImageBox extends StatelessWidget {
  final String imageUrl;
  final int index;
  final Function(String, int)? onTap;
  final int extraCount;

  const _ImageBox({
    required this.imageUrl,
    required this.index,
    this.onTap,
    this.extraCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null
          ? () => onTap!(imageUrl, index)
          : null,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),

            /// +X overlay
            if (extraCount > 0)
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: Text(
                    "+$extraCount",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
