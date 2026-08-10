import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../helpers/app_logger.dart';
import 'app_cache_keys.dart';

class SecureStorageHelper {
  SecureStorageHelper._();

  static FlutterSecureStorage? _storage;

  static FlutterSecureStorage get instance {
    if (_storage == null) {
      throw StateError(
        'SecureStorageHelper is not initialized. '
        'Call SecureStorageHelper.init() before using it.',
      );
    }

    return _storage!;
  }

  static Future<void> init() async {
    _storage = const FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
      mOptions: MacOsOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );

    AppLogger.log('Secure storage initialized', name: 'FLUTTER_SECURE_STORAGE');
  }

  static Future<bool> write({
    required String key,
    required String value,
  }) async {
    try {
      await instance.write(key: key, value: value);

      AppLogger.log(
        'Secure value saved for key: $key with value: $value',
        name: 'FLUTTER_SECURE_STORAGE',
      );

      return true;
    } on PlatformException catch (e, stackTrace) {
      if (e.code == '-25299' || e.message?.contains('-25299') == true) {
        AppLogger.log(
          'Duplicate item in keychain (-25299) for key: $key. Deleting and retrying.',
          name: 'FLUTTER_SECURE_STORAGE',
        );

        try {
          await delete(key: key);

          await instance.write(key: key, value: value);

          return true;
        } catch (e2, stackTrace2) {
          AppLogger.log(
            'Failed to save secure value after delete for key: $key - Error: $e2 - StackTrace: $stackTrace2',
            name: 'FLUTTER_SECURE_STORAGE',
          );

          return false;
        }
      }

      AppLogger.log(
        'Failed to save secure value for key: $key with value: $value - Error: $e - StackTrace: $stackTrace',
        name: 'FLUTTER_SECURE_STORAGE',
      );

      return false;
    } catch (e, stackTrace) {
      AppLogger.log(
        'Failed to save secure value for key: $key with value: $value - Error: $e - StackTrace: $stackTrace',
        name: 'FLUTTER_SECURE_STORAGE',
      );

      return false;
    }
  }

  static Future<String> read({
    required String key,
    String defaultValue = '',
  }) async {
    try {
      final value = await instance.read(key: key);

      AppLogger.log(
        'Reading secure value for key: $key - Retrieved value: ${value ?? defaultValue}',
        name: 'FLUTTER_SECURE_STORAGE',
      );

      return value ?? defaultValue;
    } catch (e, stackTrace) {
      AppLogger.log(
        'Failed to read secure value for key: $key - Error: $e - StackTrace: $stackTrace',
        name: 'FLUTTER_SECURE_STORAGE',
      );

      return defaultValue;
    }
  }

  static Future<bool> containsKey({required String key}) async {
    try {
      return await instance.containsKey(key: key);
    } catch (e, stackTrace) {
      AppLogger.log(
        'Failed to check secure key: $key - Error: $e - StackTrace: $stackTrace',
        name: 'FLUTTER_SECURE_STORAGE',
      );

      return false;
    }
  }

  static Future<bool> delete({required String key}) async {
    try {
      await instance.delete(key: key);

      AppLogger.log(
        'Secure value deleted for key: $key',
        name: 'FLUTTER_SECURE_STORAGE',
      );

      return true;
    } catch (e, stackTrace) {
      AppLogger.log(
        'Failed to delete secure value for key: $key - Error: $e - StackTrace: $stackTrace',
        name: 'FLUTTER_SECURE_STORAGE',
      );

      return false;
    }
  }

  static Future<bool> deleteAll() async {
    try {
      await instance.deleteAll();

      AppLogger.log(
        'All secure values deleted',
        name: 'FLUTTER_SECURE_STORAGE',
      );

      return true;
    } catch (e, stackTrace) {
      AppLogger.log(
        'Failed to clear secure storage - Error: $e - StackTrace: $stackTrace',
        name: 'FLUTTER_SECURE_STORAGE',
      );

      return false;
    }
  }

  static Future<bool> setToken(String token) {
    return write(key: AppCacheKeys.userAccessToken, value: token);
  }

  static Future<String> getToken({String defaultValue = ''}) {
    return read(key: AppCacheKeys.userAccessToken, defaultValue: defaultValue);
  }

  static Future<bool> clearToken() {
    return delete(key: AppCacheKeys.userAccessToken);
  }
}
