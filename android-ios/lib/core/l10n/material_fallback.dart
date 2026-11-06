import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Flutter's global Material/Cupertino localization tables do not ship
/// Kinyarwanda (`rw`). Every user-facing string in this app lives in
/// `strings.dart`, so these delegates simply serve the standard English
/// chrome strings (date pickers, tooltips, selection toolbar) while the app
/// content itself is already Kinyarwanda.
@immutable
class RwMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const RwMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      const DefaultMaterialLocalizations();

  @override
  bool shouldReload(RwMaterialLocalizationsDelegate old) => false;
}

@immutable
class RwCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const RwCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';

  @override
  Future<CupertinoLocalizations> load(Locale locale) async =>
      const DefaultCupertinoLocalizations();

  @override
  bool shouldReload(RwCupertinoLocalizationsDelegate old) => false;
}
