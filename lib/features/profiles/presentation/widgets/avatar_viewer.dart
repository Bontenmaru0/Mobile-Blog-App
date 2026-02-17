import 'package:flutter/material.dart';

class AvatarViewer extends StatelessWidget {
  final String? imageUrl;
  final String fullName;
  final String nickname;
  final String fallbackLetter;

  const AvatarViewer({
    super.key,
    required this.imageUrl,
    required this.fullName,
    required this.nickname,
    required this.fallbackLetter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// CENTER IMAGE
          Center(
            child: Hero(
              tag: "profileAvatar",
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? InteractiveViewer(
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.contain,
                      ),
                    )
                  : CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.grey.shade800,
                      child: Text(
                        fallbackLetter,
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),

          // CLOSE BUTTON (TOP RIGHT)
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

          // BADGE (TOP LEFT)
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
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

          // NAME + TAG (BOTTOM LEFT)
          Positioned(
            bottom: 40,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nickname,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
