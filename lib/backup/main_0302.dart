import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart'; // Roboto 글꼴 사용 위해 추가
import 'package:shared_preferences/shared_preferences.dart'; // 로컬 저장소
import 'package:http/http.dart' as http;
import 'dart:convert';

// 새로운 Feature 상세 페이지
class FeatureDetailPage extends StatelessWidget {
  final String featureTitle;
  final String featureDescription;

  const FeatureDetailPage({super.key, required this.featureTitle, required this.featureDescription});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          featureTitle,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF0277BD), // 깊은 청색 (바다)
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              featureTitle,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Text(
              featureDescription,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context), // 뒤로 가기
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.white, width: 2),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                'Back to Features',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent, // 배경 투명
    );
  }
}

void main() {
  runApp(EcoDiveAIApp());
}

class EcoDiveAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoDive AI',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF0277BD), // 깊은 청색 (바다)
        scaffoldBackgroundColor: Colors.transparent, // 배경을 투명으로 설정 (바다 이미지 기반)
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontFamily: GoogleFonts.roboto().fontFamily, // Roboto 글꼴
            fontSize: 36,
            fontWeight: FontWeight.bold, // 두꺼운 글꼴
            color: Colors.black, // 더 진한 검정색
          ),
          bodyMedium: TextStyle(
            fontFamily: GoogleFonts.roboto().fontFamily, // Roboto 글꼴
            fontSize: 16,
            fontWeight: FontWeight.bold, // 두꺼운 글꼴
            color: Colors.black, // 더 진한 검정색
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white), // 버튼 색상 흰색으로 변경
            foregroundColor: MaterialStateProperty.all(Colors.black), // 버튼 텍스트 검정색으로 변경
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // 둥근 모서리
                side: BorderSide(color: Colors.white, width: 2), // 흰색 테두리 추가
              ),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF4FC3F7), // 밝은 청색 (밤 바다)
        scaffoldBackgroundColor: Colors.transparent, // 배경을 투명으로 설정 (밤 바다 이미지 기반)
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontFamily: GoogleFonts.roboto().fontFamily, // Roboto 글꼴
            fontSize: 36,
            fontWeight: FontWeight.bold, // 두꺼운 글꼴
            color: Colors.white, // 밝은 색상 유지 (다크 모드)
          ),
          bodyMedium: TextStyle(
            fontFamily: GoogleFonts.roboto().fontFamily, // Roboto 글꼴
            fontSize: 16,
            fontWeight: FontWeight.bold, // 두꺼운 글꼴
            color: Colors.white, // 밝은 색상 유지 (다크 모드)
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.white),
            foregroundColor: MaterialStateProperty.all(Colors.black),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // 둥근 모서리
                side: BorderSide(color: Colors.white, width: 2), // 흰색 테두리 추가
              ),
            ),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: EcoDiveHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class EcoDiveHomePage extends StatefulWidget {
  @override
  _EcoDiveHomePageState createState() => _EcoDiveHomePageState();
}

class _EcoDiveHomePageState extends State<EcoDiveHomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "161632162529-vn1aqdd2f9nkj3ocvinadg0cah9n787l.apps.googleusercontent.com", // 웹용 클라이언트 ID
    scopes: ['email', 'profile'],
  );

  String? _userName;
  String? _userEmail;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _isScrolled = _scrollController.offset > 50;
      });
    });
    _loadUserData(); // 로컬 저장소에서 사용자 데이터 로드
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName');
      _userEmail = prefs.getString('userEmail');
    });
  }

  Future<void> _saveUserData(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("Google Sign-In cancelled.");
        setState(() => _isLoading = false);
        return;
      }

      // 사용자 정보 가져오기
      _userName = googleUser.displayName;
      _userEmail = googleUser.email;

      // 백엔드에 Google 사용자 정보 전송 및 저장
      final response = await http.post(
        Uri.parse("http://localhost:5000/api/auth/google-signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _userEmail,
          "name": _userName,
        }),
      );

      if (response.statusCode == 201) { // 성공적으로 등록된 경우
        final data = jsonDecode(response.body);
        _userName = data['user']['name'];
        _userEmail = data['user']['email'];
        await _saveUserData(_userName!, _userEmail!); // 로컬에 저장
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Sign-In successful!")),
        );
      } else if (response.statusCode == 409) { // 이메일 중복
        _userName = googleUser.displayName;
        _userEmail = googleUser.email;
        await _saveUserData(_userName!, _userEmail!); // 로컬에 저장 (중복 허용)
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Email already exists. Signed in as existing user.")),
        );
      } else {
        throw Exception("Google Sign-Up failed: ${response.body}");
      }
    } catch (error) {
      print("Google Sign-In Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-In Error: $error")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await _googleSignIn.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userName');
      await prefs.remove('userEmail');
      setState(() {
        _userName = null;
        _userEmail = null;
      });
      print("User signed out.");
    } catch (error) {
      print("Sign-Out Error: $error");
    }
  }

  Future<void> _signUpWithEmail(String email, String password) async {
    setState(() => _isLoading = true);
    try {
      // 백엔드에 새 사용자 등록 요청
      final response = await http.post(
        Uri.parse("http://localhost:5000/api/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "name": email.split('@')[0], // 기본 이름으로 이메일 사용자 이름 사용
        }),
      );

      if (response.statusCode == 201) { // 성공적으로 등록된 경우
        final data = jsonDecode(response.body);
        _userName = data['user']['name'];
        _userEmail = email;
        await _saveUserData(_userName!, _userEmail!); // 로컬에 저장
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign-Up successful!")),
        );
      } else if (response.statusCode == 409) { // 이메일 중복
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
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithEmail(String email, String password) async {
    setState(() => _isLoading = true);
    try {
      // 백엔드에 로그인 요청
      final response = await http.post(
        Uri.parse("http://localhost:5000/api/auth/signin"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) { // 성공적으로 로그인된 경우
        final data = jsonDecode(response.body);
        _userName = data['user']['name'];
        _userEmail = email;
        await _saveUserData(_userName!, _userEmail!); // 로컬에 저장
        setState(() {});
      } else if (response.statusCode == 401) { // 로그인 실패 (계정 없음)
        _showAccountNotFoundDialog(email);
      } else {
        throw Exception("Sign-In failed: ${response.body}");
      }
    } catch (error) {
      print("Email Sign-In Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-In Error: $error")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendUserDataToBackend(String email, String authType) async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/auth/user"),
        headers: {"X-User-Email": email}, // 간단한 인증 헤더 (실제로는 JWT 사용 권장)
      );

      if (response.statusCode != 200) {
        print("Failed to send user data to backend: ${response.body}");
      }
    } catch (e) {
      print("Error sending user data to backend: $e");
    }
  }

  Future<void> _deleteUser() async {
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
      setState(() => _isLoading = true);
      try {
        final response = await http.delete(
          Uri.parse("http://localhost:5000/api/auth/delete-user"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": _userEmail,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          await _signOut(); // 계정 삭제 후 로그아웃
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
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
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAccountNotFoundDialog(String email) {
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
              _showAuthDialog(switchToSignUp: true, prefillEmail: email);
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

  void _showAuthDialog({bool switchToSignUp = false, String? prefillEmail}) {
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
          onSignUp: _signUpWithEmail,
          onSignIn: _signInWithEmail,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 배경을 투명으로 설정
      body: Stack(
        children: [
          // 전체 배경 이미지 (수중 바다 이미지)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/ocean_background.jpg'), // 로컬 자산 사용
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.dstATop), // 검정 오버레이 (이미지 위에 어두운 효과)
              ),
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildHeroSection(context),
                _buildAboutSection(),
                if (_userName != null) _buildFeaturesSection(), // 로그인 상태에서만 Features 표시
                _buildCommunitySection(),
                _buildContactSection(),
                _buildFooter(),
              ],
            ),
          ),
          // AppBar를 Stack 위에 오버레이
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: _isScrolled ? Color(0xFF0277BD) : Colors.transparent,
              elevation: _isScrolled ? 4 : 0,
              title: Text(
                'EcoDive AI',
                style: TextStyle(
                  fontFamily: 'Roboto', // Roboto 글꼴
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold, // AppBar 제목도 두껍게
                ),
              ),
              actions: [
                if (_userName != null) // 로그인 상태일 때만 "Sign Out" 및 "Delete Account" 버튼 표시
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: _signOut,
                    tooltip: "Sign Out",
                  ),
                if (_userName != null)
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: _deleteUser,
                    tooltip: "Delete Account",
                  ),
                _buildNavItem(context, 'Home', () => _scrollToSection(0)),
                _buildNavItem(context, 'About', () => _scrollToSection(1)),
                if (_userName != null) _buildNavItem(context, 'Features', () => _scrollToSection(2)),
                _buildNavItem(context, 'Community', () => _scrollToSection(3)),
                _buildNavItem(context, 'Contact', () => _scrollToSection(4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Roboto', // Roboto 글꼴
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold, // 네비게이션 텍스트도 두껍게
          ),
        ),
      ),
    );
  }

  void _scrollToSection(int index) {
    double offset;
    switch (index) {
      case 0:
        offset = 0;
        break;
      case 1:
        offset = MediaQuery.of(context).size.height * 0.9;
        break;
      case 2:
        offset = MediaQuery.of(context).size.height * 1.8;
        break;
      case 3:
        offset = MediaQuery.of(context).size.height * 2.7;
        break;
      case 4:
        offset = MediaQuery.of(context).size.height * 3.6;
        break;
      default:
        offset = 0;
    }
    _scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      color: Colors.black, // 검정 배경
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(seconds: 1),
              child: Text(
                'Dive Smarter, Protect Our Oceans',
                style: TextStyle(
                  fontFamily: 'Roboto', // Roboto 글꼴
                  fontSize: 48, // 더 큰 제목 크기
                  fontWeight: FontWeight.bold, // 두꺼운 글꼴
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'EcoDive AI combines cutting-edge artificial intelligence with sustainable diving practices to protect marine ecosystems while enhancing your underwater experience.',
              style: TextStyle(
                fontFamily: 'Roboto', // Roboto 글꼴
                fontSize: 18, // 설명 텍스트 크기
                fontWeight: FontWeight.bold, // 두꺼운 글꼴
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            if (_userName == null) // 로그인되지 않은 상태에서만 버튼 표시
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _signInWithGoogle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // 버튼 배경 흰색으로 변경
                      foregroundColor: Colors.black, // 버튼 텍스트 검정색으로 변경
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // 둥근 모서리
                        side: BorderSide(color: Colors.white, width: 2), // 흰색 테두리 추가
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16), // 버튼 크기 조정
                    ),
                    child: Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontFamily: 'Roboto', // Roboto 글꼴
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // 두꺼운 글꼴
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showAuthDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // 버튼 배경 흰색으로 변경
                      foregroundColor: Colors.black, // 버튼 텍스트 검정색으로 변경
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // 둥근 모서리
                        side: BorderSide(color: Colors.white, width: 2), // 흰색 테두리 추가
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16), // 버튼 크기 조정
                    ),
                    child: Text(
                      'Sign Up / Sign In with Email',
                      style: TextStyle(
                        fontFamily: 'Roboto', // Roboto 글꼴
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // 두꺼운 글꼴
                      ),
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    'Welcome, $_userName!',
                    style: TextStyle(
                      fontFamily: 'Roboto', // Roboto 글꼴
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Email: $_userEmail',
                    style: TextStyle(
                      fontFamily: 'Roboto', // Roboto 글꼴
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8), // 약간 투명한 흰색 배경 (바다 이미지 보임)
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'About EcoDive AI',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontFamily: 'Roboto', // Roboto 글꼴
                  color: Colors.black, // 더 진한 검정색
                  fontWeight: FontWeight.bold, // 두꺼운 글꼴
                ),
          ),
          SizedBox(height: 20),
          Text(
            'EcoDive AI is an AI-powered platform dedicated to promoting sustainable scuba diving. Our mission is to protect marine ecosystems by leveraging advanced technology to enhance dive planning, provide conservation insights, and ensure diver safety.',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontFamily: 'Roboto', // Roboto 글꼴
                  color: Colors.black, // 더 진한 검정색
                  fontWeight: FontWeight.bold, // 두꺼운 글꼴
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8), // 약간 투명한 흰색 배경
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Features',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontFamily: 'Roboto', // Roboto 글꼴
                  color: Colors.black, // 더 진한 검정색
                  fontWeight: FontWeight.bold, // 두꺼운 글꼴
                ),
          ),
          SizedBox(height: 20),
          Text(
            'Our platform combines artificial intelligence with diving expertise to create safer, more sustainable underwater experiences.',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontFamily: 'Roboto', // Roboto 글꼴
                  color: Colors.black, // 더 진한 검정색
                  fontWeight: FontWeight.bold, // 두꺼운 글꼴
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildFeatureCard(
                'Smart Dive Planning',
                'AI-optimized dive routes based on your experience level, marine life interests, and environmental conditions.',
                Icons.location_on,
                context,
              ),
              _buildFeatureCard(
                'Marine Life Identification',
                'Instantly identify marine species with our AI recognition system and contribute to global biodiversity databases.',
                Icons.water_drop,
                context,
              ),
              _buildFeatureCard(
                'Safety Monitoring',
                'Real-time safety alerts and personalized recommendations to ensure a secure diving experience.',
                Icons.security,
                context,
              ),
              _buildFeatureCard(
                'Conservation Insights',
                'Learn about the health of dive sites and how your diving practices impact local marine ecosystems.',
                Icons.anchor,
                context,
              ),
              _buildFeatureCard(
                'Community Connection',
                'Connect with like-minded divers, share experiences, and participate in conservation initiatives.',
                Icons.people,
                context,
              ),
              _buildFeatureCard(
                'Dive Log Analytics',
                'Track your diving progress and environmental impact with detailed analytics and personalized insights.',
                Icons.chat_bubble,
                context,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, BuildContext context) {
    return GestureDetector(
      onTap: _userName != null
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeatureDetailPage(
                    featureTitle: title,
                    featureDescription: description,
                  ),
                ),
              );
            }
          : null, // 로그인되지 않았으면 클릭 비활성화
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        width: 300,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
            ),
          ],
          border: _userName != null
              ? Border.all(color: Colors.blue, width: 2) // 로그인 시 클릭 가능 표시
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Color(0xFF26A69A)),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Roboto', // Roboto 글꼴
                fontSize: 20, // 크기 유지
                fontWeight: FontWeight.bold, // 두꺼운 글꼴 유지
                color: Colors.black, // 더 진한 검정색
              ),
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                fontFamily: 'Roboto', // Roboto 글꼴
                fontSize: 16, // 크기 유지
                fontWeight: FontWeight.bold, // 두꺼운 글꼴
                color: Colors.black87, // 더 진한 회색
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunitySection() {
    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8), // 약간 투명한 흰색 배경
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Community',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontFamily: 'Roboto', // Roboto 글꼴
                  color: Colors.black, // 더 진한 검정색
                  fontWeight: FontWeight.bold, // 두꺼운 글꼴
                ),
          ),
          SizedBox(height: 20),
          Text(
            'Join a global community of divers sharing experiences, photos, and efforts to protect our oceans.',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontFamily: 'Roboto', // Roboto 글꼴
                  color: Colors.black, // 더 진한 검정색
                  fontWeight: FontWeight.bold, // 두꺼운 글꼴
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text(
              'Join Now',
              style: TextStyle(
                fontFamily: 'Roboto', // Roboto 글꼴
                fontWeight: FontWeight.bold, // 버튼 텍스트도 두껍게
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8), // 약간 투명한 흰색 배경
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Contact Us',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontFamily: 'Roboto', // Roboto 글꼴
                  color: Colors.black, // 더 진한 검정색
                  fontWeight: FontWeight.bold, // 두꺼운 글꼴
                ),
          ),
          SizedBox(height: 20),
          Container(
            width: 400,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(
                      fontFamily: 'Roboto', // Roboto 글꼴
                      color: Colors.black, // 라벨 텍스트도 진하게
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      fontFamily: 'Roboto', // Roboto 글꼴
                      color: Colors.black, // 라벨 텍스트도 진하게
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(),
                    // 입력된 텍스트 스타일
                    hintStyle: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // 힌트 텍스트도 진하게
                    ),
                    helperStyle: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // 도움말 텍스트도 진하게
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle( // 입력된 텍스트 스타일
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // 입력된 텍스트를 진한 검정색으로
                    fontSize: 16, // 텍스트 크기 유지
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Message',
                    labelStyle: TextStyle(
                      fontFamily: 'Roboto', // Roboto 글꼴
                      color: Colors.black, // 라벨 텍스트도 진하게
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  style: TextStyle( // 입력된 텍스트 스타일
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // 입력된 텍스트를 진한 검정색으로
                    fontSize: 16, // 텍스트 크기 유지
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    'Send Message',
                    style: TextStyle(
                      fontFamily: 'Roboto', // Roboto 글꼴
                      fontWeight: FontWeight.bold, // 버튼 텍스트도 두껍게
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(20),
      color: Color(0xFF0277BD), // 깊은 청색 (바다)
      child: Center(
        child: Text(
          '© 2025 EcoDive AI. All rights reserved.',
          style: TextStyle(
            fontFamily: 'Roboto', // Roboto 글꼴
            color: Colors.white,
            fontWeight: FontWeight.bold, // 푸터 텍스트도 두껍게
          ),
        ),
      ),
    );
  }
}

// 이메일/비밀번호 입력 폼 위젯
class AuthForm extends StatefulWidget {
  final Future<void> Function(String email, String password) onSignUp;
  final Future<void> Function(String email, String password) onSignIn;
  final bool initialSignUp;
  final String? prefillEmail;

  const AuthForm({
    super.key,
    required this.onSignUp,
    required this.onSignIn,
    this.initialSignUp = false,
    this.prefillEmail,
  });

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialSignUp;
    if (widget.prefillEmail != null) {
      _email = widget.prefillEmail!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            initialValue: _email,
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                color: Colors.black, // 라벨 텍스트도 진하게
              ),
              border: OutlineInputBorder(),
              hintText: 'Enter your email', // 힌트 텍스트 추가
              hintStyle: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                color: Colors.black54, // 힌트 텍스트는 약간 흐리게
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
            onSaved: (value) => _email = value!,
            style: TextStyle( // 입력된 텍스트 스타일
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              color: Colors.black, // 입력된 텍스트를 진한 검정색으로
              fontSize: 16, // 텍스트 크기 유지
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                color: Colors.black, // 라벨 텍스트도 진하게
              ),
              border: OutlineInputBorder(),
              hintText: 'Enter your password', // 힌트 텍스트 추가
              hintStyle: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                color: Colors.black54, // 힌트 텍스트는 약간 흐리게
              ),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            onSaved: (value) => _password = value!,
            style: TextStyle( // 입력된 텍스트 스타일
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              color: Colors.black, // 입력된 텍스트를 진한 검정색으로
              fontSize: 16, // 텍스트 크기 유지
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                if (_isSignUp) {
                  await widget.onSignUp(_email, _password);
                } else {
                  await widget.onSignIn(_email, _password);
                }
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.white, width: 2),
              ),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(
              _isSignUp ? 'Sign Up' : 'Sign In',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isSignUp = !_isSignUp;
              });
            },
            child: Text(
              _isSignUp ? 'Already have an account? Sign In' : 'Need an account? Sign Up',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}