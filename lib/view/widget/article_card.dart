import 'package:flutter/material.dart';
import 'package:healthbot_app/utils/text_styles.dart';

class ArticleCard extends StatelessWidget {
  final String logo;
  final String publisher;
  final String title;
  final String image;
  final String time;
  final String description;
  final Function()? onTap;

  const ArticleCard({
    super.key,
    required this.logo,
    required this.publisher,
    required this.title,
    required this.image,
    required this.time,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE3E9F3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.asset(
                image,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Failed to load image: $image, error: $error');
                  return Container(
                    width: double.infinity,
                    height: 120,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (frame == null) {
                    return Container(
                      width: double.infinity,
                      height: 120,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  return child;
                },
              ),
            ),
            // Article content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Publisher info
                  Row(
                    children: [
                      Image.asset(
                        logo,
                        width: 20,
                        height: 20,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          publisher,
                          style: AppTextStyles.interRegular12.copyWith(
                            color: const Color(0xFF797C7B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: AppTextStyles.interRegular12.copyWith(
                          color: const Color(0xFF797C7B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Article title
                  Text(
                    title,
                    style: AppTextStyles.interBold18,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Article description
                  Text(
                    description,
                    style: AppTextStyles.interRegular14.copyWith(
                      color: const Color(0xFF797C7B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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