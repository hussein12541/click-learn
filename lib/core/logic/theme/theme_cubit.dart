import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<bool> {
  static const _key = 'isDarkMode';

  ThemeCubit() : super(true) {
    _loadTheme();
  }

  // تحميل الحالة من SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? true; // لو مفيش قيمة خليها false
    emit(isDark);
  }

  // تبديل الحالة وتخزينها
  Future<void> toggleTheme() async {
    final newState = !state;
    emit(newState);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, newState);
  }

  // لو عايز تحدد الوضع مباشرة
  Future<void> setTheme(bool isDark) async {
    emit(isDark);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDark);
  }
}
