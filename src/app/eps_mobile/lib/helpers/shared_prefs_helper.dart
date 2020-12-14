import 'package:shared_preferences/shared_preferences.dart';
import 'package:eps_mobile/localizations/localization_value_helper.dart';
import 'package:eps_mobile/models/localization.dart';

class SharedPrefsHelper {
  String localizationPreference = '';
  bool useLocationPreference = false;

  static const String localizationPreferenceKey = 'localizationPreference';
  static const String useLocationPreferenceKey = 'useLocationPreference';

  SharedPrefsHelper();

  Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> setUseLocationPreference(
    bool useLocation,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      useLocationPreferenceKey,
      useLocation.toString().toLowerCase(),
    );
  }

  Future<bool> getUseLocationPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var pref = prefs.getString(useLocationPreferenceKey);
    if (pref == null) {
      return null;
    } else {
      bool value = pref.toLowerCase() == 'true';
      return value;
    }
  }

  Future<void> setLocalizationPreference(
    Localization localization,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      localizationPreferenceKey,
      localization.code,
    );
  }

  Future<Localization> getLocalizationPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var code = prefs.getString(localizationPreferenceKey);
    var localizations = LocalizationValueHelper().getAllLocalizations();
    var searchResults = localizations.where((x) => x.code == code).toList();
    if (searchResults.length > 0) {
      if (searchResults.length > 1) {
        // log an error here, should only get 1 result
        print('ERROR - on SharedPrefsHelper.getLocalizationPreference ' +
            'finds more than 1 result for localization code ' +
            code);
      }
      return searchResults.first;
    }
    return null;
  }
}
