import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:html' as html;

enum LoginType { google, email }

class AuthForm extends StatefulWidget {
  final Future<void> Function(String email, String password) onSignUp;
  final Future<void> Function(String email, String password) onSignIn;
  final bool initialSignUp;
  final String? prefillEmail;
  final LoginType loginType;

  const AuthForm({
    super.key,
    required this.onSignUp,
    required this.onSignIn,
    this.initialSignUp = false,
    this.prefillEmail,
    this.loginType = LoginType.email,
  });

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  late bool _isSignUp;
  late bool _isLoading;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscureText = true;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialSignUp;
    _isLoading = false;
    _emailController = TextEditingController(text: widget.prefillEmail ?? '');
    _passwordController = TextEditingController();
    _loadStoredCredentials();
  }

  Future<void> _loadStoredCredentials() async {
    final emailKey = widget.loginType == LoginType.google ? 'googleEmail' : 'emailEmail';
    final passwordKey = widget.loginType == LoginType.google ? 'googlePassword' : 'emailPassword';
    final email = await _storage.read(key: emailKey);
    final password = await _storage.read(key: passwordKey);
    if (email != null) {
      _emailController.text = email;
    }
    if (password != null) {
      _passwordController.text = password;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final emailKey = widget.loginType == LoginType.google ? 'googleEmail' : 'emailEmail';
        final passwordKey = widget.loginType == LoginType.google ? 'googlePassword' : 'emailPassword';
        await _storage.write(key: emailKey, value: _emailController.text.trim());
        await _storage.write(key: passwordKey, value: _passwordController.text.trim());

        final formElement = html.document.querySelector('form');
        if (formElement != null) {
          final submitEvent = html.Event('submit');
          formElement.dispatchEvent(submitEvent);
        }

        await (_isSignUp
            ? widget.onSignUp(_emailController.text.trim(), _passwordController.text.trim())
            : widget.onSignIn(_emailController.text.trim(), _passwordController.text.trim()));
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      onChanged: () {
        _formKey.currentState?.validate();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: 'Enter your email',
              hintStyle: GoogleFonts.roboto(
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            autofillHints: widget.loginType == LoginType.google
                ? const [AutofillHints.newUsername, AutofillHints.email] // newEmail -> email
                : const [AutofillHints.username, AutofillHints.email],
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 16,
            ),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: 'Enter your password',
              hintStyle: GoogleFonts.roboto(
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
              suffixIcon: IconButton(
                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
            obscureText: _obscureText,
            autofillHints: widget.loginType == LoginType.google
                ? const [AutofillHints.newPassword]
                : const [AutofillHints.password], // currentPassword -> password
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 16,
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const CircularProgressIndicator()
              : Semantics(
                  button: true,
                  label: _isSignUp ? 'Sign Up' : 'Sign In',
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Text(
                      _isSignUp ? 'Sign Up' : 'Sign In',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              setState(() {
                _isSignUp = !_isSignUp;
              });
            },
            child: Text(
              _isSignUp ? 'Already have an account? Sign In' : 'Need an account? Sign Up',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}