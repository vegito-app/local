class Config {
  static const String backendUrl = String.fromEnvironment(
    'APPLICATION_BACKEND_URL',
    defaultValue:
        'https://dev-moov-dev-europe-west1-application-backend-5ollyxkdkq-ew.a.run.app',
  );
}
