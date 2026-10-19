import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class OurFunctions extends StatefulWidget {
  static const String routeName = '/our-functions';

  const OurFunctions({Key? key}) : super(key: key);

  @override
  State<OurFunctions> createState() => _OurFunctionsState();
}

class _OurFunctionsState extends State<OurFunctions> with SingleTickerProviderStateMixin {
  var data6 = [];
  var heading = "Our Functions";
  var userData;
  var user_id;
  Color textColor = const Color(0xff2A2E48);
  String incharge = '';
  dynamic data = {};
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Enhanced color scheme with more vibrant colors
  final Color primaryColor = const Color(0xFF3D5AFE);
  final Color secondaryColor = const Color(0xFF00B0FF);
  final Color accentColor = const Color(0xFFFF6D00);
  final Color backgroundColor = const Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;
  final Color textPrimaryColor = const Color(0xFF2A2E48);
  final Color textSecondaryColor = const Color(0xFF757575);

  var isSelected = [true, false, false];
  var selected_school = 1;
  var selectedButton = 0;
  final List<String> schoolNames = ["AMBALA", "YAMUNANAGR", "PATIALA"];
  final List<String> schoolImages = [
    "assets/images/ambala.jpg",
    "assets/images/yamunanagar.jpg",
    "assets/images/patiala.jpg",
  ];
  
  // Categories for filtering content
//   final List<Map<String, dynamic>> categories = [
//     {"name": "All", "icon": Icons.grid_view_rounded, "isSelected": true},
//     {"name": "Cultural", "icon": Icons.music_note_rounded, "isSelected": false},
//     {"name": "Sports", "icon": Icons.sports_soccer_rounded, "isSelected": false},
//     {"name": "Academic", "icon": Icons.school_rounded, "isSelected": false},
//     {"name": "Festivals", "icon": Icons.celebration_rounded, "isSelected": false},
//   ];
  
  int selectedCategory = 0;
  bool showGrid = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
    
    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)!.settings.arguments;
      getData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      var res = await ApiService.getMethod3(
          "/getOurFunctions?branch=$selected_school");

      dynamic d = jsonDecode(res.body);
      print(d);

      if (d["error"] == false) {
        setState(() {
          data6 = d["data"];
          isLoading = false;
        });
        print(data6);
      } else {
        setState(() {
          data6 = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: primaryColor,
        backgroundColor: cardColor,
        child: Stack(
          children: [
            // Background with animated gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(0.8),
                    backgroundColor,
                    backgroundColor,
                  ],
                  stops: const [0.0, 0.2, 0.2, 1.0],
                ),
              ),
            ),
            
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Custom app bar with animations
                  _buildAnimatedAppBar(),
                  
                  // Main content area
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 1.h),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        child: _buildMainContent(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Floating action button for view toggle
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            showGrid = !showGrid;
          });
        },
        backgroundColor: primaryColor,
        child: Icon(
          showGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAnimatedAppBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button with animation
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              
              // Title with animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'School Functions',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Info button
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      // Show notifications
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Notifications coming soon!'),
                          backgroundColor: primaryColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      margin: EdgeInsets.only(right: 2.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Stack(
                        children: [
                          const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 1.5.w,
                              height: 1.5.w,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // Show info dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: primaryColor,
                                size: 6.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'About School Functions',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'This section showcases various cultural events, sports activities, and academic functions organized by our schools.',
                                style: TextStyle(
                                  color: textSecondaryColor,
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                    size: 5.w,
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      'Select a school to view their specific events',
                                      style: TextStyle(
                                        color: textPrimaryColor,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                    size: 5.w,
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      'Filter events by category using the tabs',
                                      style: TextStyle(
                                        color: textPrimaryColor,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                    size: 5.w,
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      'Toggle between list and grid view',
                                      style: TextStyle(
                                        color: textPrimaryColor,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Got it',
                                style: TextStyle(color: primaryColor),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Search bar
        //   Container(
        //     margin: EdgeInsets.only(top: 2.h),
        //     padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        //     decoration: BoxDecoration(
        //       color: Colors.white.withOpacity(0.2),
        //       borderRadius: BorderRadius.circular(15),
        //       border: Border.all(
        //         color: Colors.white.withOpacity(0.3),
        //         width: 1,
        //       ),
        //     ),
        //     child: Row(
        //       children: [
        //         Icon(
        //           Icons.search_rounded,
        //           color: Colors.white,
        //           size: 5.w,
        //         ),
        //         SizedBox(width: 3.w),
        //         // Expanded(
        //         //   child: Text(
        //         //     'Search events, functions, activities...',
        //         //     style: TextStyle(
        //         //       color: Colors.white.withOpacity(0.7),
        //         //       fontSize: 12.sp,
        //         //     ),
        //         //   ),
        //         // ),
        //         Container(
        //           padding: EdgeInsets.all(1.w),
        //           decoration: BoxDecoration(
        //             color: Colors.white.withOpacity(0.3),
        //             borderRadius: BorderRadius.circular(8),
        //           ),
        //           child: Icon(
        //             Icons.mic_rounded,
        //             color: Colors.white,
        //             size: 4.w,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Schools section with horizontal scroll
          _buildSchoolsSection(),
          
          // Category filters
        //   _buildCategoryFilters(),
          
          // Featured event banner
          if (!isLoading && data6.isNotEmpty)
            _buildFeaturedEvent(),
          
          // Content section
          _buildContentSection(),
          
          // Bottom padding
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildSchoolsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: EdgeInsets.only(left: 6.w, top: 3.h, right: 6.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Our Schools',
                style: TextStyle(
                  color: textPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.school_rounded,
                      size: 3.5.w,
                      color: primaryColor,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Top Rated',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // School cards
        SizedBox(height: 2.h),
        SizedBox(
          height: 18.h,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            scrollDirection: Axis.horizontal,
            itemCount: schoolNames.length,
            itemBuilder: (context, index) {
              return _buildSchoolCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSchoolCard(int index) {
    bool isActive = index == selectedButton;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedButton = index;
          selected_school = index + 1; // Use correct branch value (1, 2, or 3)
        });
        getData();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(right: 3.w, bottom: 1.h),
        width: 40.w,
        decoration: BoxDecoration(
          color: isActive ? primaryColor : cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: isActive ? primaryColor : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Background image with overlay
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // School image
                  Image.asset(
                    schoolImages[index],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey.shade400,
                        size: 10.w,
                      ),
                    ),
                  ),
                  
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          isActive ? primaryColor.withOpacity(0.7) : Colors.black.withOpacity(0.3),
                          isActive ? primaryColor.withOpacity(0.9) : Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // School name
                  Text(
                    schoolNames[index],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  
                  SizedBox(height: 1.h),
                  
                  // School stats
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 3.w,
                              color: Colors.amber,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '4.${8 - index}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 9.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(width: 2.w),
                      
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.event_rounded,
                              size: 3.w,
                              color: Colors.white,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '${(index + 1) * 8}+',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 9.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Selected indicator
                  if (isActive)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: EdgeInsets.only(top: 1.h),
                        padding: EdgeInsets.all(1.w),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 3.w,
                          color: primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

//   Widget _buildCategoryFilters() {
//     return Container(
//       margin: EdgeInsets.only(top: 2.h),
//       height: 10.h,
//       child: ListView.builder(
//         padding: EdgeInsets.symmetric(horizontal: 4.w),
//         scrollDirection: Axis.horizontal,
//         // itemCount: categories.length,
//         itemBuilder: (context, index) {
//           bool isSelected = selectedCategory == index;
//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 selectedCategory = index;
//                 // Here you would filter the data based on category
//               });
//             },
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               margin: EdgeInsets.only(right: 3.w),
//               padding: EdgeInsets.symmetric(horizontal: 4.w),
//               decoration: BoxDecoration(
//                 color: isSelected ? primaryColor : Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(
//                     color: isSelected 
//                         ? primaryColor.withOpacity(0.3) 
//                         : Colors.black.withOpacity(0.05),
//                     blurRadius: 8,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 // children: [
//                 //   Container(
//                 //     padding: EdgeInsets.all(2.w),
//                 //     decoration: BoxDecoration(
//                 //       color: isSelected 
//                 //           ? Colors.white.withOpacity(0.2) 
//                 //           : primaryColor.withOpacity(0.1),
//                 //       shape: BoxShape.circle,
//                 //     ),
//                 //     child: Icon(
//                 //       categories[index]["icon"],
//                 //       color: isSelected ? Colors.white : primaryColor,
//                 //       size: 6.w,
//                 //     ),
//                 //   ),
//                 //   SizedBox(height: 1.h),
//                 //   Text(
//                 //     categories[index]["name"],
//                 //     style: TextStyle(
//                 //       color: isSelected ? Colors.white : textPrimaryColor,
//                 //       fontWeight: FontWeight.w600,
//                 //       fontSize: 11.sp,
//                 //     ),
//                 //   ),
//                 // ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

  Widget _buildFeaturedEvent() {
    // Use the first item as featured event
    final featuredItem = data6.first;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: "${ApiService.careerdefenceacademy2}includes/" +
                  featuredItem['image'],
              height: 25.h,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  color: Colors.white,
                  height: 25.h,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade200,
                height: 25.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey.shade400,
                      size: 12.w,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      "Featured image not available",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Gradient overlay
          Container(
            height: 25.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
          
          // Content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'FEATURED EVENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 1.h),
                  
                  // Title
                  Text(
                    featuredItem['name'],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 1.h),
                  
                  // Date and view button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.white,
                            size: 4.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            DateFormat('dd MMM yyyy').format(DateTime.parse(featuredItem["date"])),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                      
                      ElevatedButton(
                        onPressed: () {
                          launch(featuredItem["url"]);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Details',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11.sp,
                              ),
                            ),
                            SizedBox(width: 1.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 4.w,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    if (isLoading) {
      return _buildLoadingShimmer();
    }
    
    if (data6.isEmpty) {
      return _buildEmptyState();
    }
    
    return AnimationLimiter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Padding(
              padding: EdgeInsets.only(left: 2.w, top: 2.h, bottom: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Events',
                    style: TextStyle(
                      color: textPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${data6.length} Items',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content list or grid
            showGrid 
                ? _buildGridView() 
                : _buildListView(),
            
            // Bottom padding
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 3.w,
      ),
      itemCount: data6.length,
      itemBuilder: (context, index) {
        // Skip the first item if we have a featured event
        if (index == 0 && data6.length > 1) {
          return _buildGridItem(data6[1]);
        }
        return _buildGridItem(data6[index]);
      },
    );
  }

  Widget _buildGridItem(dynamic item) {
    return AnimationConfiguration.staggeredGrid(
      position: data6.indexOf(item),
      duration: const Duration(milliseconds: 500),
      columnCount: 2,
      child: ScaleAnimation(
        child: FadeInAnimation(
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    launch(item["url"]);
                  },
                  splashColor: primaryColor.withOpacity(0.1),
                  highlightColor: primaryColor.withOpacity(0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: "${ApiService.careerdefenceacademy2}includes/uploads/spoken_english/" +
                                item['image'],
                            height: 15.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                color: Colors.white,
                                height: 15.h,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade200,
                              height: 15.h,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey.shade400,
                                size: 8.w,
                              ),
                            ),
                          ),
                          
                          // Date chip
                          Positioned(
                            bottom: 1.h,
                            right: 1.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                DateFormat('dd MMM').format(DateTime.parse(item["date"])),
                                style: TextStyle(
                                  fontSize: 8.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Content
                      Padding(
                        padding: EdgeInsets.all(2.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              item['name'],
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: textPrimaryColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            SizedBox(height: 1.h),
                            
                            // School name
                            Row(
                              children: [
                                Icon(
                                  Icons.school_rounded,
                                  size: 3.w,
                                  color: primaryColor,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  schoolNames[selected_school - 1],
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 1.h),
                            
                            // View button
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 0.8.h),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  'View Details',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: data6.length,
      itemBuilder: (context, index) {
        // Skip the first item if we have a featured event
        if (index == 0 && data6.length > 1) {
          return const SizedBox.shrink();
        }
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 500),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: listTile(data6[index]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title shimmer
            Padding(
              padding: EdgeInsets.only(left: 2.w, top: 2.h, bottom: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 30.w,
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Container(
                    width: 15.w,
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ),
            
            // Shimmer items
            for (int i = 0; i < 3; i++)
              Container(
                margin: EdgeInsets.only(bottom: 2.h),
                height: 30.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state illustration
            Container(
              width: 50.w,
              height: 25.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: 20.w,
                color: Colors.grey.shade400,
              ),
            ),
            
            SizedBox(height: 3.h),
            
            Text(
              'No events found',
              style: TextStyle(
                color: textPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
            
            SizedBox(height: 1.h),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                'We couldn\'t find any events for this school. Try selecting a different school or check back later.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textSecondaryColor,
                  fontSize: 12.sp,
                  height: 1.5,
                ),
              ),
            ),
            
            SizedBox(height: 3.h),
            
            ElevatedButton(
              onPressed: getData,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh_rounded),
                  SizedBox(width: 2.w),
                  const Text('Refresh'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listTile(dynamic item) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              launch(item["url"]);
            },
            splashColor: primaryColor.withOpacity(0.1),
            highlightColor: primaryColor.withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                Stack(
                  children: [
                    // Main image with shimmer loading
                    SizedBox(
                      height: 22.h,
                      width: double.infinity,
                      child: Hero(
                        tag: 'spoken_english_${item['id']}',
                        child: CachedNetworkImage(
                          imageUrl: "${ApiService.careerdefenceacademy2}includes/uploads/spoken_english/" +
                              item['image'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey.shade400,
                                  size: 12.w,
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  "Image not available",
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Gradient overlay
                    Container(
                      height: 22.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                    
                    // Play button overlay
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 6.w,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Date chip
                    Positioned(
                      bottom: 1.h,
                      right: 3.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.5.w,
                          vertical: 0.6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 3.w,
                              color: Colors.white,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              DateFormat('dd MMM yyyy').format(DateTime.parse(item["date"])),
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Category badge
                    Positioned(
                      top: 1.h,
                      left: 3.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.5.w,
                          vertical: 0.6.h,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.category_rounded,
                              size: 3.w,
                              color: Colors.white,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              item['premium'] == '1' ? 'Premium' : 'Standard',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Content area
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with animation
                      Text(
                        item['name'],
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: textPrimaryColor,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: 1.h),
                      
                      // Tags row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildTag(
                              icon: Icons.language_rounded,
                              label: 'English',
                              color: Colors.blue.shade700,
                            ),
                            _buildTag(
                              icon: Icons.school_rounded,
                              label: schoolNames[selected_school - 1],
                              color: Colors.purple.shade700,
                            ),
                            _buildTag(
                              icon: Icons.timer_rounded,
                              label: '${(item['id'].hashCode % 30) + 5} mins',
                              color: Colors.green.shade700,
                            ),
                            _buildTag(
                              icon: Icons.people_alt_rounded,
                              label: '${(item['id'].hashCode % 100) + 20} students',
                              color: Colors.orange.shade700,
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 2.h),
                      
                      // Bottom row with additional info and view button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Additional info
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(1.w),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.update_rounded,
                                  size: 4.w,
                                  color: primaryColor,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Updated Recently',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: textSecondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          
                          // View button
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  secondaryColor,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 4.w,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 1.5.w),
                                Text(
                                  'View Details',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag({required IconData icon, required String label, required Color color}) {
    return Container(
      margin: EdgeInsets.only(right: 2.w),
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 3.w,
            color: color,
          ),
          SizedBox(width: 1.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}