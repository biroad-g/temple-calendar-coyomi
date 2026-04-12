// ══════════════════════════════════════════════════════
//  年齢・干支・法事・中陰 計算
// ══════════════════════════════════════════════════════

class AgeCalculator {
  // 満年齢
  static int fullAge(DateTime birth, DateTime today) {
    int age = today.year - birth.year;
    if (today.month < birth.month ||
        (today.month == birth.month && today.day < birth.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  // 数え年（生まれた時を1歳、正月に加算）
  static int countingAge(DateTime birth, DateTime today) =>
      today.year - birth.year + 1;

  // 干支（十二支）
  static String junishi(DateTime date) {
    const list = ['子','丑','寅','卯','辰','巳','午','未','申','酉','戌','亥'];
    return list[(date.year - 4) % 12];
  }

  // 十干
  static String jikkan(DateTime date) {
    const list = ['庚','辛','壬','癸','甲','乙','丙','丁','戊','己'];
    return list[(date.year - 4) % 10];
  }

  // 干支（十干十二支）
  static String eto(DateTime date) => '${jikkan(date)}${junishi(date)}';

  // 年齢早見表（還暦など）
  static String? specialAge(int fullAge) {
    const map = {
      60: '還暦（かんれき）',
      61: '華甲（かこう）',
      70: '古希（こき）',
      77: '喜寿（きじゅ）',
      80: '傘寿（さんじゅ）',
      88: '米寿（べいじゅ）',
      90: '卒寿（そつじゅ）',
      99: '白寿（はくじゅ）',
      100: '百寿（ひゃくじゅ）',
    };
    return map[fullAge];
  }
}

// ── 法事年忌 ──────────────────────────────────────────
class MemorialService {
  final String name;
  final int years; // 没後何年目
  final DateTime date;
  const MemorialService(this.name, this.years, this.date);
}

class MemorialCalculator {
  // 年忌リスト（没年を0として計算）
  static const _kiList = [
    (1,   '一周忌'),
    (2,   '三回忌'),
    (6,   '七回忌'),
    (12,  '十三回忌'),
    (16,  '十七回忌'),
    (22,  '二十三回忌'),
    (26,  '二十七回忌'),
    (32,  '三十三回忌'),
    (36,  '三十七回忌'),
    (49,  '五十回忌'),
    (99,  '百回忌'),
  ];

  /// 命日から年忌一覧を生成
  static List<MemorialService> getKiList(DateTime death) {
    return _kiList.map((e) {
      final (addYears, name) = e;
      DateTime d = DateTime(death.year + addYears, death.month, death.day);
      return MemorialService(name, addYears, d);
    }).toList();
  }

  // ── 中陰（七七日忌）計算 ─────────────────────────
  static List<MemorialService> getChuinList(DateTime death) {
    const chinList = [
      (7,  '初七日（しょなぬか）'),
      (14, '二七日（ふたなぬか）'),
      (21, '三七日（みなぬか）'),
      (28, '四七日（よなぬか）'),
      (35, '五七日（いつなぬか）'),
      (42, '六七日（むなぬか）'),
      (49, '七七日・四十九日（しじゅうくにち）'),
      (100,'百箇日（ひゃっかにち）'),
    ];
    return chinList.map((e) {
      final (days, name) = e;
      return MemorialService(name, 0, death.add(Duration(days: days - 1)));
    }).toList();
  }

  /// 月命日リスト（今後12か月分）
  static List<DateTime> getMonthlyMemorials(DateTime death, DateTime from) {
    final result = <DateTime>[];
    DateTime cur = DateTime(from.year, from.month, death.day);
    for (int i = 0; i < 12; i++) {
      if (!cur.isBefore(from)) result.add(cur);
      // 翌月同日
      int nextYear  = cur.month == 12 ? cur.year + 1 : cur.year;
      int nextMonth = cur.month == 12 ? 1 : cur.month + 1;
      cur = DateTime(nextYear, nextMonth, death.day);
    }
    return result;
  }

  // 命日から何回忌かを計算
  static String? getKiName(DateTime death, int year) {
    int diff = year - death.year;
    for (final (addYears, name) in _kiList) {
      if (addYears == diff) return name;
    }
    return null;
  }
}
