import 'package:flutter/material.dart';

import '../models/item.dart';
import '../theme.dart';
import '../utils/format.dart';
import 'item_photo.dart';

/// The prototype's product card: photo with a heart, name, price, category and condition, university.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.item,
    required this.isSaved,
    required this.onOpen,
    required this.onToggleSaved,
  });

  final Item item;
  final bool isSaved;
  final VoidCallback onOpen;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ItemPhoto(item: item, height: 125, emojiSize: 53),
                Positioned(
                  right: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: onToggleSaved,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.heartBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.heartLine),
                      ),
                      child: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    cash(item.price),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.price),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${item.category.name} · ${item.conditionLabel}',
                    style: const TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '📍 ${item.sellerCampus}',
                    style: const TextStyle(fontSize: 10, color: AppColors.muted),
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
