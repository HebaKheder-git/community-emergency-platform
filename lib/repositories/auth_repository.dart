import '../core/api_client.dart';
import '../core/token_storage.dart';
import '../models/me_result.dart';

/// One method per request in the Postman collection's "Auth" folder.
///
/// IMPORTANT — current backend limitations (see the linking notes doc for
/// details), all of which affect how the Flutter screens must behave:
///  1. `/auth/register` and `/auth/login` only accept `email`, not phone.
///     There is no phone-based sign up / login endpoint yet.
///  2. `/auth/password/forgot` only accepts `email` — no SMS/phone password
///     reset endpoint yet.
///  3. There is no Google/Facebook OAuth endpoint yet (matches your note).
///  4. There is no GET /me (or similar) endpoint to fetch the logged-in
///     user's profile — we only get back a bearer token. Name/email are
///     cached locally as a stopgap (see TokenStorage).
///  5. There is no identity-verification endpoint in this collection, so
///     the "verified account" flow (VerificationStatus) still can't be
///     wired to a real backend yet — that will need its own endpoints.
class AuthRepository {
  AuthRepository({ApiClient? apiClient, TokenStorage? tokenStorage})
      : _api = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final ApiClient _api;
  final TokenStorage _tokenStorage;

  // ── Sign up ────────────────────────────────────────────────────────────

  /// POST /auth/register
  /// Returns the `temp_token` used to verify the OTP that was just sent.
  Future<String> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await _api.post('/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    final tempToken = res['temp_token'] as String;
    await _tokenStorage.saveTempToken(tempToken);
    await _tokenStorage.saveProfile(email: email, name: name);
    return tempToken;
  }

  /// POST /auth/verify-code — confirms the sign-up OTP.
  /// Returns the final auth `token` and persists it.
  /// POST /auth/verify-code — confirms the sign-up OTP.
/// temp_token now goes in a custom header, NOT the body.
Future<String> verifyRegistrationCode({
    required String verificationCode,
    required String tempToken,
  }) async {
    final res = await _api.post(
      '/auth/verify-code',
      body: {'verification_code': verificationCode},
      headers: {'temp_token': tempToken},
    );
    final token = res['token'] as String;
    await _tokenStorage.saveAuthToken(token);
    await _tokenStorage.clearTempToken();
    return token;
  }

  /// POST /auth/resend — temp_token now goes in a custom header, no body.
  Future<void> resendOtp({required String tempToken}) async {
    await _api.post('/auth/resend', headers: {'temp_token': tempToken});
  }


  // ── Login / logout ────────────────────────────────────────────────────

  /// POST /auth/login (email + password only — see class doc).
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    final token = res['token'] as String;
    await _tokenStorage.saveAuthToken(token);
    await _tokenStorage.saveProfile(email: email);
    return token;
  }

  /// POST /auth/logout (Authorization header is attached automatically).
  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } finally {
      // Always clear local session even if the request itself failed
      // (e.g. token already expired) — don't strand the user logged in.
      await _tokenStorage.clearAll();
    }
  }

  // ── Password reset (email only) ───────────────────────────────────────

  /// POST /auth/password/forgot — returns a temp_token for the OTP step.
  Future<String> forgotPassword({required String email}) async {
    final res = await _api.post('/auth/password/forgot', body: {
      'email': email,
    });
    return res['temp_token'] as String;
  }

  /// POST /auth/password/verify — confirms the reset OTP.
  /// Returns a (possibly refreshed) temp_token to use for the final step.
  Future<String> verifyPasswordResetOtp({
    required String otpCode,
    required String tempToken,
  }) async {
    final res = await _api.post('/auth/password/verify', body: {
      'otp_code': otpCode,
      'temp_token': tempToken,
    });
    return res['temp_token'] as String;
  }

  /// POST /auth/password/reset — sets the new password.
  /// Returns the final auth `token` and logs the user in.
  Future<String> resetPassword({
    required String password,
    required String passwordConfirmation,
    required String tempToken,
  }) async {
    final res = await _api.post('/auth/password/reset', body: {
      'password': password,
      'password_confirmation': passwordConfirmation,
      'temp_token': tempToken,
    });
    final token = res['token'] as String;
    await _tokenStorage.saveAuthToken(token);
    return token;
  }

  // ── Profile / roles ────────────────────────────────────────────────────

/// GET /auth/me — the endpoint that didn't exist before. Use this both to
/// validate a locally-stored token on app start, and to get real
/// name/email/roles instead of the TokenStorage-cached stopgap values.
  Future<MeResult> getMe() async {
    final res = await _api.get('/auth/me');
    final user = res['user'] as Map<String, dynamic>;
    final roles = (res['roles'] as List? ?? [])
        .map((e) => e.toString())
        .toList();
    final permissions = (res['permissions'] as List? ?? [])
        .map((e) => e.toString())
        .toList();

    await _tokenStorage.saveProfile(
      email: user['email'] as String,
      name: user['name'] as String?,
    );

    return MeResult(
      id: user['id'] as int,
      name: user['name'] as String?,
      email: user['email'] as String,
      roles: roles,
      permissions: permissions,
    );
  }
}
