/// Central place for API configuration.
///
/// Swap [baseUrl] per environment, e.g. via --dart-define=API_BASE_URL=...
/// so you don't have to touch this file when moving from Yosef's local/staging
/// server to production.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://emergency-grad.duckdns.org/api' ;
  //String.fromEnvironment(
  //  'API_BASE_URL',
  //  defaultValue: 'https://emergency-grad.duckdns.org/api',
  //);

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
