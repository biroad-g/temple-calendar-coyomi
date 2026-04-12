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
    with TickerProviderStateMixin {
  late TabController _inputTab;   // 西暦/和暦入力タブ
  late TabController _resultTab;  // 年忌/中陰タブ

  // 西暦入力
  final _yearCtrl  = TextEditingController();
  final _monthCtrl = TextEditingController();
  final _dayCtrl   = TextEditingController();

  // 和暦入力
  String _selectedEra = '令和';
  final _eraYearCtrl  = TextEditingController();
  final _eraMonthCtrl = TextEditingController();
  final _eraDayCtrl   = TextEditingController();

  DateTime? _death;

  @override
  void initState() {
    super.initState();
    _inputTab  = TabController(length: 2, vsync: this);
    _resultTab = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final p = context.read<AppProvider>();
    if (p.deathDate != null && _death == null) {
      _death = p.deathDate;
      _fillFromDate(_death!);
    }
  }

  void _fillFromDate(DateTime d) {
    _yearCtrl.text  = d.year.toString();
    _monthCtrl.text = d.month.toString();
    _dayCtrl.text   = d.day.toString();

    final w = JapaneseCalendar.seirekiToWareki(d.year);
    if (w != null) {
      _selectedEra       = w.era;
      _eraYearCtrl.text  = w.year.toString();
      _eraMonthCtrl.text = d.month.toString();
      _eraDayCtrl.text   = d.day.toString();
    }
  }

  @override
  void dispose() {
    _inputTab.dispose();
    _resultTab.dispose();
    _yearCtrl.dispose();
    _monthCtrl.dispose();
    _dayCtrl.dispose();
    _eraYearCtrl.dispose();
    _eraMonthCtrl.dispose();
    _eraDayCtrl.dispose();
    super.dispose();
  }

  void _calculateFromSeireki() {
    try {
      final d = DateTime(
        int.parse(_yearCtrl.text.trim()),
        int.parse(_monthCtrl.text.trim()),
        int.parse(_dayCtrl.text.trim()),
      );
      setState(() {
        _death = d;
        _fillFromDate(d);
      });
      context.read<AppProvider>().setDeathDate(d);
    } catch (_) {
      _showError();
    }
  }

  void _calculateFromWareki() {
    try {
      final warekiYear = int.parse(_eraYearCtrl.text.trim());
      final m = int.parse(_eraMonthCtrl.text.trim());
      final d = int.parse(_eraDayCtrl.text.trim());
      final seireki =
          JapaneseCalendar.warekiToSeireki(_selectedEra, warekiYear);
      if (seireki == null) throw Exception('変換エラー');
      final date = DateTime(seireki, m, d);
      setState(() {
        _death = date;
        _fillFromDate(date);
      });
      context.read<AppProvider>().setDeathDate(date);
    } catch (_) {
      _showError();
    }
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正しい日付を入力してください')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('法事計算'),
        backgroundColor: AppColors.navyDark,
        bottom: TabBar(
          controller: _inputTab,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: '西暦で入力'),
            Tab(text: '和暦で入力'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 入力タブ部分
          SizedBox(
            height: 140,
            child: TabBarView(
              controller: _inputTab,
              children: [
                _SeirekiDeathInput(
                  yearCtrl: _yearCtrl,
                  monthCtrl: _monthCtrl,
                  dayCtrl: _dayCtrl,
                  onCalculate: _calculateFromSeireki,
                  death: _death,
                ),
                _WarekiDeathInput(
                  selectedEra: _selectedEra,
                  eraYearCtrl: _eraYearCtrl,
                  eraMonthCtrl: _eraMonthCtrl,
                  eraDayCtrl: _eraDayCtrl,
                  onEraChanged: (v) => setState(() => _selectedEra = v),
                  onCalculate: _calculateFromWareki,
                  death: _death,
                ),
              ],
            ),
          ),

          // 年忌/中陰タブ切り替え
          if (_death != null)
            Container(
              color: AppColors.navyDark,
              child: TabBar(
                controller: _resultTab,
                indicatorColor: AppColors.gold,
                labelColor: AppColors.gold,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: const [
                  Tab(text: '年忌'),
                  Tab(text: '中陰'),
                ],
              ),
            ),

          // 結果表示
          Expanded(
            child: _death == null
                ? const Center(
                    child: Text('命日を入力して計算してください',
                        style: TextStyle(color: AppColors.textSecondary)),
                  )
                : TabBarView(
                    controller: _resultTab,
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

// ── 西暦命日入力 ─────────────────────────────────────
class _SeirekiDeathInput extends StatelessWidget {
  final TextEditingController yearCtrl, monthCtrl, dayCtrl;
  final VoidCallback onCalculate;
  final DateTime? death;

  const _SeirekiDeathInput({
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
          const Text('命日（西暦）',
              style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _numField(yearCtrl, '西暦年', width: 88),
              const SizedBox(width: 6),
              _numField(monthCtrl, '月', width: 52),
              const SizedBox(width: 6),
              _numField(dayCtrl, '日', width: 52),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onCalculate,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: const Text('計算'),
              ),
            ],
          ),
          if (death != null) ...[
            const SizedBox(height: 6),
            _DeathDateLabel(death: death!),
          ],
        ],
      ),
    );
  }

  Widget _numField(TextEditingController c, String label,
      {double width = 70}) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        ),
      ),
    );
  }
}

// ── 和暦命日入力 ─────────────────────────────────────
class _WarekiDeathInput extends StatelessWidget {
  final String selectedEra;
  final TextEditingController eraYearCtrl, eraMonthCtrl, eraDayCtrl;
  final ValueChanged<String> onEraChanged;
  final VoidCallback onCalculate;
  final DateTime? death;

  const _WarekiDeathInput({
    required this.selectedEra,
    required this.eraYearCtrl,
    required this.eraMonthCtrl,
    required this.eraDayCtrl,
    required this.onEraChanged,
    required this.onCalculate,
    this.death,
  });

  @override
  Widget build(BuildContext context) {
    final eras = JapaneseCalendar.eraNames;
    return Container(
      color: AppColors.navyDark,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('命日（和暦）',
              style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.navyMid,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.navyLight),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedEra,
                    dropdownColor: AppColors.navyDark,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 15),
                    items: eras
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) onEraChanged(v);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _numField(eraYearCtrl, '年', width: 54),
              const SizedBox(width: 6),
              _numField(eraMonthCtrl, '月', width: 50),
              const SizedBox(width: 6),
              _numField(eraDayCtrl, '日', width: 50),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onCalculate,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                child: const Text('計算'),
              ),
            ],
          ),
          if (death != null) ...[
            const SizedBox(height: 6),
            _DeathDateLabel(death: death!),
          ],
        ],
      ),
    );
  }

  Widget _numField(TextEditingController c, String label,
      {double width = 60}) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        ),
      ),
    );
  }
}

// 命日表示ラベル（西暦＋和暦）
class _DeathDateLabel extends StatelessWidget {
  final DateTime death;
  const _DeathDateLabel({required this.death});

  @override
  Widget build(BuildContext context) {
    final w = JapaneseCalendar.seirekiToWareki(death.year);
    final eraStr = w != null ? '${w.era}${w.year}年' : '';
    final label =
        '命日: ${death.year}年（$eraStr）${death.month}月${death.day}日';
    return Text(
      label,
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
      overflow: TextOverflow.ellipsis,
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
        // 西暦＋和暦表示
        final w = JapaneseCalendar.seirekiToWareki(item.date.year);
        final subLabel = w != null
            ? '${item.date.year}年（${w.era}${w.year}年）'
                '${item.date.month}月${item.date.day}日'
            : '${item.date.year}年${item.date.month}月${item.date.day}日';
        return _MemorialTile(
          label: item.name,
          date: item.date,
          isPast: isPast,
          isHighlight: isThisYear,
          subText: subLabel,
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
        // 西暦＋和暦表示
        final w = JapaneseCalendar.seirekiToWareki(item.date.year);
        final subLabel = w != null
            ? '${item.date.year}年（${w.era}${w.year}年）'
                '${item.date.month}月${item.date.day}日'
            : '${item.date.year}年${item.date.month}月${item.date.day}日';
        return _MemorialTile(
          label: item.name,
          date: item.date,
          isPast: isPast,
          isHighlight: isToday,
          subText: subLabel,
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
                color:
                    isHighlight ? AppColors.gold : AppColors.textSecondary,
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
            fontWeight:
                isHighlight ? FontWeight.bold : FontWeight.normal,
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
