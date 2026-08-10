import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../helpers/app_logger.dart';

class SocialAuthUtil {
  SocialAuthUtil._();

  static final SocialAuthUtil instance = SocialAuthUtil._();

  // Google Login
  Future<SocialAuthResponse?> loginWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize();
      final account = await GoogleSignIn.instance.authenticate();
      final auth = await account.authorizationClient.authorizeScopes(['email']);

      return SocialAuthResponse(
        id: account.id,
        email: account.email,
        name: account.displayName,
        type: SocialAuthType.google,
        accessToken: auth.accessToken,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;

      AppLogger.log('Google Sign-In Error: $e', name: 'SOCIAL_AUTH');
      throw SocialAuthException(
        message: e.toString(),
        type: SocialAuthType.google,
      );
    } catch (e, s) {
      AppLogger.log('Google Sign-In Failed: $e\n$s', name: 'SOCIAL_AUTH');
      throw SocialAuthException(
        message: e.toString(),
        type: SocialAuthType.google,
      );
    }
  }

  // Facebook Login
  Future<SocialAuthResponse?> loginWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login(
        permissions: const ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.cancelled) return null;

      if (result.status != LoginStatus.success || result.accessToken == null) {
        throw SocialAuthException(
          message: result.message ?? 'Facebook login failed',
          type: SocialAuthType.facebook,
        );
      }

      final userData = await FacebookAuth.instance.getUserData(
        fields: 'id,name,email',
      );

      return SocialAuthResponse(
        id: userData['id']?.toString() ?? '',
        email: userData['email']?.toString(),
        name: userData['name']?.toString(),
        type: SocialAuthType.facebook,
        accessToken: result.accessToken!.tokenString,
      );
    } on SocialAuthException {
      rethrow;
    } catch (e, s) {
      AppLogger.log('Facebook Sign-In Failed: $e\n$s', name: 'SOCIAL_AUTH');
      throw SocialAuthException(
        message: e.toString(),
        type: SocialAuthType.facebook,
      );
    }
  }

  // Apple Login
  Future<SocialAuthResponse?> loginWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final nameParts = [
        credential.givenName,
        credential.familyName,
      ].whereType<String>().where((s) => s.isNotEmpty).join(' ');

      return SocialAuthResponse(
        id: credential.userIdentifier ?? '',
        email: credential.email,
        name: nameParts.isEmpty ? null : nameParts,
        type: SocialAuthType.apple,
        accessToken: credential.identityToken ?? '',
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;

      AppLogger.log('Apple Sign-In Error: $e', name: 'SOCIAL_AUTH');
      throw SocialAuthException(message: e.message, type: SocialAuthType.apple);
    } catch (e, s) {
      AppLogger.log('Apple Sign-In Failed: $e\n$s', name: 'SOCIAL_AUTH');
      throw SocialAuthException(
        message: e.toString(),
        type: SocialAuthType.apple,
      );
    }
  }

  // Sign Out from all providers
  Future<void> signOut() async {
    await Future.wait([
      GoogleSignIn.instance.disconnect().catchError((_) {}),
      FacebookAuth.instance.logOut().catchError((_) {}),
    ]);
  }
}

class SocialAuthResponse {
  final String id;
  final String accessToken;
  final SocialAuthType type;
  final String? email;
  final String? name;

  const SocialAuthResponse({
    required this.id,
    required this.accessToken,
    required this.type,
    this.email,
    this.name,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'accessToken': accessToken,
    'type': type.name,
  };

  @override
  String toString() =>
      'SocialAuthResponse(id: $id, email: $email, name: $name, type: ${type.name})';
}

class SocialAuthException implements Exception {
  final String message;
  final SocialAuthType type;
  final bool canceled;

  const SocialAuthException({
    required this.message,
    required this.type,
    this.canceled = false,
  });

  @override
  String toString() => 'SocialAuthException(${type.name}): $message';
}

enum SocialAuthType { google, facebook, apple }
