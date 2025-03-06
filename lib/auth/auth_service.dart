import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_form.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "161632162529-vn1aqdd2f9nkj3ocvinadg0cah9n787l.apps.googleusercontent.com",
    scopes: ['email', 'profile'],
  );

  String? _userName;
  String? _userEmail;
  bool _isLoading = false; // 로딩 상태 추가

  bool get isLoggedIn => _userName != null && _userEmail != null;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading; // 로딩 상태 getter

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName');
    _userEmail = prefs.getString('userEmail');
  }

  Future<void> saveUserData(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    _isLoading = true;
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("Google Sign-In cancelled.");
        _isLoading = false;
        return;
      }

      _userName = googleUser.displayName;
      _userEmail = googleUser.email;

      final response = await http.post(
        Uri.parse("http://localhost:5000/api/auth/google-signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _userEmail,
          "name": _userName,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _userName = data['user']['name'];
        _userEmail = data['user']['email'];
        await saveUserData(_userName!, _userEmail!);
      } else if (response.statusCode == 409) {
        _userName = googleUser.displayName;
        _userEmail = googleUser.email;
        await saveUserData(_userName!, _userEmail!);
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
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
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
    }
  }

  Future<void> signUpWithEmail(String email, String password, BuildContext context) async {
    _isLoading = true;
    try {
      final response = await http.post(
        Uri.parse("http://localhost:5000/api/auth/signup"),
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
        await saveUserData(_userName!, _userEmail!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign-Up successful!")),
        );
      } else if (response.statusCode == 409) {
        throw Exception("Email already exists. Please sign in or use a different email.");
      } else {
        throw Exception("Sign-Up failed: ${response.body}");
      }
    } catch (error) {
      print("Email Sign-Up Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-Up Error: $error")),
      );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> signInWithEmail(String email, String password, BuildContext context) async {
    _isLoading = true;
    try {
      final response = await http.post(
        Uri.parse("http://localhost:5000/api/auth/signin"),
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
        await saveUserData(_userName!, _userEmail!);
      } else if (response.statusCode == 401) {
        showAccountNotFoundDialog(email, context);
      } else {
        throw Exception("Sign-In failed: ${response.body}");
      }
    } catch (error) {
      print("Email Sign-In Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-In Error: $error")),
      );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> sendUserDataToBackend(String email, String authType) async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/auth/user"),
        headers: {"X-User-Email": email},
      );

      if (response.statusCode != 200) {
        print("Failed to send user data to backend: ${response.body}");
      }
    } catch (e) {
      print("Error sending user data to backend: $e");
    }
  }

  Future<void> deleteUser(BuildContext context) async {
    if (_userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No user is currently signed in.")),
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Delete',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to delete the account for ${_userEmail}? This action cannot be undone.',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.white, width: 2),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
      ),
    );

    if (confirm == true) {
      _isLoading = true;
      try {
        final response = await http.delete(
          Uri.parse("http://localhost:5000/api/auth/delete-user"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": _userEmail,
          }),
        );

        if (response.statusCode == 200) {
          await signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Account deleted successfully")),
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
      }
    }
  }

  void showAccountNotFoundDialog(String email, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Account Not Found',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'The email "$email" is not registered.',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Would you like to create a new account?',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'No',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showAuthDialog(context, switchToSignUp: true, prefillEmail: email);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.white, width: 2),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'Yes, Sign Up',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showAuthDialog(BuildContext context, {bool switchToSignUp = false, String? prefillEmail}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Up / Sign In',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: AuthForm(
          onSignUp: (email, password) => signUpWithEmail(email, password, context),
          onSignIn: (email, password) => signInWithEmail(email, password, context),
          initialSignUp: switchToSignUp,
          prefillEmail: prefillEmail,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}