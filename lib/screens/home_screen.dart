import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:careerapp/screens/exam_details.dart';
import 'package:careerapp/screens/weeklytest.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:careerapp/screens/allcourses.dart';
import 'package:careerapp/screens/searchcourses.dart';
import 'package:careerapp/screens/notification_screen.dart';
import 'package:intl/intl.dart';
import 'package:new_version/new_version.dart';
// import 'package:careerapp/screens/buybooks.dart';
import 'package:careerapp/screens/school_fee.dart';
import 'dart:io' show Platform;
import 'package:careerapp/screens/openurl.dart';
import 'package:shimmer/shimmer.dart';
import 'fillform.dart';
import 'youtube_player.dart';

class Home extends StatefulWidget {
  const Home({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late SwiperController swiperController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final GlobalKey<FormState> _formKey = GlobalKey();
  final _authData = {'search': ''};

  final List<String> images = [];
  var books = [];
  var data = [];
  var data2 = [];
  var data4 = [];
  var categories = [];
  var users = [];
  var notification = "";
  var noti_name = "Notification: Check Recent Notifications";
  late DateTime nextSunday;
  late DateTime nextSaturday;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    // Initialize swiper controller
    swiperController = SwiperController();

    getSlider();
    getData();
    getBooks();

    DateTime now = DateTime.now();
    int daysToSaturday = (DateTime.saturday - now.weekday) % 7;
    nextSaturday = now.add(Duration(days: daysToSaturday));

    int daysToSunday = (DateTime.sunday - now.weekday) % 7;
    nextSunday = now.add(Duration(days: daysToSunday));

    if (Platform.isAndroid) {
      _checkVersion();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkVersion() async {
    try {
      final newVersion = NewVersion(androidId: 'com.careergroup.careerapp');

      final status = await newVersion.getVersionStatus();
      if (status != null && mounted) {
        print(status.canUpdate);
        print(status.localVersion);
        print(status.storeVersion);
        await newVersion.showAlertIfNecessary(context: context);
      }
    } catch (e) {
      print('Unable to check app version: $e');
    }
  }

  void _submit() async {
    _formKey.currentState!.save();
    String data = _authData['search']!;
    Navigator.of(context).pushNamed(Searchcourses.routeName, arguments: data);
  }

  getData() async {
    try {
      var res = await ApiService.getMethod("/getSubCategories");
      data = jsonDecode(res.body);

      var res3 = await ApiService.getMethod("/getCategories");
      categories = jsonDecode(res3.body);

      setState(() {});
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  getBooks() async {
    try {
      var res2 = await ApiService.getMethod("/getProducts?type=Books&limit=10");
      books = jsonDecode(res2.body);
      setState(() {});
    } catch (e) {
      print("Error fetching books: $e");
    }
  }

  getSlider() async {
    try {
      var res = await ApiService.getMethod("/getHomeSliders");
      data4 = jsonDecode(res.body);
      for (var element in data4) {
        images.add("${ApiService.websiteUrl2}includes/upload/sliders/" +
            element["slider_image"]);
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching sliders: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _isLoading = true;
            images.clear();
          });
          // await Future.wait([
          //   getSlider(),
          //   getData(),
          //   getBooks(),
          // ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              // Notification banner
              if (notification.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      notification = "";
                    });
                    Navigator.of(context)
                        .pushNamed(NotificationScreen.routeName, arguments: 0);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    color: Colors.green.shade600,
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active,
                            color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            noti_name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  // child: Form(
                  //   key: _formKey,
                  //   child: TextFormField(
                  //     decoration: InputDecoration(
                  //       hintText: 'Search courses...',
                  //       hintStyle: const TextStyle(fontSize: 16),
                  //       prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 24),
                  //       border: InputBorder.none,
                  //       contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  //     ),
                  //     style: const TextStyle(fontSize: 16),
                  //     onSaved: (value) {
                  //       _authData['search'] = value ?? '';
                  //     },
                  //     onFieldSubmitted: (_) => _submit(),
                  //   ),
                  // ),
                ),
              ),

              // Image slider
              _isLoading
                  ? _buildShimmerSlider(deviceSize)
                  : images.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              "No images available",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: 230,
                          padding: const EdgeInsets.all(10.0),
                          child: Swiper(
                            controller: swiperController,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  if (data4[index]["code"] != null) {
                                    Navigator.of(context).pushNamed(
                                        Youtubevideo.routeName,
                                        arguments: data4[index]["code"]);
                                  }
                                },
                                child: Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: Image.network(
                                      images[index],
                                      fit: BoxFit.contain,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                            valueColor: AlwaysStoppedAnimation<
                                                    Color>(
                                                Theme.of(context).primaryColor),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey.shade300,
                                          child: const Center(
                                            child: Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                              size: 50,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                            itemWidth: deviceSize.width - 40,
                            autoplay: true,
                            duration: 300,
                            autoplayDelay: 5000,
                            itemCount: images.length,
                            layout: SwiperLayout.STACK,
                            pagination: SwiperPagination(
                              builder: DotSwiperPaginationBuilder(
                                activeColor: Theme.of(context).primaryColor,
                                color: Colors.grey.shade300,
                                size: 10.0,
                                activeSize: 12.0,
                              ),
                            ),
                          ),
                        ),

              // Quick links section
              Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Quick Links",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to all quick links
                      },
                      child: Text(
                        "View All",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              quicklinks(),

              const SizedBox(height: 16),

              // Value coach section (Buy Online Live Classes)
              valuecoach(),

              // Featured courses section
              // Padding(
              //   padding: const EdgeInsets.all(16.0),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           const Text(
              //             "Featured Courses",
              //             style: TextStyle(
              //               fontSize: 18,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //           TextButton(
              //             onPressed: () {
              //               // Navigate to all courses
              //             },
              //             child: Text(
              //               "View All",
              //               style: TextStyle(
              //                 color: Theme.of(context).primaryColor,
              //                 fontWeight: FontWeight.w600,
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //       // const SizedBox(height: 8),
              //       // _buildFeaturedCourses(),
              //     ],
              //   ),
              // ),

              // Upcoming exams section
              // Padding(
              //   padding: const EdgeInsets.all(16.0),
              //   child: Container(
              //     width: double.infinity,
              //     padding: const EdgeInsets.all(16),
              //     decoration: BoxDecoration(
              //       gradient: const LinearGradient(
              //         colors: [Color(0xFF3366FF), Color(0xFF00CCFF)],
              //         begin: Alignment.topLeft,
              //         end: Alignment.bottomRight,
              //       ),
              //       borderRadius: BorderRadius.circular(16),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.blue.withOpacity(0.3),
              //           blurRadius: 10,
              //           offset: const Offset(0, 4),
              //         ),
              //       ],
              //     ),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         const Row(
              //           children: [
              //             Icon(Icons.event, color: Colors.white),
              //             SizedBox(width: 8),
              //             Text(
              //               "Upcoming Exams",
              //               style: TextStyle(
              //                 color: Colors.white,
              //                 fontSize: 18,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //           ],
              //         ),
              //         const SizedBox(height: 16),
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             _buildExamCard("Sainik School", "15 May 2023"),
              //             _buildExamCard("NDA", "21 May 2023"),
              //           ],
              //         ),
              //         const SizedBox(height: 12),
              //         Center(
              //           child: TextButton(
              //             onPressed: () {
              //               Navigator.push(
              //                 context,
              //                 MaterialPageRoute(builder: (context) => const ExamDetails()),
              //               );
              //             },
              //             style: TextButton.styleFrom(
              //               backgroundColor: Colors.white,
              //               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              //               shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(30),
              //               ),
              //             ),
              //             child: const Text(
              //               "View All Exams",
              //               style: TextStyle(
              //                 color: Color(0xFF3366FF),
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerSlider(Size deviceSize) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 230,
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: 200,
          width: deviceSize.width - 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
      ),
    );
  }

  Widget _buildExamCard(String title, String date) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                date,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Prepare Now",
              style: TextStyle(
                color: Color(0xFF3366FF),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildFeaturedCourses() {
  //   // Sample featured courses - replace with actual data
  //   return SizedBox(
  //     height: 220,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: 5,
  //       itemBuilder: (context, index) {
  //         return Container(
  //           width: 160,
  //           margin: const EdgeInsets.only(right: 16),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(12),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.05),
  //                 blurRadius: 10,
  //                 offset: const Offset(0, 4),
  //               ),
  //             ],
  //           ),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               ClipRRect(
  //                 borderRadius: const BorderRadius.only(
  //                   topLeft: Radius.circular(12),
  //                   topRight: Radius.circular(12),
  //                 ),
  //                 child: Image.asset(
  //                   "assets/course_placeholder.png",
  //                   height: 100,
  //                   width: double.infinity,
  //                   fit: BoxFit.cover,
  //                   errorBuilder: (context, error, stackTrace) {
  //                     return Container(
  //                       height: 100,
  //                       color: Colors.grey.shade300,
  //                       child: const Center(
  //                         child: Icon(Icons.image, color: Colors.grey),
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.all(12.0),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       "Course ${index + 1}",
  //                       style: const TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 16,
  //                       ),
  //                       maxLines: 1,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                     const SizedBox(height: 4),
  //                     const Text(
  //                       "Description of the course",
  //                       style: TextStyle(
  //                         color: Colors.grey,
  //                         fontSize: 12,
  //                       ),
  //                       maxLines: 2,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                     const SizedBox(height: 8),
  //                     Row(
  //                       children: [
  //                         const Icon(Icons.star, color: Colors.amber, size: 16),
  //                         const SizedBox(width: 4),
  //                         Text(
  //                           "${4 + index % 2}.${index % 10}",
  //                           style: const TextStyle(
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 14,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget quicklinks() {
    return Container(
      height: 155,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          _buildQuickLinkItem(
            "assets/admission1.svg",
            "Scholarship",
            () {
              dynamic row = {
                "school_name": "Apply For Scholarship Test",
                "url": "https://www.careerdefenceschool.com/admission/"
              };
              Navigator.of(context)
                  .pushNamed(OpenUrl.routeName, arguments: row);
            },
          ),
          _buildQuickLinkItem(
            "assets/fee.svg",
            "Exam Details",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExamDetails()),
              );
            },
          ),
          _buildQuickLinkItem(
            "assets/online_apply.svg",
            "Fill Online Form",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FillformScreen()),
              );
            },
          ),
          _buildQuickLinkItem(
            "assets/weeklytest.svg",
            "Weekly Test",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Weeklytest()),
              );
            },
          ),
          // _buildQuickLinkItem(
          //   "assets/books.svg", // Assuming you have this asset
          //   "Buy Books",
          //   () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => const Buybooks()),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildQuickLinkItem(
      String assetPath, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 135,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                assetPath,
                height: 48,
                width: 48,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                height: 1.15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget valuecoach() {
    return GestureDetector(
      onTap: () {
        dynamic row = {
          "school_name": "Apply For Free Sample Papers",
          "url": "https://www.careerdefenceschool.com/applysamplepapers.php"
        };
        Navigator.of(context).pushNamed(OpenUrl.routeName, arguments: row);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFFFF512F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background design elements
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "SPECIAL OFFER",
                            style: TextStyle(
                              color: Color(0xFF8E2DE2),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Buy Online Live Classes",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Daily Live 4 PM to 7 PM",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Schoolfee()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Apply Now - Last Date ${DateFormat('dd MMM').format(nextSaturday)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 110,
                        width: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          "assets/samplepapers.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "₹24,999",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8E2DE2),
                              ),
                            ),
                            Text(
                              "Valid For 1 Year",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
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
    );
  }

  Widget getCategory(String categoryId, String txt, {bool isCurrent = false}) {
    return GestureDetector(
      onTap: () {
        dynamic data5 = {"category_id": categoryId, "category_name": txt};
        Navigator.of(context).pushNamed(Allcourses.routeName, arguments: data5);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color:
              isCurrent ? Theme.of(context).primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          child: Text(
            txt,
            style: TextStyle(
              color: isCurrent ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }
}
