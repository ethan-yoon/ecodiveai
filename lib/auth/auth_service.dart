import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_form.dart';

class AuthService with ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "161632162529-vn1aqdd2f9nkj3ocvinadg0cah9n787l.apps.googleusercontent.com",
    scopes: ['email', 'profile'],
  );

  final _storage = const FlutterSecureStorage();
  //String BackendUrl = "http://localhost:5000";
  String BackendUrl = "http://ecodiveai.duckdns.org:5000";

  String? _userName;
  String? _userEmail;
  String? _lastUsedEmail;
  bool _isLoading = false;

  bool get isLoggedIn => _userName != null && _userEmail != null;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;

  AuthService() {
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName');
    _userEmail = prefs.getString('userEmail');
    _lastUsedEmail = await _storage.read(key: 'emailEmail'); // 메일 계정 기준
    notifyListeners();
  }

  Future<void> saveUserData(String name, String email, {LoginType loginType = LoginType.email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    final emailKey = loginType == LoginType.google ? 'googleEmail' : 'emailEmail';
    final passwordKey = loginType == LoginType.google ? 'googlePassword' : 'emailPassword';
    await _storage.write(key: emailKey, value: email);
    // 비밀번호는 로그인 성공 시 저장하도록 호출부에서 처리
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("Google Sign-In cancelled.");
        _isLoading = false;
        notifyListeners();
        return;
      }

      _userName = googleUser.displayName;
      _userEmail = googleUser.email;

      final response = await http.post(
        Uri.parse("$BackendUrl/api/auth/google-signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _userEmail,
          "name": _userName,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 409) {
        _userName = googleUser.displayName;
        _userEmail = googleUser.email;
        await saveUserData(_userName!, _userEmail!, loginType: LoginType.google);
      } else {
        throw Exception("Google Sign-Up failed: ${response.body}");
      }
    } catch (error) {
      print("Google Sign-In Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-In Error: $error")),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _googleSignIn.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userName');
      await prefs.remove('userEmail');
      _userName = null;
      _userEmail = null;
      print("User signed out.");
    } catch (error) {
      print("Sign-Out Error: $error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithEmail(String email, String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      print("SignIn Request: email=$email, password=$password");
      final response = await http.post(
        Uri.parse("$BackendUrl/api/auth/signin"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userName = data['user']['name'];
        _userEmail = email;
        await saveUserData(_userName!, _userEmail!, loginType: LoginType.email);
        await _storage.write(key: 'emailPassword', value: password);
      } else if (response.statusCode == 401) {
        showAccountNotFoundDialog(email, context);
      } else {
        throw Exception("Sign-In failed: ${response.body}");
      }
    } catch (error) {
      print("Email Sign-In Error: $error");
      throw error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmail(String email, String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse("$BackendUrl/api/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "name": email.split('@')[0],
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _userName = data['user']['name'];
        _userEmail = email;
        await saveUserData(_userName!, _userEmail!, loginType: LoginType.email);
        await _storage.write(key: 'emailPassword', value: password);
      } else if (response.statusCode == 409) {
        throw Exception("Email already exists.");
      } else {
        throw Exception("Sign-Up failed: ${response.body}");
      }
    } catch (error) {
      print("Email Sign-Up Error: $error");
      throw error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(BuildContext context) async {
    if (_userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user is currently signed in.")),
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete the account for $_userEmail?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _isLoading = true;
      notifyListeners();
      try {
        final response = await http.delete(
          Uri.parse("$BackendUrl/api/auth/delete-user"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"email": _userEmail}),
        );

        if (response.statusCode == 200) {
          await signOut();
          await _storage.delete(key: 'emailEmail');
          await _storage.delete(key: 'emailPassword');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account deleted successfully")),
          );
        } else {
          throw Exception("Delete failed: ${response.body}");
        }
      } catch (error) {
        print("Delete User Error: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Delete Error: $error")),
        );
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void showAuthDialog(BuildContext context, {bool switchToSignUp = false, String? prefillEmail, LoginType loginType = LoginType.email}) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.white,
          dialogBackgroundColor: Colors.white,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.black),
          ),
        ),
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            switchToSignUp ? 'Sign Up' : 'Sign In',
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: SizedBox(
            width: 300,
            child: AuthForm(
              onSignUp: (email, password) => signUpWithEmail(email, password, context),
              onSignIn: (email, password) => signInWithEmail(email, password, context),
              initialSignUp: switchToSignUp,
              prefillEmail: prefillEmail ?? _lastUsedEmail,
              loginType: loginType, // 로그인 타입 전달
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAccountNotFoundDialog(String email, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Theme(
        data: ThemeData.light(),
        child: AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Account Not Found',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            'The email "$email" is not registered. Would you like to sign up?',
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No', style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showAuthDialog(context, switchToSignUp: true, prefillEmail: email, loginType: LoginType.email);
              },
              child: const Text('Yes, Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
