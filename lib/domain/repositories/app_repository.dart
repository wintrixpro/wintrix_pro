abstract class AppRepository {
  /// Firebase से लेटेस्ट वर्जन कोड और APK URL फेच करता है
  Future<Map<String, dynamic>?> checkAppUpdate();

  /// SharedPreferences से यूजर का ईमेल गेट करता है
  Future<String?> getUserEmail();

  /// यूजर का FCM टोकन अपडेट करता है और रियल-टाइम प्रेजेंस (Online/Offline) सेट करता है
  Future<void> configureUserPresenceAndToken(String email);
}
