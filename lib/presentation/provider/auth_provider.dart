import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // साइन अप का फंक्शन जिसे हम UI (Screen) से कॉल करेंगे
  Future<void> signUpUser(String email, String password, String name, String mobile) async {
    _isLoading = true;
    notifyListeners(); // UI को बताओ कि लोडिंग शुरू हो गई है

    try {
      await _authRepository.signUp(email: email, password: password, name: name, mobile: mobile);
    } finally {
      _isLoading = false;
      notifyListeners(); // UI को बताओ कि लोडिंग खत्म हुई
    }
  }
}
