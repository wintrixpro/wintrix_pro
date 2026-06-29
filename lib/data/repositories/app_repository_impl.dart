import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/app_repository.dart';

class AppRepositoryImpl implements AppRepository {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  @override
  Future<Map<String, dynamic>?> checkAppUpdate() async {
    try {
      final snapshot = await _db.ref().child('app_update').get();
      if (snapshot.exists && snapshot.value is Map) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
    } catch (_) {
      // क्रैश रोकने के लिए साइलेंट कैच
    }
    return null;
  }

  @override
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userEmail");
  }

  @override
  Future<void> configureUserPresenceAndToken(String email) async {
    final safeProfileKey = email.replaceAll(".", "_dot_").replaceAll("@", "_at_");
    final profileRef = _db.ref("profiles").child(safeProfileKey);

    try {
      // FCM टोकन मैनेजमेंट
      final token = await _fcm.getToken();
      if (token != null) {
        await profileRef.child("fcmToken").set(token);
      }
    } catch (_) {}

    // प्रेजेंस सिस्टम लॉजिक (Online/Offline Status)
    await profileRef.child("status").set("online");
    await profileRef.child("status").onDisconnect().set("offline");
  }
}
