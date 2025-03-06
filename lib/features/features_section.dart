import 'package:flutter/material.dart';
import 'package:eco_dive_ai/features/feature_card.dart';
import 'package:eco_dive_ai/features/feature_pages/smart_dive_planning_page.dart';
import 'package:eco_dive_ai/features/feature_pages/marine_life_identification_page.dart';
import 'package:eco_dive_ai/features/feature_pages/safety_monitoring_page.dart';
import 'package:eco_dive_ai/features/feature_pages/conservation_insights_page.dart';
import 'package:eco_dive_ai/features/feature_pages/community_connection_page.dart';
import 'package:eco_dive_ai/features/feature_pages/dive_log_analytics_page.dart';

class FeaturesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Features',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Our platform combines artificial intelligence with diving expertise to create safer, more sustainable underwater experiences.',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              FeatureCard(
                title: 'Smart Dive Planning',
                description: 'AI-optimized dive routes based on your experience level, marine life interests, and environmental conditions.',
                icon: Icons.location_on,
                page: SmartDivePlanningPage(),
              ),
              FeatureCard(
                title: 'Marine Life Identification',
                description: 'Instantly identify marine species with our AI recognition system and contribute to global biodiversity databases.',
                icon: Icons.water_drop,
                page: MarineLifeIdentificationPage(),
              ),
              FeatureCard(
                title: 'Safety Monitoring',
                description: 'Real-time safety alerts and personalized recommendations to ensure a secure diving experience.',
                icon: Icons.security,
                page: SafetyMonitoringPage(),
              ),
              FeatureCard(
                title: 'Conservation Insights',
                description: 'Learn about the health of dive sites and how your diving practices impact local marine ecosystems.',
                icon: Icons.anchor,
                page: ConservationInsightsPage(),
              ),
              FeatureCard(
                title: 'Community Connection',
                description: 'Connect with like-minded divers, share experiences, and participate in conservation initiatives.',
                icon: Icons.people,
                page: CommunityConnectionPage(),
              ),
              FeatureCard(
                title: 'Dive Log Analytics',
                description: 'Track your diving progress and environmental impact with detailed analytics and personalized insights.',
                icon: Icons.chat_bubble,
                page: DiveLogAnalyticsPage(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}