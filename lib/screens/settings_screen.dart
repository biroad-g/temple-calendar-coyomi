import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: AppColors.washiDark,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 六曜 全体ON/OFF ───────────────────────────
          _SectionHeader(title: '六曜表示設定', icon: Icons.tune),
          const SizedBox(height: 8),
          _Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    '六曜を表示',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'カレンダーに六曜を表示します',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  value: p.showRokuyou,
                  onChanged: (v) => p.setShowRokuyou(v),
                  activeThumbColor: AppColors.vermillion,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── 六曜 個別ON/OFF ───────────────────────────
          _SectionHeader(title: '六曜の個別表示', icon: Icons.checklist_outlined),
          const SizedBox(height: 4),
          AnimatedOpacity(
            opacity: p.showRokuyou ? 1.0 : 0.35,
            duration: const Duration(milliseconds: 250),
            child: _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      '表示する六曜を個別に選択できます',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ),
                  ..._RokuyouToggleItem.all.map(
                    (item) => _RokuyouToggleItem(
                      roku: item,
                      isEnabled: p.showRokuyou,
                      isVisible: p.isRokuyouVisible(item),
                      onChanged: (v) => p.setRokuyouVisibility(item, v),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── 六曜カラー凡例 ────────────────────────────
          _SectionHeader(title: '六曜カラー凡例', icon: Icons.palette_outlined),
          const SizedBox(height: 8),
          _Card(
            child: Column(
              children: _rokuyouLegend.map((e) {
                final (label, color, desc) = e;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: color),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                              color: color,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          desc,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // ── 年忌早見表 ────────────────────────────────
          _SectionHeader(title: '法事年忌早見表', icon: Icons.menu_book_outlined),
          const SizedBox(height: 8),
          _Card(
            child: Column(
              children: _kiTable.map((e) {
                final (name, year, note) = e;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text(
                          year,
                          style: const TextStyle(
                              color: AppColors.vermillion,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 110,
                        child: Text(
                          name,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          note,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // ── アプリ情報 ────────────────────────────────
          _SectionHeader(title: 'アプリ情報', icon: Icons.info_outline),
          const SizedBox(height: 8),
          _Card(
            child: Column(
              children: const [
                _InfoRow(label: 'アプリ名', value: '寺院こよみカレンダー'),
                Divider(color: AppColors.divider, height: 16),
                _InfoRow(label: 'バージョン', value: '1.0.0'),
                Divider(color: AppColors.divider, height: 16),
                _InfoRow(label: '六曜計算', value: 'Chapront式天文算法'),
                Divider(color: AppColors.divider, height: 16),
                _InfoRow(label: '和暦対応', value: '明治〜令和'),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── 六曜個別トグル行 ─────────────────────────────────
class _RokuyouToggleItem extends StatelessWidget {
  final RokuyouEnum roku;
  final bool isEnabled;
  final bool isVisible;
  final ValueChanged<bool> onChanged;

  const _RokuyouToggleItem({
    required this.roku,
    required this.isEnabled,
    required this.isVisible,
    required this.onChanged,
  });

  static List<RokuyouEnum> get all => RokuyouEnum.values;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          // カラーバッジ
          Container(
            width: 44,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isVisible && isEnabled
                  ? roku.color.withValues(alpha: 0.2)
                  : AppColors.washiDark,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isVisible && isEnabled
                    ? roku.color
                    : AppColors.textDisabled,
              ),
            ),
            child: Text(
              roku.label,
              style: TextStyle(
                color: isVisible && isEnabled
                    ? roku.color
                    : AppColors.textDisabled,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 説明文
          Expanded(
            child: Text(
              roku.short,
              style: TextStyle(
                color:
                    isVisible && isEnabled ? AppColors.textPrimary : AppColors.textDisabled,
                fontSize: 13,
              ),
            ),
          ),
          // スイッチ
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: isVisible,
              onChanged: isEnabled ? onChanged : null,
              activeColor: roku.color,
              activeTrackColor: roku.color.withValues(alpha: 0.35),
              inactiveThumbColor: AppColors.textDisabled,
              inactiveTrackColor: AppColors.navyLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 六曜凡例データ ────────────────────────────────────
const _rokuyouLegend = [
  ('大安', AppColors.taianColor,       '万事に吉。結婚・開業に最吉日'),
  ('赤口', AppColors.shakkuColor,      '正午前後のみ吉。火に注意'),
  ('先勝', AppColors.senshoColor,      '午前中は吉、午後は凶'),
  ('友引', AppColors.tomobikaColor,    '友を引く日。葬儀を避ける'),
  ('先負', AppColors.senbuColor,       '午前中は凶、午後は吉'),
  ('仏滅', AppColors.butsumetsuColor,  '万事凶。祝事を避ける'),
];

// ── 年忌早見表データ ──────────────────────────────────
const _kiTable = [
  ('一周忌',    '1年',   '没後1年目の命日'),
  ('三回忌',    '3年',   '没後2年目（数え3）'),
  ('七回忌',    '7年',   '没後6年目（数え7）'),
  ('十三回忌',  '13年',  '没後12年目'),
  ('十七回忌',  '17年',  '没後16年目'),
  ('二十三回忌','23年',  '没後22年目'),
  ('二十七回忌','27年',  '没後26年目'),
  ('三十三回忌','33年',  '弔い上げとする場合も'),
  ('五十回忌',  '50年',  '没後49年目'),
  ('百回忌',    '100年', '没後99年目'),
];

// ── 共通ウィジェット ──────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.vermillion, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.vermillion,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.navyLight, width: 0.8),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
