import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/rokuyou_calculator.dart';
import '../core/japanese_calendar.dart';
import '../providers/app_provider.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Column(
        children: [
          _MonthHeader(),
          _WeekdayRow(),
          Expanded(child: _CalendarGrid()),
          _DayDetailPanel(),
        ],
      ),
    );
  }
}

// ── 月ナビゲーションヘッダー ─────────────────────────
class _MonthHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final d = p.focusedMonth;
    final wareki = JapaneseCalendar.toWareki(d);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navyDark,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        children: [
          // ── 上段：年移動 ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 前年ボタン
              IconButton(
                icon: const Icon(Icons.keyboard_double_arrow_left,
                    color: AppColors.gold, size: 22),
                tooltip: '前年',
                onPressed: p.prevYear,
              ),
              // 年タップ → 年選択ダイアログ
              GestureDetector(
                onTap: () => _showYearPicker(context, p),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.navyMid,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${d.year}年',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down,
                          color: AppColors.gold, size: 20),
                    ],
                  ),
                ),
              ),
              // 翌年ボタン
              IconButton(
                icon: const Icon(Icons.keyboard_double_arrow_right,
                    color: AppColors.gold, size: 22),
                tooltip: '翌年',
                onPressed: p.nextYear,
              ),
              // 今日ボタン
              IconButton(
                icon: const Icon(Icons.today, color: AppColors.gold, size: 22),
                tooltip: '今日',
                onPressed: p.goToToday,
              ),
            ],
          ),
          // ── 下段：月移動 ──────────────────────────────
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left,
                    color: AppColors.gold, size: 28),
                onPressed: p.prevMonth,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${d.month}月',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      wareki,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right,
                    color: AppColors.gold, size: 28),
                onPressed: p.nextMonth,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 年選択ダイアログ
  void _showYearPicker(BuildContext context, AppProvider p) {
    final currentYear = p.focusedMonth.year;
    final today = DateTime.now().year;
    // 表示範囲: 現在年 -10 〜 +10
    final years =
        List.generate(21, (i) => today - 10 + i);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navyDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '年を選択',
          style: TextStyle(color: AppColors.gold, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
        content: SizedBox(
          width: 220,
          height: 320,
          child: ListView.builder(
            itemCount: years.length,
            itemBuilder: (_, i) {
              final y = years[i];
              final isSelected = y == currentYear;
              final isToday = y == today;
              final w = JapaneseCalendar.seirekiToWareki(y);
              final warekiStr =
                  w != null ? '${w.era}${w.year == 1 ? "元" : w.year.toString()}年' : '';
              return InkWell(
                onTap: () {
                  p.goToYear(y);
                  Navigator.of(ctx).pop();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 3),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.gold.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(color: AppColors.gold, width: 1.5)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$y年',
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.gold
                                    : AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (warekiStr.isNotEmpty)
                              Text(
                                warekiStr,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isToday)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '今年',
                            style: TextStyle(
                                color: AppColors.gold, fontSize: 10),
                          ),
                        ),
                      if (isSelected)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(Icons.check,
                              color: AppColors.gold, size: 16),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('キャンセル',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

// ── 曜日ヘッダー ─────────────────────────────────────
class _WeekdayRow extends StatelessWidget {
  static const _days = ['日', '月', '火', '水', '木', '金', '土'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navyDark,
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: List.generate(7, (i) {
          Color c = i == 0
              ? AppColors.sundayColor
              : i == 6
                  ? AppColors.saturdayColor
                  : AppColors.textSecondary;
          return Expanded(
            child: Center(
              child: Text(
                _days[i],
                style: TextStyle(
                  color: c,
                  fontSize: 14,   // ← 大きく
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── カレンダーグリッド ───────────────────────────────
class _CalendarGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final today = DateTime.now();
    final firstDay = DateTime(p.focusedMonth.year, p.focusedMonth.month, 1);
    final daysInMonth = DateTime(firstDay.year, firstDay.month + 1, 0).day;
    // DateTime.weekday: 1=月〜6=土, 7=日 → %7 で 日=0, 月=1, ..., 土=6
    final startWeekday = firstDay.weekday % 7; // 日曜=0
    final holidays = HolidayCalculator.getHolidays(firstDay.year);
    final showRokuyou = p.showRokuyou;

    final cells = <_DayCell>[];
    for (int i = 0; i < startWeekday; i++) {
      cells.add(const _DayCell(day: 0, weekIndex: 0));
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(firstDay.year, firstDay.month, d);
      final weekIndex = (startWeekday + d - 1) % 7;
      final holiday = holidays[DateTime(firstDay.year, firstDay.month, d)];
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isSelected = p.selectedDate != null &&
          p.selectedDate!.year == date.year &&
          p.selectedDate!.month == date.month &&
          p.selectedDate!.day == date.day;

      // 六曜: 全体ON & 個別ON の場合のみ表示
      RokuyouEnum? roku;
      if (showRokuyou) {
        final r = RokuyouCalculator.rokuyou(date.year, date.month, date.day);
        if (p.isRokuyouVisible(r)) roku = r;
      }

      cells.add(_DayCell(
        day: d,
        weekIndex: weekIndex,
        date: date,
        holiday: holiday,
        isToday: isToday,
        isSelected: isSelected,
        rokuyou: roku,
      ));
    }
    while (cells.length % 7 != 0) {
      cells.add(const _DayCell(day: 0, weekIndex: 0));
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.72,  // 少し縦長にして文字スペース確保
      ),
      itemCount: cells.length,
      itemBuilder: (_, i) {
        final cell = cells[i];
        if (cell.day == 0) return const SizedBox();
        return GestureDetector(
          onTap: () => context.read<AppProvider>().setSelectedDate(cell.date),
          child: _DayCellWidget(cell: cell),
        );
      },
    );
  }
}

class _DayCell {
  final int day;
  final int weekIndex;
  final DateTime? date;
  final HolidayInfo? holiday;
  final bool isToday;
  final bool isSelected;
  final RokuyouEnum? rokuyou;

  const _DayCell({
    required this.day,
    required this.weekIndex,
    this.date,
    this.holiday,
    this.isToday = false,
    this.isSelected = false,
    this.rokuyou,
  });
}

class _DayCellWidget extends StatelessWidget {
  final _DayCell cell;
  const _DayCellWidget({super.key, required this.cell});

  @override
  Widget build(BuildContext context) {
    Color textColor;
    if (cell.holiday != null || cell.weekIndex == 0) {
      textColor = AppColors.sundayColor;
    } else if (cell.weekIndex == 6) {
      textColor = AppColors.saturdayColor;
    } else {
      textColor = AppColors.textPrimary;
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: cell.isSelected
            ? AppColors.navyLight
            : cell.isToday
                ? AppColors.gold.withValues(alpha: 0.15)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: cell.isToday
            ? Border.all(color: AppColors.gold, width: 1.5)
            : cell.isSelected
                ? Border.all(color: AppColors.goldLight, width: 1)
                : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 日付数字 ← 大きく
          Text(
            '${cell.day}',
            style: TextStyle(
              color: cell.isToday ? AppColors.goldLight : textColor,
              fontSize: 18,           // 15 → 18
              fontWeight: cell.isToday ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          // 六曜 ← 大きく
          if (cell.rokuyou != null)
            Text(
              cell.rokuyou!.label,
              style: TextStyle(
                color: cell.rokuyou!.color,
                fontSize: 11,         // 9 → 11
                fontWeight: FontWeight.bold,
              ),
            ),
          // 祝日ドット
          if (cell.holiday != null)
            Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(top: 1),
              decoration: const BoxDecoration(
                color: AppColors.holidayRed,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

// ── 日付詳細パネル ───────────────────────────────────
class _DayDetailPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final date = p.selectedDate ?? DateTime.now();
    final holiday = HolidayCalculator.getHoliday(date);
    final roku = RokuyouCalculator.rokuyou(date.year, date.month, date.day);
    final wareki = JapaneseCalendar.toWareki(date);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${date.month}月${date.day}日',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 24,   // ← 大きく
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      wareki,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // 六曜バッジ（詳細パネルは常に全種表示）
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: roku.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: roku.color, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      roku.label,
                      style: TextStyle(
                        color: roku.color,
                        fontSize: 18,   // ← 大きく
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      roku.short,
                      style: TextStyle(color: roku.color, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (holiday != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.holidayRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: AppColors.holidayRed.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flag, color: AppColors.holidayRed, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    holiday.name,
                    style: const TextStyle(
                      color: AppColors.holidayRed,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
