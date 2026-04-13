import 'dart:math' as math;
import 'app_theme.dart';

// ══════════════════════════════════════════════════════
//  Chapront 式天文算法による六曜計算 (閏月補正済み)
//  検証済み: benri.jp 2025年・2026年全月一致
//  
//  根本原理:
//  朔のk番号は lm%6 = (k - BASE_K - leapCount) % 6 を満たす
//  BASE_K=297 は旧暦2024年1月1日の朔 (lm%6=0 = 旧暦12月の次)
//  leapCount は prevK以下の閏月の数
//  
//  六曜index = (prevK - 297 - leapCount + lunarDay) % 6
//  0=大安, 1=赤口, 2=先勝, 3=友引, 4=先負, 5=仏滅
// ══════════════════════════════════════════════════════
class RokuyouCalculator {
  // ── 既知の閏月 k 番号テーブル (2020〜2030年) ──────
  // k=316: 2025年閏6月 (2025/07/25)
  static const List<int> _leapMonthKTable = [
    316, // 2025年 閏6月
    // 次の閏月: 2028年閏5月頃 (要調査・追加)
  ];

  // ── グレゴリオ暦 → ユリウス日 ─────────────────────
  static double gregorianToJD(int y, int m, int d) {
    if (m <= 2) { y--; m += 12; }
    int a = (y / 100).floor();
    int b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
           (30.6001 * (m + 1)).floor() +
           d + b - 1524.5;
  }

  // ── k 番目の新月の JDE（Chapront式）─────────────
  static double _newMoonJDE(double k) {
    double T  = k / 1236.85;
    double T2 = T * T;
    double T3 = T2 * T;
    double T4 = T3 * T;

    double jde = 2451550.09766
        + 29.530588861 * k
        + 0.00015437  * T2
        - 0.000000150 * T3
        + 0.00000000073 * T4;

    double M  = _r(2.5534      + 29.10535670  * k - 0.0000014 * T2);
    double Mp = _r(201.5643    + 385.81693528 * k + 0.0107582 * T2
                   + 0.00001238 * T3);
    double F  = _r(160.7108    + 390.67050284 * k - 0.0016118 * T2
                   - 0.00000227 * T3);
    double Om = _r(124.7746    -  1.56375588  * k + 0.0020672 * T2);

    jde += -0.40720 * math.sin(Mp)
        +  0.17241 * math.sin(M)
        +  0.01608 * math.sin(2 * Mp)
        +  0.01039 * math.sin(2 * F)
        +  0.00739 * math.sin(Mp - M)
        - 0.00514 * math.sin(Mp + M)
        +  0.00208 * math.sin(2 * M)
        - 0.00111 * math.sin(Mp - 2 * F)
        - 0.00057 * math.sin(Mp + 2 * F)
        +  0.00056 * math.sin(2 * Mp + M)
        - 0.00042 * math.sin(3 * Mp)
        +  0.00042 * math.sin(M  + 2 * F)
        +  0.00038 * math.sin(M  - 2 * F)
        - 0.00024 * math.sin(2 * Mp - M)
        - 0.00017 * math.sin(Om)
        - 0.00007 * math.sin(Mp + 2 * M);
    return jde;
  }

  static double _r(double deg) => deg * math.pi / 180.0;

  // ── k 番目の新月の JST 日付の JD を返す ──────────
  static double _newMoonJstJD(double k) {
    double jde = _newMoonJDE(k);
    double jstDecimal = jde + 9.0 / 24.0;
    return (jstDecimal + 0.5).floorToDouble() - 0.5;
  }

  // ── 直前の新月の k を返す ──────────────────────────
  static int _prevNewMoonK(double jd) {
    double kEst = (jd - 2451550.09766) / 29.530588861;

    double prevNmJD = 0;
    int prevK = 0;

    for (int dk = -3; dk < 3; dk++) {
      int k = kEst.floor() + dk;
      double nmJstJD = _newMoonJstJD(k.toDouble());
      if (nmJstJD <= jd) {
        if (prevNmJD == 0 || nmJstJD > prevNmJD) {
          prevNmJD = nmJstJD;
          prevK = k;
        }
      }
    }

    if (prevNmJD == 0) {
      prevK = kEst.floor();
    }
    return prevK;
  }

  // ── 六曜インデックス (閏月補正済み) ──────────────
  // 計算式: (prevK - 297 - leapCount + lunarDay) % 6
  // 0=大安, 1=赤口, 2=先勝, 3=友引, 4=先負, 5=仏滅
  //
  // 原理: 朔番号kは旧暦月番号lmと
  //   lm%6 = (k - 297 - leapCount) % 6 の関係を持つ
  //   六曜 = (lm + lunarDay) % 6 = ((k-297-leapCount) + lunarDay) % 6
  static int rokuyouIndex(int year, int month, int day) {
    double jd = gregorianToJD(year, month, day);
    int prevK = _prevNewMoonK(jd);
    double prevNmJD = _newMoonJstJD(prevK.toDouble());

    int lunarDay = (jd - prevNmJD).toInt() + 1;
    if (lunarDay < 1) lunarDay = 1;
    if (lunarDay > 30) lunarDay = 30;

    // prevK以下の閏月数をカウント
    int leapCount = _leapMonthKTable.where((lk) => lk <= prevK).length;

    return (prevK - 297 - leapCount + lunarDay) % 6;
  }

  static RokuyouEnum rokuyou(int year, int month, int day) {
    return RokuyouEnum.values[rokuyouIndex(year, month, day)];
  }
}
