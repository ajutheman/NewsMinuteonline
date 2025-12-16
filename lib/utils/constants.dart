class Constants {
  static const String baseUrl = String.fromEnvironment(
    'API_URL', 
    defaultValue: 'https://newsminutebackend.onrender.com/api'
  );
  static const String appName = 'NewsMinute';
}
