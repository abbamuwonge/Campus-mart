import 'package:flutter/material.dart';

/// Colours copied from the prototype's CSS variables.
class AppColors {
  static bool isDark = true;

  static Color get bg =>
      isDark ? const Color(0xFF101115) : const Color(0xFFF6F7F9);
  static Color get surface => isDark ? const Color(0xFF191B21) : Colors.white;
  static Color get surface2 =>
      isDark ? const Color(0xFF22252D) : const Color(0xFFEFF1F4);
  static Color get line =>
      isDark ? const Color(0xFF30333D) : const Color(0xFFD9DDE4);
  static Color get text =>
      isDark ? const Color(0xFFF5F5F7) : const Color(0xFF17191D);
  static Color get muted =>
      isDark ? const Color(0xFFA1A5AF) : const Color(0xFF626975);
  static const orange = Color(0xFFFF7A24);
  static const orange2 = Color(0xFFFF9A50);

  static Color get inputBg =>
      isDark ? const Color(0xFF111318) : const Color(0xFFF3F4F6);
  static Color get hint =>
      isDark ? const Color(0xFF7B7F8A) : const Color(0xFF858C98);
  static Color get label =>
      isDark ? const Color(0xFFB9BDC5) : const Color(0xFF59616D);
  static const btnText = Color(0xFF171717);
  static const price = Color(0xFFFF9955);

  static Color get headerBg =>
      isDark ? const Color(0xF2111216) : const Color(0xF2FFFFFF);
  static Color get headerLine =>
      isDark ? const Color(0xFF292C33) : const Color(0xFFE1E4E9);
  static Color get navBg =>
      isDark ? const Color(0xF5191B21) : const Color(0xF2FFFFFF);
  static Color get navInactive =>
      isDark ? const Color(0xFF999EAA) : const Color(0xFF737B87);

  static Color get chipText =>
      isDark ? const Color(0xFFC9CBD1) : const Color(0xFF505762);
  static Color get chipActiveBg =>
      isDark ? const Color(0xFF4A2A19) : const Color(0xFFFFE7D8);
  static Color get chipActiveLine =>
      isDark ? const Color(0xFF9A5124) : const Color(0xFFFFA16B);
  static Color get chipActiveText =>
      isDark ? const Color(0xFFFFB17C) : const Color(0xFFC74F0A);

  static Color get badgeBg =>
      isDark ? const Color(0xFF49351E) : const Color(0xFFFFE9BD);
  static Color get badgeText =>
      isDark ? const Color(0xFFFFD18B) : const Color(0xFF8A5A00);

  static Color get bannerA =>
      isDark ? const Color(0xFF553019) : const Color(0xFFFFE5D5);
  static Color get bannerB =>
      isDark ? const Color(0xFF2B201B) : const Color(0xFFFFF7F1);
  static Color get bannerLine =>
      isDark ? const Color(0xFF704021) : const Color(0xFFFFB98D);
  static Color get bannerText =>
      isDark ? const Color(0xFFE2CFC2) : const Color(0xFF75452B);

  static Color get photoA =>
      isDark ? const Color(0xFF292D36) : const Color(0xFFE8EBF0);
  static Color get photoB =>
      isDark ? const Color(0xFF1C1F25) : const Color(0xFFF7F8FA);
  static const heartBg = Color(0xBB111111);
  static const heartLine = Color(0x88555555);

  static Color get bubble =>
      isDark ? const Color(0xFF292D36) : const Color(0xFFE8EBF0);
  static Color get bubbleMine =>
      isDark ? const Color(0xFF63381F) : const Color(0xFFFFDCC8);

  static Color get toastBg =>
      isDark ? const Color(0xFF292D35) : const Color(0xFF20242B);
  static const toastLine = Color(0xFF555B65);

  static Color get avatarBg =>
      isDark ? const Color(0xFF55321F) : const Color(0xFFFFE0CB);
  static Color get avatarText =>
      isDark ? const Color(0xFFFFC08E) : const Color(0xFFC75B1D);

  static void setDarkMode(bool value) => isDark = value;
}

ThemeData buildTheme({required bool dark}) {
  AppColors.setDarkMode(dark);
  final base = dark
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme(
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: AppColors.orange,
      onPrimary: AppColors.btnText,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      error: Colors.red,
      onError: Colors.white,
      onSecondary: Colors.white,
      secondary: AppColors.orange2,
      onSurfaceVariant: AppColors.muted,
      outline: AppColors.line,
      shadow: Colors.black,
      scrim: Colors.black,
    ),
    textTheme: base.textTheme
        .apply(bodyColor: AppColors.text, displayColor: AppColors.text),
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
    hintStyle: TextStyle(color: AppColors.hint),
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
