class Config {
  static const String backendUrl = String.fromEnvironment(
    'APPLICATION_BACKEND_URL',
    defaultValue:
        'https://dev-moov-dev-europe-west1-application-backend-5ollyxkdkq-ew.a.run.app',
  );
  static const String cdnPublicPrefix = String.fromEnvironment(
    'APPLICATION_CDN_PUBLIC_PREFIX',
    defaultValue: 'http://34.98.82.137/',
  );
  static const String firebaseStoragePublicPrefix = String.fromEnvironment(
    'FIREBASE_STORAGE_PUBLIC_PREFIX',
    defaultValue:
        'https://firebasestorage.googleapis.com/v0/b/moov-438615.appspot.com/o',
  );
}
