import 'package:firebase_auth/firebase_auth.dart';
import '../Service/FirebaseAuthService.dart';
import '../Provider/FirebaseAuthProvider.dart';

class AuthController {
  final FirebaseAuthService _authService;
  final FirebaseAuthProvider _authProvider;

  AuthController({
    required FirebaseAuthProvider authProvider,
    FirebaseAuthService? authService,
  })  : _authProvider = authProvider,
        _authService = authService ?? FirebaseAuthService();

  String verifyPassword(String pass) {
    if (pass.length < 8) {
      return 'Password should be equal to or more than 8 characters.';
    }
    if (!pass.contains(RegExp(r'[a-z]'))) {
      return 'Password should contain at least one lowercase character.';
    }
    if (!pass.contains(RegExp(r'[A-Z]'))) {
      return 'Password should contain at least one uppercase character.';
    }
    if (!pass.contains(RegExp(r'[0-9]'))) {
      return 'Password should contain at least one number.';
    }
    if (!pass.contains(RegExp(r'[!@#$%^&*~]'))) {
      return 'Password should contain at least one special character.';
    }
    return '';
  }

  Future<bool> logIn(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _authProvider.setWarning('Please fill out all fields.');
      return false;
    }

    _authProvider.clearWarning();
    _authProvider.setLoading(true);

    try {
      final credential = await _authService.logIn(
        email: email.trim(),
        password: password.trim(),
      );
      _authProvider.setUser(credential.user);
      return true;
    } on FirebaseAuthException catch (e) {
      _authProvider.setWarning(e.message ?? 'Authentication failed.');
      return false;
    } catch (e) {
      _authProvider.setWarning(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _authProvider.setLoading(false);
    }
  }

  Future<bool> signUp(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _authProvider.setWarning('Please fill out both fields to sign up.');
      return false;
    }

    final passwordError = verifyPassword(password);
    if (passwordError.isNotEmpty) {
      _authProvider.setWarning(passwordError);
      return false;
    }

    _authProvider.clearWarning();
    _authProvider.setLoading(true);

    try {
      final credential = await _authService.signUp(
        email: email.trim(),
        password: password.trim(),
      );
      _authProvider.setUser(credential.user);
      return true;
    } on FirebaseAuthException catch (e) {
      _authProvider.setWarning(e.message ?? 'Sign up failed.');
      return false;
    } catch (e) {
      _authProvider.setWarning(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _authProvider.setLoading(false);
    }
  }

  Future<void> logOut() async {
    await _authService.logOut();
    _authProvider.setUser(null);
  }

  Future<bool> confirmCurrentPassword(String password) async {
    if (password.trim().isEmpty) {
      _authProvider.setWarning('Please enter your current password.');
      return false;
    }

    _authProvider.clearWarning();
    _authProvider.setLoading(true);

    try {
      await _authService.confirmCurrentPassword(password);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        _authProvider.setWarning('The current password entered is incorrect.');
      } else {
        _authProvider.setWarning(e.message ?? 'Confirmation failed.');
      }
      return false;
    } catch (e) {
      _authProvider.setWarning(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _authProvider.setLoading(false);
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    if (newPassword.trim().isEmpty) {
      _authProvider.setWarning('Please enter your new password.');
      return false;
    }

    final passwordError = verifyPassword(newPassword);
    if (passwordError.isNotEmpty) {
      _authProvider.setWarning(passwordError);
      return false;
    }

    _authProvider.clearWarning();
    _authProvider.setLoading(true);

    try {
      await _authService.updatePassword(newPassword);
      return true;
    } on FirebaseAuthException catch (e) {
      _authProvider.setWarning(e.message ?? 'Failed to update password.');
      return false;
    } catch (e) {
      _authProvider.setWarning(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _authProvider.setLoading(false);
    }
  }
}
