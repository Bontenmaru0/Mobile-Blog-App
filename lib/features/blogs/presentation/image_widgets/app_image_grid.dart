import 'package:flutter/material.dart';

class AppImageGrid extends StatelessWidget {
  final List<String> images;
  final Function(String imageUrl, int index)? onImageTap;

  const AppImageGrid({
    super.key,
    required this.images,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (onImageTap != null) {
              onImageTap!(images[index], index);
            }
          },
          child: Image.network(
            images[index],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}