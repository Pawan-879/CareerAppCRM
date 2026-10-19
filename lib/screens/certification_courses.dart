// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:sizer/sizer.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../services/api_services.dart';
// import 'youtube_player.dart';

// class CertificationCourses extends StatefulWidget {
//   static const routeName = '/certification_courses';

//   const CertificationCourses({Key? key}) : super(key: key);

//   @override
//   State<CertificationCourses> createState() => _CertificationCoursesState();
// }

// class _CertificationCoursesState extends State<CertificationCourses> {
//   var data6 = [];
//   var heading = "Certification Courses";
//   var userData;
//   var user_id;
//   Color textColor = const Color(0xff2A2E48);
//   String incharge = '';
//   dynamic data = {};

//   var isSelected = [false, false, false, false];
//   var selected_school = 0;
//   var selectedButton = 0;

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(Duration.zero, () {
//       data = ModalRoute.of(context)!.settings.arguments;
//       // selected_school = data["school_id"];
//       print(data);
//       getData();
//     });
//   }

//   getData() async {
//     data6 = [];

//     var res = await ApiService.getMethod3(
//         "/getCertificationCourses?class_name=" +
//             data["class_for"] +
//             "&school_id=" +
//             data["school_id"]);

//     dynamic d = jsonDecode(res.body);

//     if (d["error"] == false) {
//       data6 = d["data"];
//       print(data6);
//     }
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, size: 15),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       backgroundColor: Colors.blue,
//       body: Stack(
//         children: [
//           Container(
//             alignment: Alignment.bottomCenter,
//             margin: EdgeInsets.only(top: 12.h),
//             width: double.infinity,
//             height: 85.h,
//             decoration: const BoxDecoration(
//               borderRadius: BorderRadius.vertical(
//                 top: Radius.circular(40),
//               ),
//               color: Color(0xffF8F8FA),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.only(left: 2.w, right: 2.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: EdgeInsets.only(
//                     left: 6.w,
//                     right: 6.w,
//                   ),
//                   child: Text('Certification Courses🏅\nSpecial Courses',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w500,
//                           fontSize: 22.sp)),
//                 ),
//                 SizedBox(height: 2.0.h),
//                 SizedBox(
//                   height: 65.h,
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         SizedBox(
//                           height: 65.h,
//                           child: ListView.builder(
//                             shrinkWrap: true,
//                             itemCount: data6.length,
//                             itemBuilder: (context, index) {
//                               return listTile(data6[index]);
//                             },
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget listTile(item) {
//     return Container(
//         margin: EdgeInsets.only(bottom: 2.h, left: 6.w, right: 6.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.shade300,
//               blurRadius: 3,
//             ),
//           ],
//           borderRadius: const BorderRadius.all(
//             Radius.circular(15.0),
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 17.w,
//               height: 10.h,
//               decoration: BoxDecoration(
//                 borderRadius: const BorderRadius.all(Radius.circular(15.0)),
//                 image: DecorationImage(
//                   fit: BoxFit.cover,
//                   image: NetworkImage(
//                     ApiService.careerdefenceacademy2 +
//                         "includes/uploads/certification_courses/" +
//                         item['image'],
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(width: 2.h),
//             SizedBox(
//               width: 60.w,
//               child: ListTile(
//                 onTap: () {
//                   launch(ApiService.careerdefenceacademy2 +
//                       "includes/uploads/certification_courses/" +
//                       item['image']);
//                   // dynamic row = {
//                   //   "school_name": "Medical Report",
//                   //   "url": ApiService.careerdefenceacademy2 +
//                   //       "home/medical_report/" +
//                   //       report.id!
//                   // };
//                   // Navigator.of(context)
//                   //     .pushNamed(OpenUrl.routeName, arguments: row);
//                 },
//                 contentPadding: EdgeInsets.zero,
//                 title: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(item['topic'],
//                         style: TextStyle(
//                             fontSize: 14.sp,
//                             color: Colors.grey.shade800,
//                             fontWeight: FontWeight.w500)),
//                     Text(
//                       DateFormat('dd MMM yyyy')
//                           .format(DateTime.parse(item["created"])),
//                       style: TextStyle(
//                         fontSize: 10.sp,
//                         color: Colors.grey,
//                       ),
//                     )
//                   ],
//                 ),
//                 trailing: Column(
//                   children: [
//                     const Icon(
//                       Icons.remove_red_eye,
//                       color: Colors.grey,
//                     ),
//                     Text('View',
//                         style: TextStyle(
//                             fontSize: 10.sp,
//                             color: Colors.blue,
//                             fontWeight: FontWeight.w500))
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ));
//   }

//   // Widget listItem(item) {
//   //   return InkWell(
//   //     onTap: () {
//   //       Navigator.of(context)
//   //           .pushNamed(Youtubevideo.routeName, arguments: item["url"]);
//   //     },
//   //     child: Container(
//   //       width: double.infinity,
//   //       margin: EdgeInsets.symmetric(horizontal: 2.5.h, vertical: 1.2.h),
//   //       decoration: BoxDecoration(
//   //           boxShadow: [
//   //             BoxShadow(
//   //               color: Colors.grey.withOpacity(0.5),
//   //               blurRadius: 3,
//   //             ),
//   //           ],
//   //           color: Colors.white,
//   //           borderRadius: const BorderRadius.all(
//   //             Radius.circular(6.0),
//   //           )),
//   //       child: Stack(
//   //         children: [
//   //           ClipRRect(
//   //             borderRadius: const BorderRadius.all(
//   //               Radius.circular(6.0),
//   //             ),
//   //             child: Image.network(ApiService.careerdefenceacademy2 +
//   //                 "includes/uploads/leadership_training/" +
//   //                 item['image']),
//   //           ),
//   //           Container(
//   //             alignment: Alignment.center,
//   //             margin: EdgeInsets.only(top: 5.h),
//   //             child: CircleAvatar(
//   //               radius: 3.h,
//   //               backgroundColor: Colors.red,
//   //               child: Icon(
//   //                 Icons.play_arrow_rounded,
//   //                 color: Colors.white,
//   //                 size: 5.h,
//   //               ),
//   //             ),
//   //           ),
//   //           Container(
//   //             margin: EdgeInsets.only(top: 16.h),
//   //             padding: EdgeInsets.all(1.2.h),
//   //             width: double.infinity,
//   //             decoration: BoxDecoration(
//   //               boxShadow: [
//   //                 BoxShadow(
//   //                   color: Colors.grey.withOpacity(0.5),
//   //                   blurRadius: 3,
//   //                 ),
//   //               ],
//   //               color: Colors.white,
//   //               borderRadius: const BorderRadius.all(
//   //                 Radius.circular(6.0),
//   //               ),
//   //             ),
//   //             height: 12.h,
//   //             child: Column(
//   //               crossAxisAlignment: CrossAxisAlignment.start,
//   //               children: [
//   //                 Text(
//   //                   item['topic'],
//   //                   style: TextStyle(
//   //                       color: textColor,
//   //                       fontWeight: FontWeight.bold,
//   //                       fontSize: 10.sp),
//   //                 ),
//   //                 Divider(
//   //                   color: Colors.grey.shade300,
//   //                 ),
//   //                 Row(
//   //                   children: [
//   //                     Expanded(
//   //                       child: Text(
//   //                         "Class: " + item['class'],
//   //                         style: TextStyle(
//   //                             color: Colors.blue,
//   //                             fontWeight: FontWeight.w500,
//   //                             fontSize: 11.sp),
//   //                       ),
//   //                     ),
//   //                     Text(
//   //                       DateFormat('dd MMM yyyy')
//   //                           .format(DateTime.parse(item["created"])),
//   //                       style: TextStyle(
//   //                           color: Colors.blue,
//   //                           fontWeight: FontWeight.w400,
//   //                           fontSize: 8.sp),
//   //                     ),
//   //                   ],
//   //                 )
//   //               ],
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

//   //  DateFormat('dd MMM yyyy').format(DateTime.parse(item["date"])),
// }
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CertificationCourses extends StatefulWidget {
  static const routeName = '/certification_courses';

  const CertificationCourses({Key? key}) : super(key: key);

  @override
  State<CertificationCourses> createState() => _CertificationCoursesState();
}

class _CertificationCoursesState extends State<CertificationCourses>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabTitles = [
    "Sub-Junior Wing \n(LKG to 4th)",
    "Junior Wing \n(Class 5th to 8th)",
    "Senior Wing \n(Class 9th to 12th)",
    "My Certifications"
  ];
  final List<String> _tabUrls = [
    "https://www.careerdefenceschool.com/Subjuniorwing.php",
    "https://www.careerdefenceschool.com/Juniorwing.php",
    "https://www.careerdefenceschool.com/Seniorwing.php",
    "" // Empty URL for "My Certifications"
  ];
  final List<IconData> _tabIcons = [
    Icons.child_care,
    Icons.school,
    Icons.workspace_premium,
    Icons.verified_user, // Added a new icon for "My Certifications"
  ];
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                _tabTitles.length,
                (index) {
                  if (index < 3) {
                    // First 3 tabs: show WebViews
                    return EnhancedWebViewScreen(
                      url: _tabUrls[index],
                      title: _tabTitles[index],
                    );
                  } else {
                    // 4th tab: "Coming Soon" screen
                    return const ComingSoonScreen();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Column(
      children: [
        Container(
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade800,
                Colors.blue.shade500,
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _tabIcons[_currentTabIndex],
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Compulsory Certification Courses",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.blue.shade700,
            labelColor: Colors.blue.shade700,
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
            tabs: List.generate(
              _tabTitles.length,
              (index) => Tab(icon: Icon(_tabIcons[index]), text: _tabTitles[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class EnhancedWebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const EnhancedWebViewScreen({Key? key, required this.url, required this.title}) : super(key: key);

  @override
  State<EnhancedWebViewScreen> createState() => _EnhancedWebViewScreenState();
}

class _EnhancedWebViewScreenState extends State<EnhancedWebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onProgress: (progress) => setState(() => _loadingProgress = progress / 100),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          LinearProgressIndicator(value: _loadingProgress, backgroundColor: Colors.white),
      ],
    );
  }
}

class ComingSoonScreen extends StatefulWidget {
  const ComingSoonScreen({Key? key}) : super(key: key);

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              "Coming Soon...",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
