import 'package:flutter/material.dart';

import '../theme.dart';

/// A prototype `.field` with a dark drop-down list (the HTML <select>).
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.optionLabel,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> options;
  final String Function(T) optionLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.label, fontSize: 12)),
          const SizedBox(height: 6),
          InputDecorator(
            decoration: appInputDecoration(),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                isDense: true,
                dropdownColor: AppColors.surface2,
                iconEnabledColor: AppColors.muted,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                items: [
                  for (final option in options)
                    DropdownMenuItem<T>(value: option, child: Text(optionLabel(option))),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
