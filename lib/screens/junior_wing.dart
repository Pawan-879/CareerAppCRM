import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/api_services.dart';
import 'package:share_plus/share_plus.dart';

class Juniorwing extends StatefulWidget {
  const Juniorwing({Key? key}) : super(key: key);

  @override
  State<Juniorwing> createState() => _JuniorwingState();
}

class _JuniorwingState extends State<Juniorwing> with SingleTickerProviderStateMixin {
  var data6 = [];
  var heading = "Junior Wing";
  var userData;
  var user_id;
  dynamic data = {};
  
  // Animation controller for staggered animations
  late AnimationController _animationController;
  
  // School selection
  int selectedSchoolTab = 0; // 0 = AMBALA, 1 = YMNGR, 2 = PATIALA
  var selected_school = 1;
  
  // Hobby categories
  List<String> hobbyCategories = [
    "Dance",
    "Drawing",
    "Quiz",
    "Abacus",
    "Memory Skills",
    "Spoken English",
  ];
  int selectedCategoryIndex = -1;
  bool isHobbyTabSelected = false;
  
  // Tab selection
  int selectedTab = 0;
  List<String> tabTitles = [
    "CDS\nAMBALA",
    "CDS\nYMNGR",
    "CDS\nPATIALA",
    "Caretaker\nReport",
    "Etiquette's &\nManners",
    "Hobby\nClasses"
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // Faster animation
    );
    
    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)!.settings.arguments;
      getData();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  getData() async {
    setState(() {
      data6 = []; // Clear existing data
    });

    String url = "/getJuniorWing?school_id=$selected_school";

    // Send hobby category if selected
    if (isHobbyTabSelected && selectedCategoryIndex != -1) {
      url += "&category=${hobbyCategories[selectedCategoryIndex]}";
    }

    try {
      var res = await ApiService.getMethod3(url);
      dynamic d = jsonDecode(res.body);

      if (d["error"] == false) {
        setState(() {
          data6 = d["data"];
        });
      }
    } catch (e) {
      // Handle error
      print("Error fetching data: $e");
    }
  }

void _sharePage() {
  const deepLinkUrl = "myapp://juniorwing";  // This will open the JuniorWing page in your app
  Share.share('Check out this page: $deepLinkUrl');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Compact App Bar with gradient
          SliverAppBar(
            expandedHeight: 8.h, // Reduced height
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A73E8),
                    Color(0xFF6C92F4),
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                title: Text(
                  'Sub-Junior Wing',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp, // Slightly smaller
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                titlePadding: EdgeInsets.only(bottom: 1.h), // Reduced padding
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background pattern
                    Opacity(
                      opacity: 0.1,
                      child: Image.asset(
                        'assets/junior1.jpeg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                    // Subtitle
                    Positioned(
                      bottom: 5.h,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          '(Nursery to 4th)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp, // Smaller font
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6), // Smaller padding
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 18), // Smaller icon
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6), // Smaller padding
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white, size: 18), // Share icon
                ),
                onPressed: _sharePage, // Call the _sharePage function
              ),
              SizedBox(width: 1.w), // Reduced spacing
            ],
          ),
          
          // Main content
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), // Smaller radius
                  topRight: Radius.circular(20), // Smaller radius
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section title with animation - more compact
                  FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                      ),
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 0.5.h), // Reduced padding
                        child: Row(
                          children: [
                            Container(
                              height: 4.h, // Smaller height
                              width: 0.8.w, // Smaller width
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A73E8),
                                borderRadius: BorderRadius.circular(8), // Smaller radius
                              ),
                            ),
                            SizedBox(width: 2.w), // Reduced spacing
                            Text(
                              'Special Coaching',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp, // Smaller font
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Compact carousel slider with animation
                  FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
                      ),
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 1.h), // Reduced padding
                        child: _buildCompactCarouselSlider(),
                      ),
                    ),
                  ),
                  
                  // Compact tab selector
                  FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
                      ),
                    ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h), // Reduced padding
                        child: _buildCompactTabSelector(),
                      ),
                    ),
                  ),
                  
                  // School selector for hobby tab - more compact
                  if (isHobbyTabSelected)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h), // Reduced padding
                      child: _buildCompactSchoolSelector(),
                    ),
                  
                  // Hobby category selector - more compact
                  if (isHobbyTabSelected)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h), // Reduced padding
                      child: _buildCompactHobbyCategorySelector(),
                    ),
                  
                  // Content list - more compact
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.h), // Reduced padding
                    child: _buildCompactContentList(),
                  ),
                  
                  SizedBox(height: 1.h), // Reduced spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Compact carousel slider with activities - shows 3 items per row
  Widget _buildCompactCarouselSlider() {
    final points = [
      {"name": "Assembly", "image": "assets/junior1.jpeg"},
      {"name": "Morning Prayers", "image": "assets/junior2.jpeg"},
      {"name": "Yoga-Classes", "image": "assets/junior3.webp"},
      {"name": "Prize Distribution", "image": "assets/junior4.jpeg"},
      {"name": "Combine Assembly", "image": "assets/junior5.jpeg"},
      {"name": "Mess", "image": "assets/junior13.jpg"},
      {"name": "Reading Classes", "image": "assets/junior6.jpg"},
      {"name": "Hand-Writting", "image": "assets/junior7.jpg"},
      {"name": "Study Time", "image": "assets/junior8.jpg"},
      {"name": "Fun Trip", "image": "assets/junior9.jpg"},
      {"name": "Morning Exercises", "image": "assets/junior10.jpg"},
      {"name": "Dance", "image": "assets/junior11.jpeg"},
      {"name": "Birhtday Celebrations", "image": "assets/junior12.jpg"},
      {"name": "New Year Party", "image": "assets/junior14.jpg"},
    ];

    return CarouselSlider.builder(
      itemCount: (points.length / 3).ceil(), // Show 3 items per row
      itemBuilder: (context, index, realIdx) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // First item
            if (index * 3 < points.length)
              Expanded(
                child: _buildCompactActivityCard(
                  context,
                  points[index * 3]["name"] ?? "Unknown",
                  points[index * 3]["image"] ?? "assets/placeholder.png",
                  points,
                  index * 3,
                ),
              ),
            SizedBox(width: 2.w),
            
            // Second item
            if (index * 3 + 1 < points.length)
              Expanded(
                child: _buildCompactActivityCard(
                  context,
                  points[index * 3 + 1]["name"] ?? "Unknown",
                  points[index * 3 + 1]["image"] ?? "assets/placeholder.png",
                  points,
                  index * 3 + 1,
                ),
              ),
            SizedBox(width: 2.w),
            
            // Third item
            if (index * 3 + 2 < points.length)
              Expanded(
                child: _buildCompactActivityCard(
                  context,
                  points[index * 3 + 2]["name"] ?? "Unknown",
                  points[index * 3 + 2]["image"] ?? "assets/placeholder.png",
                  points,
                  index * 3 + 2,
                ),
              ),
          ],
        );
      },
      options: CarouselOptions(
        height: 14.h, // Reduced height
        enlargeCenterPage: true,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        viewportFraction: 0.95, // Show more content
      ),
    );
  }

  // Compact activity card for carousel
  Widget _buildCompactActivityCard(
    BuildContext context,
    String title,
    String imagePath,
    List<Map<String, String>> points,
    int initialIndex,
  ) {
    return GestureDetector(
      onTap: () {
        _showFullscreenGallery(context, points, initialIndex);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // Smaller radius
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12), // Smaller radius
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.5, 1.0], // Adjusted gradient
                  ),
                ),
              ),
              // Title
              Positioned(
                bottom: 8, // Reduced spacing
                left: 8,
                right: 8,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 9.sp, // Smaller font
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Play indicator
              Positioned(
                top: 6, // Reduced spacing
                right: 6, // Reduced spacing
                child: Container(
                  padding: const EdgeInsets.all(4), // Smaller padding
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.touch_app,
                    color: Colors.white,
                    size: 12, // Smaller icon
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fullscreen gallery dialog - kept mostly the same
  void _showFullscreenGallery(
    BuildContext context,
    List<Map<String, String>> points,
    int initialIndex,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 90.h,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(vertical: 1.5.h), // Reduced padding
                decoration: const BoxDecoration(
                  color: Color(0xFF1A73E8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Activities Gallery',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              
              // Gallery
              Expanded(
                child: CarouselSlider.builder(
                  itemCount: points.length,
                  itemBuilder: (context, index, realIdx) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                points[index]["image"] ?? "assets/placeholder.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A73E8),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            points[index]["name"] ?? "Unknown",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                      ],
                    );
                  },
                  options: CarouselOptions(
                    height: 70.h,
                    initialPage: initialIndex,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                    autoPlay: false,
                    viewportFraction: 0.9,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Compact tab selector - horizontal scrollable row of smaller tabs
  Widget _buildCompactTabSelector() {
    return SizedBox(
      height: 9.h, // Reduced height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabTitles.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedTab == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedTab = index;
                isHobbyTabSelected = (index == 5); // Hobby Classes tab
                
                if (index < 3) {
                  selected_school = index + 1;
                  selectedCategoryIndex = -1;
                  getData();
                } else if (index == 3) {
                  // Caretaker Report tab
                  selected_school = 11;
                  selectedCategoryIndex = -1;
                  getData();
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 0.8.w), // Reduced margin
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h), // Reduced padding
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1A73E8) : Colors.white,
                borderRadius: BorderRadius.circular(10), // Smaller radius
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? const Color(0xFF1A73E8).withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 6, // Smaller blur
                    offset: const Offset(0, 2), // Smaller offset
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getTabIcon(index),
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    size: 20, // Smaller icon
                  ),
                  SizedBox(height: 0.5.h), // Reduced spacing
                  Text(
                    tabTitles[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade800,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 8.sp, // Smaller font
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Get icon for tab - unchanged
  IconData _getTabIcon(int index) {
    switch (index) {
      case 0:
        return Icons.school;
      case 1:
        return Icons.school_outlined;
      case 2:
        return Icons.account_balance;
      case 3:
        return Icons.psychology;
      case 4:
        return Icons.palette;
      case 5:
        return Icons.sports_esports;
      default:
        return Icons.school;
    }
  }

  // Compact school selector for hobby tab
  Widget _buildCompactSchoolSelector() {
    return Container(
      padding: EdgeInsets.all(1.5.w), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // Smaller radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6, // Smaller blur
            offset: const Offset(0, 2), // Smaller offset
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            "School:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10.sp, // Smaller font
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(width: 2.w), // Reduced spacing
          Expanded(
            child: SizedBox(
              height: 4.h, // Reduced height
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) {
                  List<String> schools = ["Ambala", "Yamunanagar", "Patiala"];
                  bool isSelected = selectedSchoolTab == index;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSchoolTab = index;
                        selected_school = (index == 0) ? 5 : (index == 1) ? 3 : 2;
                        selectedCategoryIndex = -1;
                        getData();
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 1.5.w), // Reduced margin
                      padding: EdgeInsets.symmetric(horizontal: 3.w), // Reduced padding
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1A73E8) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20), // Smaller radius
                      ),
                      child: Center(
                        child: Text(
                          schools[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade800,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 9.sp, // Smaller font
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Compact hobby category selector - horizontal chips
  Widget _buildCompactHobbyCategorySelector() {
    return SizedBox(
      height: 4.h, // Reduced height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hobbyCategories.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedCategoryIndex == index;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategoryIndex = index;
                getData();
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 1.5.w), // Reduced margin
              padding: EdgeInsets.symmetric(horizontal: 3.w), // Reduced padding
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1A73E8) : Colors.white,
                borderRadius: BorderRadius.circular(20), // Smaller radius
                border: Border.all(
                  color: isSelected ? const Color(0xFF1A73E8) : Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1A73E8).withOpacity(0.3),
                          blurRadius: 6, // Smaller blur
                          offset: const Offset(0, 2), // Smaller offset
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  hobbyCategories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade800,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 9.sp, // Smaller font
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Compact content list - grid view for more content per screen
  Widget _buildCompactContentList() {
    if (data6.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 2.h), // Reduced spacing
            Icon(
              Icons.search_off_rounded,
              size: 12.w, // Smaller icon
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 1.h), // Reduced spacing
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 12.sp, // Smaller font
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 0.5.h), // Reduced spacing
            Text(
              'Try selecting a different category',
              style: TextStyle(
                fontSize: 10.sp, // Smaller font
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // Use GridView instead of ListView for more content per screen
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 items per row
        childAspectRatio: 0.75, // Adjust for card proportions
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.h,
      ),
      itemCount: data6.length,
      itemBuilder: (context, index) {
        // Add staggered animation to grid items
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = index * 0.05; // Faster animation
            final start = 0.6 + delay;
            final end = start + 0.3; // Faster animation
            
            final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(start, end, curve: Curves.easeOut),
              ),
            );
            
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(start, end, curve: Curves.easeOut),
              ),
            );
            
            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
          child: _buildCompactGridItem(data6[index]),
        );
      },
    );
  }

  // Compact grid item for content list
  Widget _buildCompactGridItem(dynamic item) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1.5.w), // Reduced margin
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Smaller radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12), // Smaller radius
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            launch(item["url"]);
          },
          splashColor: const Color(0xFF1A73E8).withOpacity(0.1),
          highlightColor: const Color(0xFF1A73E8).withOpacity(0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              Stack(
                children: [
                  // Main image
                  Container(
                    height: 14.h, // Reduced height
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12), // Smaller radius
                        topRight: Radius.circular(12), // Smaller radius
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12), // Smaller radius
                            topRight: Radius.circular(12), // Smaller radius
                          ),
                          child: Image.network(
                            "${ApiService.careerdefenceacademy2}includes/uploads/junior_wing/" +
                                item['image'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey.shade200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey.shade400,
                                    size: 10.w, // Smaller icon
                                  ),
                                  SizedBox(height: 0.5.h), // Reduced spacing
                                  Text(
                                    "Image not available",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 10.sp, // Smaller font
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.shade100,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                    color: const Color(0xFF1A73E8),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Text section
              Padding(
                padding: EdgeInsets.all(2.w), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['topic'],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12.sp, // Smaller font
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Read more button
             Padding(
  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // CreatedAt timestamp
    Text(
  item['created'] != null && item['created'].isNotEmpty
      ? DateFormat('dd MMM yyyy')
          .format(DateTime.parse(item['created']).toLocal())
      : '',
  style: TextStyle(
    color: Colors.grey.shade600,
    fontSize: 9.sp,
  ),
),
      // Read more button
      TextButton(
        onPressed: () {
          launch(item["url"]);
        },
        child: Text(
          "Read more",
          style: TextStyle(
            color: const Color(0xFF1A73E8),
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  ),
),

            ],
          ),
        ),
      ),
    );
  }
}
