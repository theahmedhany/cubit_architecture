import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/app_logger.dart';

class SharedPrefHelper {
  SharedPrefHelper._();

  static SharedPreferences? _pref;

  static SharedPreferences get instance {
    if (_pref == null) {
      throw StateError(
        'SharedPrefHelper is not initialized. '
        'Call SharedPrefHelper.init() before using it.',
      );
    }

    return _pref!;
  }

  static Future<void> init() async {
    _pref = await SharedPreferences.getInstance();

    AppLogger.log(
      'SharedPreferences initialized successfully.',
      name: 'SHARED_PREF_HELPER',
    );
  }

  static Future<bool> setData<T>({
    required String key,
    required T value,
  }) async {
    try {
      AppLogger.log(
        'Set data with key : $key and value : $value',
        name: 'SHARED_PREF_HELPER',
      );

      if (value is String) {
        return instance.setString(key, value);
      }

      if (value is int) {
        return instance.setInt(key, value);
      }

      if (value is bool) {
        return instance.setBool(key, value);
      }

      if (value is double) {
        return instance.setDouble(key, value);
      }

      if (value is List<String>) {
        return instance.setStringList(key, value);
      }

      throw UnsupportedError('Unsupported type: ${value.runtimeType}');
    } catch (e, stackTrace) {
      AppLogger.log(
        'Failed to set key: $key with value: $value - Error: $e - StackTrace: $stackTrace',
        name: 'SHARED_PREF_HELPER',
      );

      return false;
    }
  }

  static String getString({required String key, String defaultValue = ''}) {
    final value = instance.getString(key);

    AppLogger.log(
      'Get string with key : $key - Retrieved value: ${value ?? defaultValue}',
      name: 'SHARED_PREF_HELPER',
    );

    return value ?? defaultValue;
  }

  static int getInt({required String key, int defaultValue = 0}) {
    final value = instance.getInt(key);

    AppLogger.log(
      'Get int with key : $key - Retrieved value: ${value ?? defaultValue}',
      name: 'SHARED_PREF_HELPER',
    );

    return value ?? defaultValue;
  }

  static double getDouble({required String key, double defaultValue = 0.0}) {
    final value = instance.getDouble(key);

    AppLogger.log(
      'Get double with key : $key - Retrieved value: ${value ?? defaultValue}',
      name: 'SHARED_PREF_HELPER',
    );

    return value ?? defaultValue;
  }

  static bool getBool({required String key, bool defaultValue = false}) {
    final value = instance.getBool(key);

    AppLogger.log(
      'Get bool with key : $key - Retrieved value: ${value ?? defaultValue}',
      name: 'SHARED_PREF_HELPER',
    );

    return value ?? defaultValue;
  }

  static List<String> getStringList({
    required String key,
    List<String> defaultValue = const [],
  }) {
    final value = instance.getStringList(key);

    AppLogger.log(
      'Get string list with key : $key - Retrieved value: ${value ?? defaultValue}',
      name: 'SHARED_PREF_HELPER',
    );

    return value ?? defaultValue;
  }

  static T getData<T>({required String key, required T defaultValue}) {
    final value = instance.get(key);

    AppLogger.log(
      'Get data with key : $key - Retrieved value: ${value ?? defaultValue}',
      name: 'SHARED_PREF_HELPER',
    );

    if (value is T) {
      return value;
    }

    return defaultValue;
  }

  static bool containsKey({required String key}) {
    AppLogger.log('Contains key : $key', name: 'SHARED_PREF_HELPER');

    return instance.containsKey(key);
  }

  static Future<bool> removeData({required String key}) async {
    try {
      AppLogger.log('Remove data with key : $key', name: 'SHARED_PREF_HELPER');

      return await instance.remove(key);
    } catch (e, stackTrace) {
      AppLogger.log(
        'Failed to remove key: $key - Error: $e - StackTrace: $stackTrace',
        name: 'SHARED_PREF_HELPER',
      );

      return false;
    }
  }

  static Future<bool> clearAllData() async {
    try {
      AppLogger.log('Clear all data', name: 'SHARED_PREF_HELPER');

      return await instance.clear();
    } catch (e, stackTrace) {
      AppLogger.log(
        'Failed to clear SharedPreferences - Error: $e - StackTrace: $stackTrace',
        name: 'SHARED_PREF_HELPER',
      );

      return false;
    }
  }

  static Future<void> reload() async {
    AppLogger.log('Reload SharedPreferences', name: 'SHARED_PREF_HELPER');

    await instance.reload();
  }
}
