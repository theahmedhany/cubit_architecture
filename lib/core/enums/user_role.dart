enum UserRole {
  user('user'),
  admin('admin');

  const UserRole(this.apiValue);

  final String apiValue;

  static UserRole? fromString(String? role) {
    if (role == null) return null;

    final normalized = role.toLowerCase();

    for (final r in UserRole.values) {
      if (r.apiValue == normalized) return r;
    }

    return null;
  }
}
