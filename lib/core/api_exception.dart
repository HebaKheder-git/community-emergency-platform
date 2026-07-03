/// Thrown by [ApiClient] / repositories whenever a request fails.
///
/// Mirrors Laravel's default error shape:
/// ```json
/// { "message": "The email has already been taken.",
///   "errors": { "email": ["The email has already been taken."] } }
/// ```
/// [fieldErrors] is populated only when the backend returns a 422 with an
/// `errors` map (form validation). Otherwise it's empty and [message] is the
/// only thing you show the user.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, List<String>> fieldErrors;

  const ApiException(
    this.message, {
    this.statusCode,
    this.fieldErrors = const {},
  });

  /// Convenience getter for the first error of a given field, e.g.
  /// `error.fieldError('email')` inside a TextFormField validator.
  String? fieldError(String field) =>
      fieldErrors[field]?.isNotEmpty == true ? fieldErrors[field]!.first : null;

  @override
  String toString() => message;
}
