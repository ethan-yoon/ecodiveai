import 'package:flutter/material.dart';

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
            fontFamily: 'Roboto',
            fontSize: 36,
            fontWeight: FontWeight.bold, // 두꺼운 글꼴
            color: Colors.black, // 더 진한 검정색
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Roboto',
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
            fontFamily: 'Roboto',
            fontSize: 36,
            fontWeight: FontWeight.bold, // 두꺼운 글꼴
            color: Colors.white, // 밝은 색상 유지 (다크 모드)
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Roboto',
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _isScrolled = _scrollController.offset > 50;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildHeroSection(context),
                _buildAboutSection(),
                _buildFeaturesSection(),
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
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold, // AppBar 제목도 두껍게
                ),
              ),
              actions: [
                _buildNavItem(context, 'Home', () => _scrollToSection(0)),
                _buildNavItem(context, 'About', () => _scrollToSection(1)),
                _buildNavItem(context, 'Features', () => _scrollToSection(2)),
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
      //color: Colors.black, // 검정 배경
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
                  fontFamily: 'Roboto',
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
                fontFamily: 'Roboto',
                fontSize: 18, // 설명 텍스트 크기
                fontWeight: FontWeight.bold, // 두꺼운 글꼴
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _scrollToSection(1),
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
                'Start Exploring',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold, // 두꺼운 글꼴
                ),
              ),
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
                  color: Colors.black, // 더 진한 검정색
                  fontWeight: FontWeight.bold, // 두꺼운 글꼴
                ),
          ),
          SizedBox(height: 20),
          Text(
            'EcoDive AI is an AI-powered platform dedicated to promoting sustainable scuba diving. Our mission is to protect marine ecosystems by leveraging advanced technology to enhance dive planning, provide conservation insights, and ensure diver safety.',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
                  color: Colors.black, // 더 진한 검정색
                  fontWeight: FontWeight.bold, // 두꺼운 글꼴
                ),
          ),
          SizedBox(height: 20),
          Text(
            'Our platform combines artificial intelligence with diving expertise to create safer, more sustainable underwater experiences.',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
              ),
              _buildFeatureCard(
                'Marine Life Identification',
                'Instantly identify marine species with our AI recognition system and contribute to global biodiversity databases.',
                Icons.water_drop,
              ),
              _buildFeatureCard(
                'Safety Monitoring',
                'Real-time safety alerts and personalized recommendations to ensure a secure diving experience.',
                Icons.security,
              ),
              _buildFeatureCard(
                'Conservation Insights',
                'Learn about the health of dive sites and how your diving practices impact local marine ecosystems.',
                Icons.anchor,
              ),
              _buildFeatureCard(
                'Community Connection',
                'Connect with like-minded divers, share experiences, and participate in conservation initiatives.',
                Icons.people,
              ),
              _buildFeatureCard(
                'Dive Log Analytics',
                'Track your diving progress and environmental impact with detailed analytics and personalized insights.',
                Icons.chat_bubble,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      width: 300,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Color(0xFF26A69A)),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 20, // 크기 유지
              fontWeight: FontWeight.bold, // 두꺼운 글꼴 유지
              color: Colors.black, // 더 진한 검정색
            ),
          ),
          SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontSize: 16, // 크기 유지
              fontWeight: FontWeight.bold, // 두꺼운 글꼴
              color: Colors.black87, // 더 진한 회색
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
                  color: Colors.black, // 더 진한 검정색
                  fontWeight: FontWeight.bold, // 두꺼운 글꼴
                ),
          ),
          SizedBox(height: 20),
          Text(
            'Join a global community of divers sharing experiences, photos, and efforts to protect our oceans.',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
                      color: Colors.black, // 라벨 텍스트도 진하게
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Message',
                    labelStyle: TextStyle(
                      color: Colors.black, // 라벨 텍스트도 진하게
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    'Send Message',
                    style: TextStyle(
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
            color: Colors.white,
            fontWeight: FontWeight.bold, // 푸터 텍스트도 두껍게
          ),
        ),
      ),
    );
  }
}