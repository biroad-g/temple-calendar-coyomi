import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_theme.dart';

class AppProvider extends ChangeNotifier {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDate;
  DateTime? _birthDate;
  DateTime? _deathDate;
  bool _showRokuyou = true;
  int _currentTab = 0;

  // 六曜個別ON/OFF（6種類: 大安・赤口・先勝・友引・先負・仏滅）
  // key: RokuyouEnum.name, value: 表示するか
  final Map<String, bool> _rokuyouVisibility = {
    'taian':      true,
    'shakku':     true,
    'sensho':     true,
    'tomobiki':   true,
    'senbu':      true,
    'butsumetsu': true,
  };

  DateTime get focusedMonth => _focusedMonth;
  DateTime? get selectedDate => _selectedDate;
  DateTime? get birthDate => _birthDate;
  DateTime? get deathDate => _deathDate;
  bool get showRokuyou => _showRokuyou;
  int get currentTab => _currentTab;
  Map<String, bool> get rokuyouVisibility => Map.unmodifiable(_rokuyouVisibility);

  /// 特定の六曜が表示対象かを返す
  bool isRokuyouVisible(RokuyouEnum roku) =>
      _rokuyouVisibility[roku.name] ?? true;

  AppProvider() {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _showRokuyou = p.getBool('showRokuyou') ?? true;
    final bd = p.getString('birthDate');
    if (bd != null) _birthDate = DateTime.tryParse(bd);
    final dd = p.getString('deathDate');
    if (dd != null) _deathDate = DateTime.tryParse(dd);
    // 六曜個別設定を読み込む
    for (final key in _rokuyouVisibility.keys) {
      _rokuyouVisibility[key] = p.getBool('roku_$key') ?? true;
    }
    notifyListeners();
  }

  void setFocusedMonth(DateTime d) {
    _focusedMonth = DateTime(d.year, d.month, 1);
    notifyListeners();
  }

  void setSelectedDate(DateTime? d) {
    _selectedDate = d;
    notifyListeners();
  }

  void setBirthDate(DateTime? d) {
    _birthDate = d;
    SharedPreferences.getInstance().then((p) {
      if (d != null) {
        p.setString('birthDate', d.toIso8601String());
      } else {
        p.remove('birthDate');
      }
    });
    notifyListeners();
  }

  void setDeathDate(DateTime? d) {
    _deathDate = d;
    SharedPreferences.getInstance().then((p) {
      if (d != null) {
        p.setString('deathDate', d.toIso8601String());
      } else {
        p.remove('deathDate');
      }
    });
    notifyListeners();
  }

  void setShowRokuyou(bool v) {
    _showRokuyou = v;
    SharedPreferences.getInstance().then((p) => p.setBool('showRokuyou', v));
    notifyListeners();
  }

  /// 個別の六曜の表示をトグル
  void toggleRokuyouVisibility(RokuyouEnum roku) {
    final key = roku.name;
    _rokuyouVisibility[key] = !(_rokuyouVisibility[key] ?? true);
    SharedPreferences.getInstance()
        .then((p) => p.setBool('roku_$key', _rokuyouVisibility[key]!));
    notifyListeners();
  }

  /// 個別の六曜の表示をセット
  void setRokuyouVisibility(RokuyouEnum roku, bool v) {
    _rokuyouVisibility[roku.name] = v;
    SharedPreferences.getInstance()
        .then((p) => p.setBool('roku_${roku.name}', v));
    notifyListeners();
  }

  void setCurrentTab(int i) {
    _currentTab = i;
    notifyListeners();
  }

  void prevMonth() {
    final d = _focusedMonth;
    _focusedMonth = DateTime(
        d.month == 1 ? d.year - 1 : d.year,
        d.month == 1 ? 12 : d.month - 1,
        1);
    notifyListeners();
  }

  void nextMonth() {
    final d = _focusedMonth;
    _focusedMonth = DateTime(
        d.month == 12 ? d.year + 1 : d.year,
        d.month == 12 ? 1 : d.month + 1,
        1);
    notifyListeners();
  }

  void prevYear() {
    final d = _focusedMonth;
    _focusedMonth = DateTime(d.year - 1, d.month, 1);
    notifyListeners();
  }

  void nextYear() {
    final d = _focusedMonth;
    _focusedMonth = DateTime(d.year + 1, d.month, 1);
    notifyListeners();
  }

  void goToYear(int year) {
    _focusedMonth = DateTime(year, _focusedMonth.month, 1);
    notifyListeners();
  }

  void goToYearMonth(int year, int month) {
    _focusedMonth = DateTime(year, month, 1);
    notifyListeners();
  }

  void goToToday() {
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _selectedDate = DateTime.now();
    notifyListeners();
  }
}
