// ══════════════════════════════════════════════════════
//  和暦変換 / 祝日計算
// ══════════════════════════════════════════════════════

class _Era {
  final String name;
  final DateTime start;
  const _Era(this.name, this.start);
}

final _eraList = [
  _Era('明治', DateTime(1868, 9, 8)),
  _Era('大正', DateTime(1912, 7, 30)),
  _Era('昭和', DateTime(1926, 12, 25)),
  _Era('平成', DateTime(1989, 1, 8)),
  _Era('令和', DateTime(2019, 5, 1)),
];

class JapaneseCalendar {
  // 和暦文字列 (例: 令和6年)
  static String toWareki(DateTime d) {
    for (int i = _eraList.length - 1; i >= 0; i--) {
      final e = _eraList[i];
      if (!d.isBefore(e.start)) {
        int y = d.year - e.start.year + 1;
        return '${e.name}${y == 1 ? "元" : y.toString()}年';
      }
    }
    return '${d.year}年';
  }

  static String toFullDate(DateTime d) =>
      '${toWareki(d)}（${d.year}年）${d.month}月${d.day}日（${_weekStr(d.weekday)}）';

  static String _weekStr(int w) =>
      ['月', '火', '水', '木', '金', '土', '日'][w - 1];
}

// ══════════════════════════════════════════════════════
//  祝日計算
// ══════════════════════════════════════════════════════
class HolidayInfo {
  final String name;
  final bool isSubstitute;
  const HolidayInfo(this.name, {this.isSubstitute = false});
}

class HolidayCalculator {
  static Map<DateTime, HolidayInfo> getHolidays(int year) {
    final h = <DateTime, HolidayInfo>{};

    void add(int m, int d, String name) {
      try {
        h[DateTime(year, m, d)] = HolidayInfo(name);
      } catch (_) {}
    }

    // 固定祝日
    add(1,  1,  '元日');
    add(2,  11, '建国記念の日');
    if (year >= 2020) add(2, 23, '天皇誕生日');
    add(4,  29, '昭和の日');
    add(5,  3,  '憲法記念日');
    add(5,  4,  'みどりの日');
    add(5,  5,  'こどもの日');
    if (year >= 2016) add(8, 11, '山の日');
    add(11, 3,  '文化の日');
    add(11, 23, '勤労感謝の日');

    // 春分の日・秋分の日
    h[DateTime(year, 3, _shunbun(year))] = const HolidayInfo('春分の日');
    h[DateTime(year, 9, _shubun(year))]  = const HolidayInfo('秋分の日');

    // 移動祝日
    h[_nth(year, 1,  DateTime.monday, 2)] = const HolidayInfo('成人の日');
    h[_nth(year, 7,  DateTime.monday, 3)] = const HolidayInfo('海の日');
    h[_nth(year, 9,  DateTime.monday, 3)] = const HolidayInfo('敬老の日');
    h[_nth(year, 10, DateTime.monday, 2)] = const HolidayInfo('スポーツの日');

    // 国民の祝日（挟まれた平日）
    _addSandwich(h, year);

    // 振替休日
    _addSubstitute(h);

    return h;
  }

  static int _shunbun(int y) =>
      (20.8431 + 0.242194 * (y - 1980) - ((y - 1980) / 4).floor()).floor();

  static int _shubun(int y) =>
      (23.2488 + 0.242194 * (y - 1980) - ((y - 1980) / 4).floor()).floor();

  static DateTime _nth(int y, int m, int weekday, int n) {
    DateTime f = DateTime(y, m, 1);
    int diff = (weekday - f.weekday + 7) % 7;
    return f.add(Duration(days: diff + (n - 1) * 7));
  }

  static void _addSandwich(Map<DateTime, HolidayInfo> h, int y) {
    for (int m = 1; m <= 12; m++) {
      for (int d = 2; d <= 29; d++) {
        final dt   = DateTime(y, m, d);
        final prev = DateTime(y, m, d - 1);
        final next = DateTime(y, m, d + 1);
        if (!h.containsKey(dt) &&
            dt.weekday != DateTime.sunday &&
            h.containsKey(prev) &&
            h.containsKey(next)) {
          h[dt] = const HolidayInfo('国民の祝日');
        }
      }
    }
  }

  static void _addSubstitute(Map<DateTime, HolidayInfo> h) {
    final copy = Map<DateTime, HolidayInfo>.from(h);
    for (final e in copy.entries) {
      if (e.key.weekday == DateTime.sunday) {
        DateTime sub = e.key.add(const Duration(days: 1));
        while (h.containsKey(sub)) {
          sub = sub.add(const Duration(days: 1));
        }
        h[sub] = HolidayInfo('振替休日（${e.value.name}）', isSubstitute: true);
      }
    }
  }

  static HolidayInfo? getHoliday(DateTime d) =>
      getHolidays(d.year)[DateTime(d.year, d.month, d.day)];
}
