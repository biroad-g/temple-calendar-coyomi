import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/age_memorial_calculator.dart';
import '../core/japanese_calendar.dart';
import '../providers/app_provider.dart';

class MemorialScreen extends StatefulWidget {
  const MemorialScreen({super.key});
  @override
  State<MemorialScreen> createState() => _MemorialScreenState();
}

class _MemorialScreenState extends State<MemorialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _yearCtrl  = TextEditingController();
  final _monthCtrl = TextEditingController();
  final _dayCtrl   = TextEditingController();
  DateTime? _death;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final p = context.read<AppProvider>();
    if (p.deathDate != null && _death == null) {
      _death = p.deathDate;
      _yearCtrl.text  = _death!.year.toString();
      _monthCtrl.text = _death!.month.toString();
      _dayCtrl.text   = _death!.day.toString();
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    _yearCtrl.dispose();
    _monthCtrl.dispose();
    _dayCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    try {
      final d = DateTime(
        int.parse(_yearCtrl.text.trim()),
        int.parse(_monthCtrl.text.trim()),
        int.parse(_dayCtrl.text.trim()),
      );
      setState(() => _death = d);
      context.read<AppProvider>().setDeathDate(d);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正しい日付を入力してください')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('法事計算'),
        backgroundColor: AppColors.navyDark,
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: '年忌'),
            Tab(text: '中陰'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 命日入力
          _DeathDateInput(
            yearCtrl: _yearCtrl,
            monthCtrl: _monthCtrl,
            dayCtrl: _dayCtrl,
            onCalculate: _calculate,
            death: _death,
          ),
          // タブビュー
          Expanded(
            child: _death == null
                ? const Center(
                    child: Text('命日を入力して計算してください',
                        style: TextStyle(color: AppColors.textSecondary)),
                  )
                : TabBarView(
                    controller: _tab,
                    children: [
                      _KiListTab(death: _death!),
                      _ChuinTab(death: _death!),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ── 命日入力コンポーネント ─────────────────────────────
class _DeathDateInput extends StatelessWidget {
  final TextEditingController yearCtrl, monthCtrl, dayCtrl;
  final VoidCallback onCalculate;
  final DateTime? death;

  const _DeathDateInput({
    required this.yearCtrl,
    required this.monthCtrl,
    required this.dayCtrl,
    required this.onCalculate,
    this.death,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navyDark,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('命日',
              style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _numField(yearCtrl, '年', width: 80),
              const SizedBox(width: 6),
              _numField(monthCtrl, '月', width: 52),
              const SizedBox(width: 6),
              _numField(dayCtrl, '日', width: 52),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onCalculate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: const Text('計算'),
              ),
              if (death != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    JapaneseCalendar.toWareki(death!),
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _numField(TextEditingController c, String label, {double width = 70}) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        ),
      ),
    );
  }
}

// ── 年忌タブ ─────────────────────────────────────────
class _KiListTab extends StatelessWidget {
  final DateTime death;
  const _KiListTab({required this.death});

  @override
  Widget build(BuildContext context) {
    final list = MemorialCalculator.getKiList(death);
    final today = DateTime.now();
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final item = list[i];
        final isPast = item.date.isBefore(today);
        final isThisYear = item.date.year == today.year;
        return _MemorialTile(
          label: item.name,
          date: item.date,
          isPast: isPast,
          isHighlight: isThisYear,
          subText: JapaneseCalendar.toWareki(item.date),
        );
      },
    );
  }
}

// ── 中陰タブ ─────────────────────────────────────────
class _ChuinTab extends StatelessWidget {
  final DateTime death;
  const _ChuinTab({required this.death});

  @override
  Widget build(BuildContext context) {
    final list = MemorialCalculator.getChuinList(death);
    final today = DateTime.now();
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final item = list[i];
        final isPast = item.date.isBefore(today);
        final isToday = item.date.year == today.year &&
            item.date.month == today.month &&
            item.date.day == today.day;
        return _MemorialTile(
          label: item.name,
          date: item.date,
          isPast: isPast,
          isHighlight: isToday,
          subText: JapaneseCalendar.toFullDate(item.date),
        );
      },
    );
  }
}

// ── 共通タイルウィジェット ────────────────────────────
class _MemorialTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool isPast;
  final bool isHighlight;
  final String subText;

  const _MemorialTile({
    required this.label,
    required this.date,
    required this.isPast,
    required this.isHighlight,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.gold.withValues(alpha: 0.12)
            : AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHighlight ? AppColors.gold : AppColors.divider,
          width: isHighlight ? 1.5 : 0.8,
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isHighlight
                ? AppColors.gold.withValues(alpha: 0.2)
                : AppColors.navyMid,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${date.month}\n月',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isHighlight ? AppColors.gold : AppColors.textSecondary,
                fontSize: 10,
                height: 1.1,
              ),
            ),
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isPast
                ? AppColors.textDisabled
                : isHighlight
                    ? AppColors.goldLight
                    : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          subText,
          style: TextStyle(
            color: isPast ? AppColors.textDisabled : AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        trailing: isPast
            ? const Icon(Icons.check_circle_outline,
                color: AppColors.textDisabled, size: 18)
            : isHighlight
                ? const Icon(Icons.notifications_active,
                    color: AppColors.gold, size: 18)
                : const Icon(Icons.arrow_forward_ios,
                    color: AppColors.textDisabled, size: 14),
      ),
    );
  }
}
