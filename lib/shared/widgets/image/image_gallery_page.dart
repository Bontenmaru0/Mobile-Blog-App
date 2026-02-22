import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../../features/comments/presentation/comment_widgets/comment_panel.dart';
import '../../../core/enums/comment_context_type.dart';

class ImageGalleryPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String? articleId; // Pass articleId for fetching comments
  final String? imageId; // Pass imageId for fetching comments

  const ImageGalleryPage({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.articleId,
    this.imageId,
  });

  @override
  State<ImageGalleryPage> createState() => _ImageGalleryPageState();
}

class _ImageGalleryPageState extends State<ImageGalleryPage> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// Photo gallery
          PhotoViewGallery.builder(
            itemCount: widget.images.length,
            pageController: _pageController,
            onPageChanged: (index) => setState(() => currentIndex = index),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.images[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
          ),

          /// Top left badge
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: const Text(
                "Modern Samurai",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          /// Top right close button
          Positioned(
            top: 40.5,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),

          /// Bottom center comment/chat icon
          if (widget.articleId != null && widget.imageId != null)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.zero),
                      ),
                      builder: (context) {
                        return DraggableScrollableSheet(
                          expand: false,
                          initialChildSize: 0.85,
                          minChildSize: 0.25,
                          maxChildSize: 0.95,
                          builder: (context, scrollController) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 5,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Photo Comments',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Expanded(
                                    child: CommentPanel(
                                      articleId: widget.articleId!,
                                      imageId: widget.imageId!,
                                      type: CommentContextType.comment,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  child: const CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 25,
                    child: Icon(Icons.chat_bubble_outline, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
