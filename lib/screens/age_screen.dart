import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/age_memorial_calculator.dart';
import '../core/japanese_calendar.dart';
import '../providers/app_provider.dart';

class AgeScreen extends StatefulWidget {
  const AgeScreen({super.key});
  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // 西暦入力
  final _yearCtrl  = TextEditingController();
  final _monthCtrl = TextEditingController();
  final _dayCtrl   = TextEditingController();

  // 和暦入力
  String _selectedEra = '令和';
  final _eraYearCtrl  = TextEditingController();
  final _eraMonthCtrl = TextEditingController();
  final _eraDayCtrl   = TextEditingController();

  DateTime? _birth;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final p = context.read<AppProvider>();
    if (p.birthDate != null && _birth == null) {
      _birth = p.birthDate;
      _fillFromDate(_birth!);
    }
  }

  void _fillFromDate(DateTime d) {
    _yearCtrl.text  = d.year.toString();
    _monthCtrl.text = d.month.toString();
    _dayCtrl.text   = d.day.toString();

    // 和暦も更新
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
    _tabCtrl.dispose();
    _yearCtrl.dispose();
    _monthCtrl.dispose();
    _dayCtrl.dispose();
    _eraYearCtrl.dispose();
    _eraMonthCtrl.dispose();
    _eraDayCtrl.dispose();
    super.dispose();
  }

  // 西暦から計算
  void _calculateFromSeireki() {
    try {
      final y = int.parse(_yearCtrl.text.trim());
      final m = int.parse(_monthCtrl.text.trim());
      final d = int.parse(_dayCtrl.text.trim());
      final birth = DateTime(y, m, d);
      setState(() {
        _birth = birth;
        _fillFromDate(birth);
      });
      context.read<AppProvider>().setBirthDate(birth);
    } catch (_) {
      _showError();
    }
  }

  // 和暦から計算
  void _calculateFromWareki() {
    try {
      final warekiYear = int.parse(_eraYearCtrl.text.trim());
      final m = int.parse(_eraMonthCtrl.text.trim());
      final d = int.parse(_eraDayCtrl.text.trim());
      final seireki = JapaneseCalendar.warekiToSeireki(_selectedEra, warekiYear);
      if (seireki == null) throw Exception('変換エラー');
      final birth = DateTime(seireki, m, d);
      setState(() {
        _birth = birth;
        _fillFromDate(birth);
      });
      context.read<AppProvider>().setBirthDate(birth);
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
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('年齢計算'),
        backgroundColor: AppColors.navyDark,
        bottom: TabBar(
          controller: _tabCtrl,
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
          // 入力タブ
          SizedBox(
            height: 130,
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _SeirekiInput(
                  yearCtrl: _yearCtrl,
                  monthCtrl: _monthCtrl,
                  dayCtrl: _dayCtrl,
                  onCalculate: _calculateFromSeireki,
                ),
                _WarekiInput(
                  selectedEra: _selectedEra,
                  eraYearCtrl: _eraYearCtrl,
                  eraMonthCtrl: _eraMonthCtrl,
                  eraDayCtrl: _eraDayCtrl,
                  onEraChanged: (v) => setState(() => _selectedEra = v),
                  onCalculate: _calculateFromWareki,
                ),
              ],
            ),
          ),

          // 結果
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_birth != null) ...[
                    _sectionCard(
                      title: '計算結果',
                      icon: Icons.auto_awesome,
                      child: Column(
                        children: [
                          _resultRow('生年月日', _formatBirthDate(_birth!)),
                          _divider(),
                          _resultRow('満年齢',
                              '${AgeCalculator.fullAge(_birth!, today)} 歳'),
                          _divider(),
                          _resultRow('数え年',
                              '${AgeCalculator.countingAge(_birth!, today)} 歳'),
                          _divider(),
                          _resultRow('干支', AgeCalculator.eto(_birth!)),
                          _divider(),
                          _resultRow('今年の干支', AgeCalculator.eto(today)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: '長寿のお祝い',
                      icon: Icons.celebration_outlined,
                      child: _LongevityTable(birth: _birth!, today: today),
                    ),
                  ] else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Text(
                          '生年月日を入力して計算してください',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 生年月日を西暦＋和暦で表示
  String _formatBirthDate(DateTime d) {
    final w = JapaneseCalendar.seirekiToWareki(d.year);
    final eraStr = w != null ? '${w.era}${w.year}年' : '';
    return '${d.year}年（$eraStr）${d.month}月${d.day}日';
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.navyLight, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: AppColors.gold, size: 18),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(color: AppColors.divider, height: 1),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(color: AppColors.divider, height: 12, thickness: 0.5);
}

// ── 西暦入力ウィジェット ──────────────────────────────
class _SeirekiInput extends StatelessWidget {
  final TextEditingController yearCtrl, monthCtrl, dayCtrl;
  final VoidCallback onCalculate;

  const _SeirekiInput({
    required this.yearCtrl,
    required this.monthCtrl,
    required this.dayCtrl,
    required this.onCalculate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navyDark,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('生年月日（西暦）',
              style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              _numField(yearCtrl, '西暦年', width: 90),
              const SizedBox(width: 8),
              _numField(monthCtrl, '月', width: 56),
              const SizedBox(width: 8),
              _numField(dayCtrl, '日', width: 56),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onCalculate,
                child: const Text('計算'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('例: 1980 年 3 月 15 日',
              style: TextStyle(color: AppColors.textDisabled, fontSize: 11)),
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
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        ),
      ),
    );
  }
}

// ── 和暦入力ウィジェット ──────────────────────────────
class _WarekiInput extends StatelessWidget {
  final String selectedEra;
  final TextEditingController eraYearCtrl, eraMonthCtrl, eraDayCtrl;
  final ValueChanged<String> onEraChanged;
  final VoidCallback onCalculate;

  const _WarekiInput({
    required this.selectedEra,
    required this.eraYearCtrl,
    required this.eraMonthCtrl,
    required this.eraDayCtrl,
    required this.onEraChanged,
    required this.onCalculate,
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
          const Text('生年月日（和暦）',
              style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              // 元号ドロップダウン
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
              _numField(eraYearCtrl, '年', width: 56),
              const SizedBox(width: 6),
              _numField(eraMonthCtrl, '月', width: 50),
              const SizedBox(width: 6),
              _numField(eraDayCtrl, '日', width: 50),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onCalculate,
                child: const Text('計算'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('例: 昭和 55 年 3 月 15 日',
              style: TextStyle(color: AppColors.textDisabled, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _numField(TextEditingController c, String label, {double width = 60}) {
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

// ── 長寿祝い一覧 ─────────────────────────────────────
class _LongevityTable extends StatelessWidget {
  final DateTime birth;
  final DateTime today;

  const _LongevityTable({required this.birth, required this.today});

  static const _items = [
    (60,  '還暦', 'かんれき', '赤'),
    (70,  '古希', 'こき', '紫'),
    (77,  '喜寿', 'きじゅ', '紫'),
    (80,  '傘寿', 'さんじゅ', '黄'),
    (88,  '米寿', 'べいじゅ', '黄'),
    (90,  '卒寿', 'そつじゅ', '白'),
    (99,  '白寿', 'はくじゅ', '白'),
    (100, '百寿', 'ひゃくじゅ', '白'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentAge = AgeCalculator.fullAge(birth, today);
    return Column(
      children: _items.map((e) {
        final (age, name, reading, color) = e;
        final seireki = birth.year + age;
        // 西暦＋和暦で表示
        final w = JapaneseCalendar.seirekiToWareki(seireki);
        final yearLabel = w != null
            ? '$seireki年\n（${w.era}${w.year}年）'
            : '$seireki年';
        final isPast = currentAge > age;
        final isCurrent = currentAge == age;
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.gold.withValues(alpha: 0.15)
                : AppColors.navyMid,
            borderRadius: BorderRadius.circular(8),
            border: isCurrent
                ? Border.all(color: AppColors.gold, width: 1.5)
                : Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Text('$age歳',
                    style: TextStyle(
                        color: isCurrent ? AppColors.gold : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: TextStyle(
                            color: isCurrent
                                ? AppColors.goldLight
                                : isPast
                                    ? AppColors.textDisabled
                                    : AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    Text('（$reading）',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(yearLabel,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: isCurrent ? AppColors.gold : AppColors.textSecondary,
                          fontSize: 11,
                          height: 1.3)),
                  Text('色: $color',
                      style: const TextStyle(
                          color: AppColors.textDisabled, fontSize: 10)),
                ],
              ),
              if (isCurrent)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.star, color: AppColors.gold, size: 16),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
