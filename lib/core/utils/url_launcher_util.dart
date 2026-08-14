import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/app/app_snack_bar.dart';
import '../helpers/app_logger.dart';

class UrlLauncherUtil {
  const UrlLauncherUtil._();

  // Launch URL
  static Future<void> launchURL({
    required BuildContext context,
    required String url,
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    try {
      if (url.isEmpty) {
        AppLogger.log(
          'URL is empty or not available',
          name: 'URL_LAUNCHER_UTIL',
        );

        AppSnackBar.show(
          context: context,
          message: 'url_not_available'.tr(),
          type: AppSnackBarType.error,
        );

        return;
      }

      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: mode);
      } else {
        AppLogger.log('Cannot launch URL: $url', name: 'URL_LAUNCHER_UTIL');

        if (!context.mounted) return;

        AppSnackBar.show(
          context: context,
          message: 'cannot_open_url'.tr(),
          type: AppSnackBarType.error,
        );
      }
    } catch (e) {
      AppLogger.log('Error launching URL: $e', name: 'URL_LAUNCHER_UTIL');

      if (!context.mounted) return;

      AppSnackBar.show(
        context: context,
        message: 'error_opening_url'.tr(),
        type: AppSnackBarType.error,
      );
    }
  }

  // WhatsApp
  static Future<void> launchWhatsApp({
    required BuildContext context,
    required String phoneNumber,
    String? message,
  }) async {
    try {
      if (phoneNumber.isEmpty) {
        AppLogger.log(
          'WhatsApp number is empty or not available',
          name: 'URL_LAUNCHER_UTIL',
        );

        AppSnackBar.show(
          context: context,
          message: 'whatsapp_number_not_available'.tr(),
          type: AppSnackBarType.error,
        );

        return;
      }

      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

      final encodedMessage = message != null && message.isNotEmpty
          ? Uri.encodeComponent(message)
          : '';

      final Uri uri = Uri.parse(
        'https://wa.me/$cleanNumber${encodedMessage.isNotEmpty ? '?text=$encodedMessage' : ''}',
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppLogger.log(
          'Cannot launch WhatsApp: $phoneNumber',
          name: 'URL_LAUNCHER_UTIL',
        );

        if (!context.mounted) return;

        AppSnackBar.show(
          context: context,
          message: 'cannot_open_whatsapp'.tr(),
          type: AppSnackBarType.error,
        );
      }
    } catch (e) {
      AppLogger.log('Error launching WhatsApp: $e', name: 'URL_LAUNCHER_UTIL');

      if (!context.mounted) return;

      AppSnackBar.show(
        context: context,
        message: 'error_opening_whatsapp'.tr(),
        type: AppSnackBarType.error,
      );
    }
  }

  // Email
  static Future<void> launchEmail({
    required BuildContext context,
    required String email,
    String? subject,
    String? body,
    List<String>? cc,
    List<String>? bcc,
  }) async {
    try {
      if (email.isEmpty) {
        AppLogger.log(
          'Email is empty or not available',
          name: 'URL_LAUNCHER_UTIL',
        );

        AppSnackBar.show(
          context: context,
          message: 'email_not_available'.tr(),
          type: AppSnackBarType.error,
        );

        return;
      }

      final Map<String, String> queryParameters = {};

      if (subject != null && subject.isNotEmpty) {
        queryParameters['subject'] = subject;
      }

      if (body != null && body.isNotEmpty) {
        queryParameters['body'] = body;
      }

      if (cc != null && cc.isNotEmpty) {
        queryParameters['cc'] = cc.join(',');
      }

      if (bcc != null && bcc.isNotEmpty) {
        queryParameters['bcc'] = bcc.join(',');
      }

      final Uri uri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        AppLogger.log('Cannot launch email: $email', name: 'URL_LAUNCHER_UTIL');

        if (!context.mounted) return;

        AppSnackBar.show(
          context: context,
          message: 'cannot_open_email'.tr(),
          type: AppSnackBarType.error,
        );
      }
    } catch (e) {
      AppLogger.log('Error launching email: $e', name: 'URL_LAUNCHER_UTIL');

      if (!context.mounted) return;

      AppSnackBar.show(
        context: context,
        message: 'error_opening_email'.tr(),
        type: AppSnackBarType.error,
      );
    }
  }

  // Phone dialer
  static Future<void> launchPhone({
    required BuildContext context,
    required String phoneNumber,
  }) async {
    try {
      if (phoneNumber.isEmpty) {
        AppLogger.log(
          'Phone number is empty or not available',
          name: 'URL_LAUNCHER_UTIL',
        );

        AppSnackBar.show(
          context: context,
          message: 'phone_number_not_available'.tr(),
          type: AppSnackBarType.error,
        );

        return;
      }

      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

      final Uri uri = Uri(scheme: 'tel', path: cleanNumber);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        AppLogger.log(
          'Cannot launch phone: $phoneNumber',
          name: 'URL_LAUNCHER_UTIL',
        );

        if (!context.mounted) return;

        AppSnackBar.show(
          context: context,
          message: 'cannot_open_phone'.tr(),
          type: AppSnackBarType.error,
        );
      }
    } catch (e) {
      AppLogger.log('Error launching phone: $e', name: 'URL_LAUNCHER_UTIL');

      if (!context.mounted) return;

      AppSnackBar.show(
        context: context,
        message: 'error_opening_phone'.tr(),
        type: AppSnackBarType.error,
      );
    }
  }

  // SMS
  static Future<void> launchSMS({
    required BuildContext context,
    required String phoneNumber,
    String? message,
  }) async {
    try {
      if (phoneNumber.isEmpty) {
        AppLogger.log(
          'Phone number is empty or not available',
          name: 'URL_LAUNCHER_UTIL',
        );

        AppSnackBar.show(
          context: context,
          message: 'phone_number_not_available'.tr(),
          type: AppSnackBarType.error,
        );

        return;
      }

      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

      final Uri uri = Uri(
        scheme: 'sms',
        path: cleanNumber,
        queryParameters: message != null && message.isNotEmpty
            ? {'body': message}
            : null,
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        AppLogger.log(
          'Cannot launch SMS: $phoneNumber',
          name: 'URL_LAUNCHER_UTIL',
        );

        if (!context.mounted) return;

        AppSnackBar.show(
          context: context,
          message: 'cannot_open_sms'.tr(),
          type: AppSnackBarType.error,
        );
      }
    } catch (e) {
      AppLogger.log('Error launching SMS: $e', name: 'URL_LAUNCHER_UTIL');

      if (!context.mounted) return;

      AppSnackBar.show(
        context: context,
        message: 'error_opening_sms'.tr(),
        type: AppSnackBarType.error,
      );
    }
  }

  // Maps
  static Future<void> launchMaps({
    required BuildContext context,
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    try {
      Uri? uri;

      if (latitude != null && longitude != null) {
        uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
        );
      } else if (address != null && address.isNotEmpty) {
        final encodedAddress = Uri.encodeComponent(address);

        uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
        );
      } else {
        AppLogger.log(
          'Location is empty or not available',
          name: 'URL_LAUNCHER_UTIL',
        );

        AppSnackBar.show(
          context: context,
          message: 'location_not_available'.tr(),
          type: AppSnackBarType.error,
        );

        return;
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppLogger.log('Cannot launch maps', name: 'URL_LAUNCHER_UTIL');

        if (!context.mounted) return;

        AppSnackBar.show(
          context: context,
          message: 'cannot_open_maps'.tr(),
          type: AppSnackBarType.error,
        );
      }
    } catch (e) {
      AppLogger.log('Error launching maps: $e', name: 'URL_LAUNCHER_UTIL');

      if (!context.mounted) return;

      AppSnackBar.show(
        context: context,
        message: 'error_opening_maps'.tr(),
        type: AppSnackBarType.error,
      );
    }
  }

  // Web URL
  static Future<void> launchWebURL({
    required BuildContext context,
    required String url,
    bool inApp = false,
  }) async {
    try {
      if (url.isEmpty) {
        AppLogger.log(
          'URL is empty or not available',
          name: 'URL_LAUNCHER_UTIL',
        );

        AppSnackBar.show(
          context: context,
          message: 'url_not_available'.tr(),
          type: AppSnackBarType.error,
        );

        return;
      }

      String finalUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        finalUrl = 'https://$url';
      }

      final Uri uri = Uri.parse(finalUrl);

      final mode = inApp
          ? LaunchMode.inAppWebView
          : LaunchMode.externalApplication;

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: mode);
      } else {
        AppLogger.log('Cannot launch web URL: $url', name: 'URL_LAUNCHER_UTIL');

        if (!context.mounted) return;

        AppSnackBar.show(
          context: context,
          message: 'cannot_open_url'.tr(),
          type: AppSnackBarType.error,
        );
      }
    } catch (e) {
      AppLogger.log('Error launching web URL: $e', name: 'URL_LAUNCHER_UTIL');

      if (!context.mounted) return;

      AppSnackBar.show(
        context: context,
        message: 'error_opening_url'.tr(),
        type: AppSnackBarType.error,
      );
    }
  }
}
