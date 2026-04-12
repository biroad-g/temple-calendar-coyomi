import 'dart:math' as math;
import 'app_theme.dart';

// ══════════════════════════════════════════════════════
//  Chapront 式天文算法による六曜計算
// ══════════════════════════════════════════════════════
class RokuyouCalculator {
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
                   + 0.00001238 * T3 - 0.000000058 * T4);
    double F  = _r(160.7108    + 390.67050284 * k - 0.0016118 * T2
                   - 0.00000227 * T3 + 0.000000011 * T4);
    double Om = _r(124.7746    -  1.56375588  * k + 0.0020672 * T2
                   + 0.00000215 * T3);

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

  // ── グレゴリオ暦日 → 旧暦(月, 日) ────────────────
  static (int lunarMonth, int lunarDay) toLunar(int year, int month, int day) {
    double jd   = gregorianToJD(year, month, day);
    double kEst = (jd - 2451550.09766) / 29.530588861;

    // 直前の新月を探す
    double prevNM = 0;
    for (int dk = -3; dk <= 1; dk++) {
      double nm = _newMoonJDE((kEst.floor() + dk).toDouble()).floorToDouble();
      if (nm <= jd && nm > prevNM) prevNM = nm;
    }
    if (prevNM == 0) prevNM = _newMoonJDE(kEst.floor().toDouble()).floorToDouble();

    int lunarDay = (jd - prevNM + 1).toInt().clamp(1, 30);

    // 旧暦月：参照新月(k=0: 2000年1月6日≒旧暦11月)から月数を数える
    int monthCount = ((prevNM - 2451550.0) / 29.530588861).round();
    int lunarMonth = ((monthCount + 10) % 12) + 1;

    return (lunarMonth, lunarDay);
  }

  // ── 六曜インデックス 0=大安 1=赤口 2=先勝 3=友引 4=先負 5=仏滅
  static int rokuyouIndex(int year, int month, int day) {
    final (lm, ld) = toLunar(year, month, day);
    return (lm + ld) % 6;
  }

  static RokuyouEnum rokuyou(int year, int month, int day) {
    return RokuyouEnum.values[rokuyouIndex(year, month, day)];
  }
}
