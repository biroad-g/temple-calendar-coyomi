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

class _AgeScreenState extends State<AgeScreen> {
  final _yearCtrl  = TextEditingController();
  final _monthCtrl = TextEditingController();
  final _dayCtrl   = TextEditingController();
  DateTime? _birth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final p = context.read<AppProvider>();
    if (p.birthDate != null && _birth == null) {
      _birth = p.birthDate;
      _yearCtrl.text  = _birth!.year.toString();
      _monthCtrl.text = _birth!.month.toString();
      _dayCtrl.text   = _birth!.day.toString();
    }
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    _monthCtrl.dispose();
    _dayCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    try {
      final y = int.parse(_yearCtrl.text.trim());
      final m = int.parse(_monthCtrl.text.trim());
      final d = int.parse(_dayCtrl.text.trim());
      final birth = DateTime(y, m, d);
      setState(() => _birth = birth);
      context.read<AppProvider>().setBirthDate(birth);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正しい日付を入力してください')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        title: const Text('年齢計算'),
        backgroundColor: AppColors.navyDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 入力カード
            _sectionCard(
              title: '生年月日を入力',
              icon: Icons.cake_outlined,
              child: Column(
                children: [
                  Row(
                    children: [
                      _numField(_yearCtrl, '年', width: 90),
                      const SizedBox(width: 8),
                      _numField(_monthCtrl, '月', width: 56),
                      const SizedBox(width: 8),
                      _numField(_dayCtrl, '日', width: 56),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _calculate,
                        child: const Text('計算'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 結果カード
            if (_birth != null) ...[
              const SizedBox(height: 16),
              _sectionCard(
                title: '計算結果',
                icon: Icons.auto_awesome,
                child: Column(
                  children: [
                    _resultRow('生年月日',
                        JapaneseCalendar.toFullDate(_birth!)),
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

              // 長寿祝い
              const SizedBox(height: 16),
              _sectionCard(
                title: '長寿のお祝い',
                icon: Icons.celebration_outlined,
                child: _LongevityTable(birth: _birth!, today: today),
              ),
            ],
          ],
        ),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        ),
      ),
    );
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

// 長寿祝い一覧
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
        final year = birth.year + age;
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
                  Text('$year年',
                      style: TextStyle(
                          color: isCurrent ? AppColors.gold : AppColors.textSecondary,
                          fontSize: 12)),
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
