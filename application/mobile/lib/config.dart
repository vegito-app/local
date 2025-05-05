class Config {
  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue:
        'https://dev-moov-dev-europe-west1-application-backend-5ollyxkdkq-ew.a.run.app',
  );
}
