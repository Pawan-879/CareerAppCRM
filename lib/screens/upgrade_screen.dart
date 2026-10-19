import 'package:flutter/material.dart';
import 'package:careerapp/screens/school_fee.dart';


class UpgradeFeatures extends StatefulWidget {
  static const routeName = '/upgradefeatures';

  const UpgradeFeatures({super.key});

  @override
  _UpgradeFeaturesState createState() => _UpgradeFeaturesState();
}

class _UpgradeFeaturesState extends State<UpgradeFeatures> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> features = [
    "AI-Powered Progress Insights",
    "Behavioral Analytics",
    "Parent-Teacher Interaction Hub",
    "Weekly Zoom Meeting with Teachers & Child",
    "Weekly Certification Courses Report",
    "Class Teacher & Chief Warden Weekly Report",
    "Achievements & Milestones Timeline",
    "Wellness Tracker",
    "Gamified Learning Leaderboard",
    "360° Skill Development Report",
  ];

  final List<IconData> featureIcons = [
    Icons.psychology,
    Icons.analytics,
    Icons.groups,
    Icons.videocam,
    Icons.article,
    Icons.assignment,
    Icons.emoji_events,
    Icons.favorite,
    Icons.leaderboard,
    Icons.insights,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF3949AB),
              Color(0xFF1E88E5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _buildFeaturesList(),
              ),
              _buildPaymentSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "PREMIUM FEATURES",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: features.length,
            itemBuilder: (context, index) {
              // Create staggered animation for each item
              final Animation<double> animation = CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  (index / features.length) * 0.75,
                  ((index + 1) / features.length) * 0.75,
                  curve: Curves.easeOut,
                ),
              );
              
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - animation.value)),
                    child: Opacity(
                      opacity: animation.value,
                      child: child,
                    ),
                  );
                },
                child: _buildFeatureItem(index),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colors.white,
            Color(0xFFE3F2FD),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A237E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            featureIcons[index],
            color: const Color(0xFF1A237E),
            size: 28,
          ),
        ),
        title: Text(
          features[index],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A237E),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "₹20,000",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              Text(
                " /year",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            "Unlock all premium features",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
             onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Schoolfee()),
                            );
                          },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              shadowColor: const Color(0xFF1A237E).withOpacity(0.5),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
             
              children: [
                Icon(Icons.lock_open, size: 24),
                SizedBox(width: 12),
                Text(
                  "UPGRADE NOW",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        //   SizedBox(height: 12),
        //   TextButton(
        //     onPressed: () {},
        //     child: Text(
        //       "View Payment Options",
        //       style: TextStyle(
        //         color: Color(0xFF1A237E),
        //         fontWeight: FontWeight.w500,
        //       ),
        //     ),
        //   ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: const Color(0xFF1A237E),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: const UpgradeFeatures(),
  ));
}

