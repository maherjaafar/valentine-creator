import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/invite_images.dart';

class InviteImageCard extends StatelessWidget {
  const InviteImageCard({super.key, required this.imageId, required this.revealed, this.imageUrl});

  final String imageId;
  final String? imageUrl;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final image = InviteImages.byId(imageId);
    final hasCustomImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFFFC1D0)),
          ),
          child: hasCustomImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return SvgPicture.asset(image.assetPath, fit: BoxFit.contain);
                    },
                  ),
                )
              : SvgPicture.asset(image.assetPath, fit: BoxFit.contain),
        ),
        AnimatedOpacity(
          opacity: revealed ? 0 : 1,
          duration: const Duration(milliseconds: 250),
          child: Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F6).withOpacity(0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFC1D0)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.lock_rounded, color: Color(0xFF6B1839)),
                SizedBox(height: 8),
                Text(
                  'Say YES to reveal!',
                  style: TextStyle(color: Color(0xFF6B1839), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
