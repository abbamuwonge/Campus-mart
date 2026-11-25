import 'package:flutter/material.dart';

import '../models/category.dart';
import '../theme.dart';

/// The prototype's row of category chips ("All" first), scrolling sideways.
class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key, required this.categories, required this.selectedId, required this.onSelected});

  final List<Category> categories;
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(top: 1, bottom: 13),
      child: Row(
        children: [
          _Chip(label: 'All', active: selectedId == null, onTap: () => onSelected(null)),
          for (final c in categories) ...[
            const SizedBox(width: 8),
            _Chip(label: c.name, active: selectedId == c.id, onTap: () => onSelected(c.id)),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.chipActiveBg : AppColors.surface,
          border: Border.all(color: active ? AppColors.chipActiveLine : AppColors.line),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, color: active ? AppColors.chipActiveText : AppColors.chipText),
        ),
      ),
    );
  }
}
