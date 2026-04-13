import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════
//  AppColors — 和紙（Washi Paper）パレット
//  ベース: 和紙クリーム × 墨黒 × 朱色 × 金箔
// ══════════════════════════════════════════════════════
class AppColors {
  // ── ベースカラー（和紙・木目）
  static const Color washi       = Color(0xFFF7F0E6);  // 和紙クリーム
  static const Color washiDark   = Color(0xFFEDE4D4);  // 少し暗い和紙
  static const Color washiDeep   = Color(0xFFE0D5C0);  // 深い和紙（ヘッダー）
  static const Color woodBrown   = Color(0xFF6D4C28);  // 木目ブラウン

  // ── 旧カラー名（後方互換用エイリアス）
  static const Color navy        = washi;
  static const Color navyDark    = washiDeep;
  static const Color navyMid     = washiDark;
  static const Color navyLight   = Color(0xFFCFC3A8);  // ボーダー用

  // ── 墨・テキスト
  static const Color sumi        = Color(0xFF1C1C1C);  // 墨黒
  static const Color sumiMid     = Color(0xFF4A3F35);  // 中間墨
  static const Color sumiLight   = Color(0xFF7A6A58);  // 薄墨

  static const Color textPrimary   = sumi;
  static const Color textSecondary = sumiMid;
  static const Color textDisabled  = Color(0xFFAA9A88);

  // ── 朱・金（アクセント）
  static const Color vermillion  = Color(0xFFC62828);  // 朱色（メインアクセント）
  static const Color vermillionLight = Color(0xFFEF5350); // 薄朱
  static const Color gold        = Color(0xFFC9A84C);  // 金箔
  static const Color goldLight   = Color(0xFFE8C97A);  // 薄金
  static const Color goldDark    = Color(0xFFA07830);  // 濃金
  static const Color goldPale    = Color(0xFFF5E8C0);  // 金淡

  // ── 六曜カラー（和の色）
  static const Color senshoColor    = Color(0xFFB71C1C);  // 深紅（先勝）
  static const Color tomobikaColor  = Color(0xFF1565C0);  // 藍（友引）
  static const Color senbuColor     = Color(0xFF2E7031);  // 深緑（先負）
  static const Color butsumetsuColor= Color(0xFF5D4037);  // 焦茶（仏滅）
  static const Color taianColor     = Color(0xFFC9A84C);  // 金（大安）
  static const Color shakkuColor    = Color(0xFFE65100);  // 橙朱（赤口）

  // ── 曜日
  static const Color sundayColor    = Color(0xFFC62828);  // 朱
  static const Color saturdayColor  = Color(0xFF1565C0);  // 藍
  static const Color holidayRed     = Color(0xFFC62828);  // 朱

  // ── UI
  static const Color divider     = Color(0xFFCFC3A8);
  static const Color cardBg      = Color(0xFFFBF6EE);  // カードは白和紙
  static const Color surface     = Color(0xFFF0E8D8);
}

// ══════════════════════════════════════════════════════
//  AppTheme — 和紙テーマ
// ══════════════════════════════════════════════════════
class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary:     AppColors.vermillion,
        onPrimary:   Colors.white,
        secondary:   AppColors.gold,
        onSecondary: AppColors.sumi,
        surface:     AppColors.washi,
        onSurface:   AppColors.sumi,
        error:       AppColors.vermillion,
        onError:     Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.washi,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.washiDeep,
        foregroundColor: AppColors.sumi,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.sumi,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
        iconTheme: IconThemeData(color: AppColors.vermillion),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.washiDeep,
        selectedItemColor: AppColors.vermillion,
        unselectedItemColor: AppColors.sumiLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 10),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 2,
        shadowColor: AppColors.sumiLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.divider, width: 0.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vermillion,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          elevation: 2,
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.vermillion,
        unselectedLabelColor: AppColors.sumiLight,
        indicatorColor: AppColors.vermillion,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        dividerColor: AppColors.divider,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.vermillion : AppColors.textDisabled),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.vermillion.withValues(alpha: 0.35)
                : AppColors.divider),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.vermillion, width: 2)),
        labelStyle: const TextStyle(color: AppColors.sumiMid),
        hintStyle: const TextStyle(color: AppColors.textDisabled),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            color: AppColors.sumi, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        headlineMedium: TextStyle(
            color: AppColors.sumi, fontSize: 20, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(
            color: AppColors.sumi, fontSize: 17, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(
            color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(
            color: AppColors.sumi, fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.sumi, fontSize: 15),
        bodyMedium: TextStyle(color: AppColors.sumiMid, fontSize: 13),
        bodySmall: TextStyle(color: AppColors.sumiLight, fontSize: 11),
        labelLarge: TextStyle(
            color: AppColors.vermillion, fontSize: 12,
            fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
//  六曜 Enum  ※ (旧暦月+旧暦日)%6 のインデックスと一致させる
//  正しいマッピング: 0=大安 1=赤口 2=先勝 3=友引 4=先負 5=仏滅
//  検証済み: benri.jp 2025年1月・4月全日一致
// ══════════════════════════════════════════════════════
enum RokuyouEnum {
  taian    ('大安', '万事大吉',   AppColors.taianColor),
  shakku   ('赤口', '正午のみ吉', AppColors.shakkuColor),
  sensho   ('先勝', '午前中は吉', AppColors.senshoColor),
  tomobiki ('友引', '友を引く',   AppColors.tomobikaColor),
  senbu    ('先負', '午後から吉', AppColors.senbuColor),
  butsumetsu('仏滅', '万事凶',   AppColors.butsumetsuColor);

  const RokuyouEnum(this.label, this.short, this.color);
  final String label;
  final String short;
  final Color color;
}
