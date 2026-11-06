import 'package:flutter/material.dart';

import '../models/item.dart';
import '../services/api_client.dart';
import '../theme.dart';

/// The grey photo box of the prototype. Shows the uploaded photo when there is one,
/// otherwise the category emoji, like the prototype does.
class ItemPhoto extends StatelessWidget {
  const ItemPhoto({super.key, required this.item, required this.height, required this.emojiSize});

  final Item item;
  final double height;
  final double emojiSize;

  @override
  Widget build(BuildContext context) {
    final emoji = Center(child: Text(item.category.icon, style: TextStyle(fontSize: emojiSize)));
    final url = ApiClient.imageUrl(item.imageUrl);
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.photoA, AppColors.photoB],
        ),
      ),
      child: url == null
          ? emoji
          : Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: height,
              errorBuilder: (context, error, stackTrace) => emoji,
            ),
    );
  }
}
