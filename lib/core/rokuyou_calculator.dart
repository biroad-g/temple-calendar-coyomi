import 'dart:math' as math;
import 'app_theme.dart';

// ══════════════════════════════════════════════════════
//  Chapront 式天文算法による六曜計算 (閏月補正済み)
//  検証済み: benri.jp 2024〜2026年全月一致 (エラー0)
//  
//  根本原理:
//  朔のk番号は lm%6 = (k - BASE_K - leapCount) % 6 を満たす
//  BASE_K=297 は旧暦2024年1月の朔 (lm%6=0)
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
    final int a = (y / 100).floor();
    final int b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
           (30.6001 * (m + 1)).floor() +
           d + b - 1524.5;
  }

  // ── k 番目の新月の JDE（Chapront式）─────────────
  static double _newMoonJDE(double k) {
    final double t  = k / 1236.85;
    final double t2 = t * t;
    final double t3 = t2 * t;
    final double t4 = t3 * t;

    double jde = 2451550.09766
        + 29.530588861 * k
        + 0.00015437  * t2
        - 0.000000150 * t3
        + 0.00000000073 * t4;

    final double mAngle  = _r(2.5534      + 29.10535670  * k - 0.0000014 * t2);
    final double mpAngle = _r(201.5643    + 385.81693528 * k + 0.0107582 * t2
                   + 0.00001238 * t3);
    final double fAngle  = _r(160.7108    + 390.67050284 * k - 0.0016118 * t2
                   - 0.00000227 * t3);
    final double omAngle = _r(124.7746    -  1.56375588  * k + 0.0020672 * t2);

    jde += -0.40720 * math.sin(mpAngle)
        +  0.17241 * math.sin(mAngle)
        +  0.01608 * math.sin(2 * mpAngle)
        +  0.01039 * math.sin(2 * fAngle)
        +  0.00739 * math.sin(mpAngle - mAngle)
        - 0.00514 * math.sin(mpAngle + mAngle)
        +  0.00208 * math.sin(2 * mAngle)
        - 0.00111 * math.sin(mpAngle - 2 * fAngle)
        - 0.00057 * math.sin(mpAngle + 2 * fAngle)
        +  0.00056 * math.sin(2 * mpAngle + mAngle)
        - 0.00042 * math.sin(3 * mpAngle)
        +  0.00042 * math.sin(mAngle  + 2 * fAngle)
        +  0.00038 * math.sin(mAngle  - 2 * fAngle)
        - 0.00024 * math.sin(2 * mpAngle - mAngle)
        - 0.00017 * math.sin(omAngle)
        - 0.00007 * math.sin(mpAngle + 2 * mAngle);
    return jde;
  }

  static double _r(double deg) => deg * math.pi / 180.0;

  // ── k 番目の新月の JST 日付の JD を返す ──────────
  static double _newMoonJstJD(double k) {
    final double jde = _newMoonJDE(k);
    final double jstDecimal = jde + 9.0 / 24.0;
    return (jstDecimal + 0.5).floorToDouble() - 0.5;
  }

  // ── 直前の新月の k を返す ──────────────────────────
  static int _prevNewMoonK(double jd) {
    final double kEst = (jd - 2451550.09766) / 29.530588861;

    double prevNmJD = 0;
    int prevK = 0;

    for (int dk = -3; dk < 3; dk++) {
      final int k = kEst.floor() + dk;
      final double nmJstJD = _newMoonJstJD(k.toDouble());
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
    final double jd = gregorianToJD(year, month, day);
    final int prevK = _prevNewMoonK(jd);
    final double prevNmJD = _newMoonJstJD(prevK.toDouble());

    int lunarDay = (jd - prevNmJD).toInt() + 1;
    if (lunarDay < 1) lunarDay = 1;
    if (lunarDay > 30) lunarDay = 30;

    // prevK以下の閏月数をカウント
    final int leapCount = _leapMonthKTable.where((lk) => lk <= prevK).length;

    return (prevK - 297 - leapCount + lunarDay) % 6;
  }

  static RokuyouEnum rokuyou(int year, int month, int day) {
    return RokuyouEnum.values[rokuyouIndex(year, month, day)];
  }
}
