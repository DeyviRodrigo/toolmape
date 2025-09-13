import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clase: UserPrefs - preferencias locales del usuario.
class UserPrefs {
  final int? rucLastDigit;   // 0..9
  final String? regimen;     // "RMT","RER","MYPE","RG", etc.
  final bool notificaciones; // activar recordatorios

  const UserPrefs({this.rucLastDigit, this.regimen, this.notificaciones = true});

  UserPrefs copyWith({int? rucLastDigit, String? regimen, bool? notificaciones}) => UserPrefs(
    rucLastDigit: rucLastDigit ?? this.rucLastDigit,
    regimen: regimen ?? this.regimen,
    notificaciones: notificaciones ?? this.notificaciones,
  );
}

/// Notifier: UserPrefsNotifier - maneja la persistencia de UserPrefs.
class UserPrefsNotifier extends AsyncNotifier<UserPrefs> {
  static const _kRucDigit = 'prefs.rucLastDigit';
  static const _kRegimen  = 'prefs.regimen';
  static const _kNotif    = 'prefs.notif';

  @override
  Future<UserPrefs> build() async {
    final p = await SharedPreferences.getInstance();
    return UserPrefs(
      rucLastDigit: p.getInt(_kRucDigit),
      regimen: p.getString(_kRegimen),
      notificaciones: p.getBool(_kNotif) ?? true,
    );
  }

  Future<void> setRucDigit(int? d) async {
    final p = await SharedPreferences.getInstance();
    if (d == null) { await p.remove(_kRucDigit); }
    else { await p.setInt(_kRucDigit, d); }
    state = AsyncData((state.value ?? const UserPrefs()).copyWith(rucLastDigit: d));
  }

  Future<void> setRegimen(String? r) async {
    final p = await SharedPreferences.getInstance();
    if (r == null) { await p.remove(_kRegimen); }
    else { await p.setString(_kRegimen, r); }
    state = AsyncData((state.value ?? const UserPrefs()).copyWith(regimen: r));
  }

  Future<void> setNotif(bool on) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kNotif, on);
    state = AsyncData((state.value ?? const UserPrefs()).copyWith(notificaciones: on));
  }
}

/// Provider: userPrefsProvider - expone las preferencias del usuario.
final userPrefsProvider =
    AsyncNotifierProvider<UserPrefsNotifier, UserPrefs>(() => UserPrefsNotifier());
