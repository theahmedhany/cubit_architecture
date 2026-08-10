import '../cache/app_cache_keys.dart';
import '../cache/shared_pref_helper.dart';
import '../enums/auth_status.dart';
import '../enums/user_role.dart';

class AppConstants {
  AppConstants._();

  static const String appName = "Cubit Architecture";

  static const String appVersion = "1.0.0";

  // Authentication status of the user.
  static AuthStatus authStatus = AuthStatus.guest;

  // Current user role.
  static UserRole? get currentUserRole {
    final roleName = SharedPrefHelper.getString(key: AppCacheKeys.userRoleName);

    return UserRole.fromString(roleName);
  }
}
