import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _sessionKey = 'session_timestamp';

  User? get currentUser => _auth.currentUser;

  Future<User?> signUp(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        await _storeSession();
      }
      return userCredential.user;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        await _storeSession();
      }
      return userCredential.user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> signOut() async {
    await _clearSession();
    await _auth.signOut();
  }

  Future<void> _storeSession() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_sessionKey, timestamp);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_sessionKey);
    if (timestamp == null) return false;

    final sessionDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    const sessionDuration = Duration(days: 7);
    return now.difference(sessionDate) <= sessionDuration;
  }
}
