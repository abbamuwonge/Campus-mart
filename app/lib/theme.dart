import 'package:flutter/material.dart';

/// Colours copied from the prototype's CSS variables.
class AppColors {
  static const bg = Color(0xFF101115);
  static const surface = Color(0xFF191B21);
  static const surface2 = Color(0xFF22252D);
  static const line = Color(0xFF30333D);
  static const text = Color(0xFFF5F5F7);
  static const muted = Color(0xFFA1A5AF);
  static const orange = Color(0xFFFF7A24);
  static const orange2 = Color(0xFFFF9A50);

  static const inputBg = Color(0xFF111318);
  static const hint = Color(0xFF7B7F8A);
  static const label = Color(0xFFB9BDC5);
  static const btnText = Color(0xFF171717);
  static const price = Color(0xFFFF9955);

  static const headerBg = Color(0xF2111216);
  static const headerLine = Color(0xFF292C33);
  static const navBg = Color(0xF5191B21);
  static const navInactive = Color(0xFF999EAA);

  static const chipText = Color(0xFFC9CBD1);
  static const chipActiveBg = Color(0xFF4A2A19);
  static const chipActiveLine = Color(0xFF9A5124);
  static const chipActiveText = Color(0xFFFFB17C);

  static const badgeBg = Color(0xFF49351E);
  static const badgeText = Color(0xFFFFD18B);

  static const bannerA = Color(0xFF553019);
  static const bannerB = Color(0xFF2B201B);
  static const bannerLine = Color(0xFF704021);
  static const bannerText = Color(0xFFE2CFC2);

  static const photoA = Color(0xFF292D36);
  static const photoB = Color(0xFF1C1F25);
  static const heartBg = Color(0xBB111111);
  static const heartLine = Color(0x88555555);

  static const bubble = Color(0xFF292D36);
  static const bubbleMine = Color(0xFF63381F);

  static const toastBg = Color(0xFF292D35);
  static const toastLine = Color(0xFF555B65);

  static const avatarBg = Color(0xFF55321F);
  static const avatarText = Color(0xFFFFC08E);
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.orange,
      onPrimary: AppColors.btnText,
      surface: AppColors.surface,
      onSurface: AppColors.text,
    ),
    textTheme: base.textTheme.apply(bodyColor: AppColors.text, displayColor: AppColors.text),
  );
}

/// The prototype's input look: dark fill, thin border, orange border when focused.
InputDecoration appInputDecoration({String? hint}) {
  OutlineInputBorder border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: color),
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.hint),
    isDense: true,
    filled: true,
    fillColor: AppColors.inputBg,
    contentPadding: const EdgeInsets.all(12),
    border: border(AppColors.line),
    enabledBorder: border(AppColors.line),
    disabledBorder: border(AppColors.line),
    focusedBorder: border(AppColors.orange),
  );
}
