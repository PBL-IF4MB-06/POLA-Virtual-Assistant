/// OAuth 2.0 client IDs from [Google Cloud Console](https://console.cloud.google.com/apis/credentials).
///
/// Web: create an **Web application** OAuth client; pass its ID as [webClientId].
/// Android / iOS: often need [serverClientId] set to the **same Web client** ID so
/// `google_sign_in` can complete the OAuth flow correctly.
///
/// Example:
/// `flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=xxx.apps.googleusercontent.com --dart-define=GOOGLE_SERVER_CLIENT_ID=xxx.apps.googleusercontent.com`
abstract final class GoogleOauthConfig {
  static const webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  static const serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );
}
