import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps [FlutterSecureStorage] so the rest of the app never talks to the
/// storage plugin directly.
///
/// Stores:
///  - `auth_token`   the final bearer token returned by /auth/login,
///                    /auth/verify-code and /auth/password/reset.
///  - `temp_token`   the short-lived token used while an OTP flow is in
///                    progress (register-pending-verification or
///                    password-reset-pending-verification).
///  - `user_email` / `user_name`
///                    NOTE: the backend does not yet expose a GET /me (or
///                    similar) endpoint, so there is no way to fetch the
///                    logged-in user's profile after app restart. Until
///                    Yosef adds one, we cache the email/name locally at
///                    sign up / login time purely so screens like Settings
///                    have something to show. Treat this as a stopgap.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _authTokenKey = 'auth_token';
  static const _tempTokenKey = 'temp_token';
  static const _userEmailKey = 'user_email';
  static const _userNameKey = 'user_name';

  Future<void> saveAuthToken(String token) =>
      _storage.write(key: _authTokenKey, value: token);

  Future<String?> readAuthToken() => _storage.read(key: _authTokenKey);

  Future<void> saveTempToken(String token) =>
      _storage.write(key: _tempTokenKey, value: token);

  Future<String?> readTempToken() => _storage.read(key: _tempTokenKey);

  Future<void> clearTempToken() => _storage.delete(key: _tempTokenKey);

  Future<void> saveProfile({required String email, String? name}) async {
    await _storage.write(key: _userEmailKey, value: email);
    if (name != null) {
      await _storage.write(key: _userNameKey, value: name);
    }
  }

  Future<String?> readEmail() => _storage.read(key: _userEmailKey);

  Future<String?> readName() => _storage.read(key: _userNameKey);

  Future<bool> get isLoggedIn async => (await readAuthToken()) != null;

  /// Call on logout (and on any 401 the app receives).
  Future<void> clearAll() async {
    await _storage.delete(key: _authTokenKey);
    await _storage.delete(key: _tempTokenKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _userNameKey);
  }
}
