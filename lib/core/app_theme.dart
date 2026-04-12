import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════
//  AppColors — ネイビー × ゴールド パレット
// ══════════════════════════════════════════════════════
class AppColors {
  // ── ベースカラー
  static const Color navy       = Color(0xFF0D1B3E);
  static const Color navyDark   = Color(0xFF070E20);
  static const Color navyMid    = Color(0xFF152040);
  static const Color navyLight  = Color(0xFF1E3270);

  // ── ゴールドカラー
  static const Color gold       = Color(0xFFD4A843);
  static const Color goldLight  = Color(0xFFEDC96A);
  static const Color goldDark   = Color(0xFFAA832A);
  static const Color goldPale   = Color(0xFFF5E8C0);

  // ── テキスト
  static const Color textPrimary   = Color(0xFFF0E8D0);
  static const Color textSecondary = Color(0xFFB8A88A);
  static const Color textDisabled  = Color(0xFF4A5A7A);

  // ── 六曜カラー
  static const Color senshoColor   = Color(0xFFE53935);
  static const Color tomobikaColor = Color(0xFF1565C0);
  static const Color senbuColor    = Color(0xFF2E7D32);
  static const Color butsumetsuColor = Color(0xFF6A1B9A);
  static const Color taianColor    = Color(0xFFD4A843);
  static const Color shakkuColor   = Color(0xFFE65100);

  // ── 曜日
  static const Color sundayColor   = Color(0xFFEF9A9A);
  static const Color saturdayColor = Color(0xFF90CAF9);
  static const Color holidayRed    = Color(0xFFEF5350);

  // ── UI
  static const Color divider    = Color(0xFF1A2F5A);
  static const Color cardBg     = Color(0xFF111D38);
  static const Color surface    = Color(0xFF0B1528);
}

// ══════════════════════════════════════════════════════
//  AppTheme
// ══════════════════════════════════════════════════════
class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary:   AppColors.gold,
        onPrimary: AppColors.navyDark,
        secondary: AppColors.goldLight,
        onSecondary: AppColors.navyDark,
        surface:   AppColors.navyMid,
        onSurface: AppColors.textPrimary,
        error:     Color(0xFFEF5350),
        onError:   Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.navy,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navyDark,
        foregroundColor: AppColors.gold,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.gold,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navyDark,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textDisabled,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 10),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.navyLight, width: 0.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.navyDark,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.gold,
        unselectedLabelColor: AppColors.textDisabled,
        indicatorColor: AppColors.gold,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.gold : AppColors.textDisabled),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.gold.withValues(alpha: 0.4)
                : AppColors.navyLight),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.navyMid,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.navyLight)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.navyLight)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.gold, width: 2)),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textDisabled),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            color: AppColors.gold, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        headlineMedium: TextStyle(
            color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(
            color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(
            color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(
            color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 15),
        bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        bodySmall: TextStyle(color: AppColors.textDisabled, fontSize: 11),
        labelLarge: TextStyle(
            color: AppColors.gold, fontSize: 12,
            fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  六曜 Enum
// ══════════════════════════════════════════════════════
enum RokuyouEnum {
  taian('大安', '万事大吉', AppColors.taianColor),
  shakku('赤口', '正午のみ吉', AppColors.shakkuColor),
  sensho('先勝', '午前中は吉', AppColors.senshoColor),
  tomobiki('友引', '友を引く', AppColors.tomobikaColor),
  senbu('先負', '午後から吉', AppColors.senbuColor),
  butsumetsu('仏滅', '万事凶', AppColors.butsumetsuColor);

  const RokuyouEnum(this.label, this.short, this.color);
  final String label;
  final String short;
  final Color color;
}
