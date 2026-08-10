import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

import '../helpers/app_logger.dart';

class DeviceSecurityCheckUtil {
  DeviceSecurityCheckUtil._();

  static final _deviceInfo = DeviceInfoPlugin();
  static const _nativeSecurityChannel = MethodChannel(
    'structure_test/device_security',
  );

  static Future<bool> isEmulator() async {
    try {
      if (Platform.isAndroid) return await _isAndroidEmulator();
      if (Platform.isIOS) return await _isIOSSimulator();
    } catch (e) {
      AppLogger.log(
        'Is Emulator check failed: $e',
        name: 'DEVICE_SECURITY_CHECK_UTIL',
      );
    }
    return false;
  }

  static Future<bool> _isAndroidEmulator() async {
    if (await _invokeAndroidBool('isEmulator')) return true;

    final info = await _deviceInfo.androidInfo;

    if (!info.isPhysicalDevice) return true;

    final suspects = [
      info.model,
      info.brand,
      info.manufacturer,
      info.hardware,
      info.product,
      info.device,
      info.fingerprint,
    ].map((s) => s.toLowerCase()).toList();

    const emulatorKeywords = [
      'generic',
      'sdk',
      'emulator',
      'genymotion',
      'vbox',
      'nox',
      'bluestacks',
      'qemu',
      'goldfish',
      'ranchu',
      'ttvm',
      'android_x86',
      'x86',
    ];

    if (suspects.any((prop) => emulatorKeywords.any(prop.contains))) {
      return true;
    }

    if (await _hasQemuFiles()) return true;

    return false;
  }

  static Future<bool> _isIOSSimulator() async {
    final info = await _deviceInfo.iosInfo;

    return !info.isPhysicalDevice;
  }

  static Future<bool> _hasQemuFiles() async {
    const paths = [
      '/dev/socket/qemud',
      '/dev/qemu_pipe',
      '/sys/qemu_trace',
      '/system/bin/qemu-props',
      '/system/lib/libc_malloc_debug_qemu.so',
    ];

    return paths.any((p) => File(p).existsSync());
  }

  static Future<bool> isRootedOrJailbroken() async {
    try {
      if (Platform.isAndroid) return await _isAndroidRooted();

      if (Platform.isIOS) return await _isIOSJailbroken();
    } catch (e) {
      AppLogger.log(
        'Is Rooted | JailBroken check failed: $e',
        name: 'DEVICE_SECURITY_CHECK_UTIL',
      );
    }

    return false;
  }

  static Future<bool> _isAndroidRooted() async {
    if (await _invokeAndroidBool('isRooted')) return true;

    final info = await _deviceInfo.androidInfo;

    if (info.tags.contains('test-keys')) return true;

    const rootPaths = [
      '/system/app/Superuser.apk',
      '/sbin/su',
      '/system/bin/su',
      '/system/xbin/su',
      '/data/local/xbin/su',
      '/data/local/bin/su',
      '/system/sd/xbin/su',
      '/system/bin/failsafe/su',
      '/data/local/su',
      '/su/bin/su',
      '/system/bin/.ext/.su',
      '/system/usr/we-need-root/su',
      '/system/xbin/daemonsu',
      '/magisk/.core/bin/su',
      '/data/adb/magisk',
      '/data/adb/ksu',
    ];

    if (rootPaths.any((p) => File(p).existsSync())) return true;

    if (await _canFindSuBinary()) return true;

    return false;
  }

  static Future<bool> _isIOSJailbroken() async {
    final info = await _deviceInfo.iosInfo;

    if (!info.isPhysicalDevice) return false;

    const jailbreakPaths = [
      '/Applications/Cydia.app',
      '/Library/MobileSubstrate/MobileSubstrate.dylib',
      '/bin/bash',
      '/usr/sbin/sshd',
      '/etc/apt',
      '/private/var/lib/apt/',
    ];

    if (jailbreakPaths.any((p) => File(p).existsSync())) return true;

    return _canWriteOutsideIOSSandbox();
  }

  static Future<bool> isDeveloperOptionsEnabled() async {
    if (!Platform.isAndroid) return false;

    if (await _invokeAndroidBool('isDeveloperOptionsEnabled')) return true;

    return _developerOptionsFallback();
  }

  static Future<bool> openDeveloperOptionsSettings() async {
    if (!Platform.isAndroid) return false;

    try {
      return await _nativeSecurityChannel.invokeMethod<bool>(
            'openDeveloperOptionsSettings',
          ) ??
          false;
    } on MissingPluginException catch (e) {
      AppLogger.log(
        'Native Android security method "openDeveloperOptionsSettings" is not registered: $e',
        name: 'DEVICE_SECURITY_CHECK_UTIL',
      );
    } on PlatformException catch (e) {
      AppLogger.log(
        'Native Android security method "openDeveloperOptionsSettings" failed: $e',
        name: 'DEVICE_SECURITY_CHECK_UTIL',
      );
    } catch (e) {
      AppLogger.log(
        'Native Android security method "openDeveloperOptionsSettings" failed: $e',
        name: 'DEVICE_SECURITY_CHECK_UTIL',
      );
    }

    return false;
  }

  static Future<bool> _developerOptionsFallback() async {
    try {
      final info = await _deviceInfo.androidInfo;

      return info.tags.contains('test-keys') ||
          info.type.toLowerCase().contains('debug');
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _invokeAndroidBool(String method) async {
    if (!Platform.isAndroid) return false;

    try {
      return await _nativeSecurityChannel.invokeMethod<bool>(method) ?? false;
    } on MissingPluginException catch (e) {
      AppLogger.log(
        'Native Android security method "$method" is not registered: $e',
        name: 'DEVICE_SECURITY_CHECK_UTIL',
      );
    } on PlatformException catch (e) {
      AppLogger.log(
        'Native Android security method "$method" failed: $e',
        name: 'DEVICE_SECURITY_CHECK_UTIL',
      );
    } catch (e) {
      AppLogger.log(
        'Native Android security method "$method" failed: $e',
        name: 'DEVICE_SECURITY_CHECK_UTIL',
      );
    }

    return false;
  }

  static Future<bool> _canFindSuBinary() async {
    const commands = [
      ['/system/xbin/which', 'su'],
      ['/system/bin/which', 'su'],
      ['which', 'su'],
    ];

    for (final command in commands) {
      try {
        final result = await Process.run(command.first, command.sublist(1));
        if (result.exitCode == 0 &&
            result.stdout.toString().trim().isNotEmpty) {
          return true;
        }
      } catch (_) {
        continue;
      }
    }

    return false;
  }

  static Future<bool> _canWriteOutsideIOSSandbox() async {
    const testPath = '/private/jailbreak_test.txt';

    try {
      final file = File(testPath);
      await file.writeAsString('Jailbreak Test');
      await file.delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<DeviceSecurityResult> checkAll() async {
    final results = await Future.wait([
      isEmulator(),

      isRootedOrJailbroken(),

      isDeveloperOptionsEnabled(),
    ]);

    final result = DeviceSecurityResult(
      isEmulator: results[0],
      isRooted: results[1],
      isDeveloperOptionsEnabled: results[2],
    );

    AppLogger.log(
      'Security check: $result',
      name: 'DEVICE_SECURITY_CHECK_UTIL',
    );

    return result;
  }
}

class DeviceSecurityResult {
  final bool isEmulator;
  final bool isRooted;
  final bool isDeveloperOptionsEnabled;

  const DeviceSecurityResult({
    required this.isEmulator,
    required this.isRooted,
    required this.isDeveloperOptionsEnabled,
  });

  bool get isSecure => !isEmulator && !isRooted && !isDeveloperOptionsEnabled;

  @override
  String toString() =>
      'DeviceSecurityResult(emulator: $isEmulator, rooted: $isRooted, devOptions: $isDeveloperOptionsEnabled, secure: $isSecure)';
}
