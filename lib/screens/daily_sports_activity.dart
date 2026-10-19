import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class DailySportsActivity extends StatefulWidget {
  const DailySportsActivity({Key? key}) : super(key: key);

  @override
  State<DailySportsActivity> createState() => _DailySportsActivityState();
}

class _DailySportsActivityState extends State<DailySportsActivity> with SingleTickerProviderStateMixin {
  var data6 = [];
  var heading = "Sports Activity";
  var userData;
  var user_id;
  Color textColor = const Color(0xff2A2E48);
  String incharge = '';
  dynamic data = {};
  List dataDailyPuja = [];
  List sportsFAQs = [
    {
      "question": "What sports are offered?",
      "answer": "We offer cricket, basketball, volleyball, kabaddi, boxing, yoga, horse riding, and more."
    },
    {
      "question": "What is the training schedule?",
      "answer": "Daily 2.5 hours in evening and 1 hour physical training in morning."
    },
    {
      "question": "Are there competitions?",
      "answer": "Yes, we conduct weekly inter-sports matches on Saturdays and Sundays."
    },
    {
      "question": "Is equipment provided?",
      "answer": "Yes, all necessary sports equipment is provided by the academy."
    },
    {
      "question": "Are there professional coaches?",
      "answer": "Yes, all sports are taught by certified professional coaches."
    },
  ];

  var isSelected = [false, false, false, false, false, false, false];
  var selected_school = 1;
  var selectedButton = 0;
  late TabController _tabController;
  bool isLoading = true;
  int currentCarouselPage = 0;
  final CarouselSliderController carouselController = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _tabController.addListener(() {
  if (!_tabController.indexIsChanging) return;

  setState(() {
    // Reset data
    data6 = [];
    dataDailyPuja = [];

    // Decide action based on tab index
    switch (_tabController.index) {
      case 0: // Ambala
      case 1: // Yamunanagar
      case 2: // Patiala
        selected_school = _tabController.index + 1;
        getData();
        break;
      case 3: // Daily Puja
        getDailyPuja();
        break;
      case 6: // Sports Meet
        getSportsMeet();
        break;
      default:
        break;
    }
  });
});
    
    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)!.settings.arguments;
      getData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    data6 = [];
    var res = await ApiService.getMethod3(
        "/getDailySportsActivity?school_id=$selected_school");

    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      data6 = d["data"];
    }
    setState(() {
      isLoading = false;
    });
  }

  getDailyPuja() async {
    setState(() {
      isLoading = true;
    });
    var res = await ApiService.getMethod3("/getDailyPuja");
    dynamic d = jsonDecode(res.body);

    if (d != null && d["error"] == false && d["data"] != null) {
      dataDailyPuja = d["data"];
    } else {
      dataDailyPuja = [];
    }
    setState(() {
      isLoading = false;
    });
  }

  getSportsMeet() async {
  setState(() {
    isLoading = true;
  });
  var res = await ApiService.getMethod3("/getSportsMeet");
  dynamic d = jsonDecode(res.body);

  if (d != null && d["error"] == false && d["data"] != null) {
    dataDailyPuja = d["data"];
  } else {
    dataDailyPuja = [];
  }
  setState(() {
    isLoading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 25.h,
              floating: false,
              pinned: true,
              backgroundColor: Colors.blue,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 15),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Sports Activity',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://bbk12e1-cdn.myschoolcdn.com/449/photo/orig_photo2167852_12205610.jpg?',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue.withOpacity(0.3),
                            Colors.blue.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8.h,
                      left: 4.w,
                      right: 4.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '1. Daily 2.5 Hours Sports Training in Evening\n'
                          '2. Daily 1 Hour Physical Training in Morning\n'
                          '3. Weekly Saturday & Sunday Inter Sports Matches',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(8.h),
                child: Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: Colors.blue,
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, size: 5.w),
                            Text('Ambala', style: TextStyle(fontSize: 10.sp)),
                          ],
                        ),
                      ),
                      Tab(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, size: 5.w),
                            Text('Yamunanagar', style: TextStyle(fontSize: 10.sp)),
                          ],
                        ),
                      ),
                      Tab(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, size: 5.w),
                            Text('Patiala', style: TextStyle(fontSize: 10.sp)),
                          ],
                        ),
                      ),
                      Tab(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.temple_hindu, size: 5.w),
                            Text('Daily Puja', style: TextStyle(fontSize: 10.sp)),
                          ],
                        ),
                      ),
                      Tab(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sports, size: 5.w),
                            Text('Training', style: TextStyle(fontSize: 10.sp)),
                          ],
                        ),
                      ),
                      Tab(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.question_answer, size: 5.w),
                            Text('FAQs', style: TextStyle(fontSize: 10.sp)),
                          ],
                        ),
                      ),
                        Tab(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sports, size: 5.w),
                            Text('Monthly Sports Meet', style: TextStyle(fontSize: 10.sp)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Container(
          color: const Color(0xFFF8F8FA),
          child: Column(
            children: [
              // Activity Carousel
              Container(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Column(
                  children: [
                    CarouselSlider(
                      carouselController: carouselController,
                      options: CarouselOptions(
                        height: 15.h,
                        viewportFraction: 0.9,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        onPageChanged: (index, reason) {
                          setState(() {
                            currentCarouselPage = index;
                          });
                        },
                      ),
                      items: buildCarouselItems(),
                    ),
                    SizedBox(height: 1.h),
                    // Carousel Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        8, // Number of carousel pages
                        (index) => GestureDetector(
                          onTap: () {
                            carouselController.animateToPage(index);
                          },
                          child: Container(
                            width: 2.w,
                            height: 2.w,
                            margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentCarouselPage == index
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Main Content
              Expanded(
                child: isLoading
                    ? _buildLoadingShimmer()
                    : _tabController.index == 5
                        ? _buildFAQs()
                        : _buildContentList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.sports_kabaddi),
        onPressed: () {
          _showSportsScheduleDialog();
        },
      ),
    );
  }

  List<Widget> buildCarouselItems() {
    final points = [
      {"name": "Basket-Ball", "image": "assets/activity1.jpeg"},
      {"name": "Cricket", "image": "assets/activity2.jpeg"},
      {"name": "Yoga", "image": "assets/activity3.jpg"},
      {"name": "Dance", "image": "assets/activity4.jpg"},
      {"name": "Volly-Ball", "image": "assets/activity5.jpeg"},
      {"name": "Sports-Meet", "image": "assets/activity6.jpeg"},
      {"name": "Zip-Line", "image": "assets/activity7.jpeg"},
      {"name": "Matches", "image": "assets/activity8.jpeg"},
      {"name": "Kabbadi", "image": "assets/activity9.jpeg"},
      {"name": "Boxing", "image": "assets/activity10.jpeg"},
      {"name": "Trainings", "image": "assets/sport509.jpg"},
      {"name": "Matches", "image": "assets/sport510.jpg"},
      {"name": "Horse Riding", "image": "assets/sport511.jpg"},
      {"name": "Boxing", "image": "assets/sports.jpg"}
    ];

    return List.generate(
      (points.length / 2).ceil(),
      (index) {
        final point1 = points[index * 2];
        final point2 = index * 2 + 1 < points.length ? points[index * 2 + 1] : null;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          child: Row(
            children: [
              Expanded(
                child: _buildActivityCard(point1["name"]!, point1["image"]!, index * 2),
              ),
              SizedBox(width: 2.w),
              if (point2 != null)
                Expanded(
                  child: _buildActivityCard(point2["name"]!, point2["image"]!, index * 2 + 1),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityCard(String title, String imagePath, int index) {
    return GestureDetector(
      onTap: () => _showActivityDetailsDialog(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.asset(
                imagePath,
                height: 8.h,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(1.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 3.w,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityDetailsDialog(int initialIndex) {
    final points = [
      {"name": "Basket-Ball", "image": "assets/activity1.jpeg"},
      {"name": "Cricket", "image": "assets/activity2.jpeg"},
      {"name": "Yoga", "image": "assets/activity3.jpg"},
      {"name": "Dance", "image": "assets/activity4.jpg"},
      {"name": "Volly-Ball", "image": "assets/activity5.jpeg"},
      {"name": "Sports-Meet", "image": "assets/activity6.jpeg"},
      {"name": "Zip-Line", "image": "assets/activity7.jpeg"},
      {"name": "Matches", "image": "assets/activity8.jpeg"},
      {"name": "Kabbadi", "image": "assets/activity9.jpeg"},
      {"name": "Boxing", "image": "assets/activity10.jpeg"},
      {"name": "Trainings", "image": "assets/sport509.jpg"},
      {"name": "Matches", "image": "assets/sport510.jpg"},
      {"name": "Horse Riding", "image": "assets/sport511.jpg"},
      {"name": "Boxing", "image": "assets/sports.jpg"}
    ];

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: SizedBox(
            width: 90.w,
            height: 50.h,
            child: Column(
              children: [
                Expanded(
                  child: CarouselSlider.builder(
                    itemCount: points.length,
                    itemBuilder: (context, index, realIdx) {
                      return Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                points[index]["image"]!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            points[index]["name"]!,
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            "Daily training sessions available",
                            style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
                          ),
                        ],
                      );
                    },
                    options: CarouselOptions(
                      height: 40.h,
                      initialPage: initialIndex,
                      enlargeCenterPage: true,
                      viewportFraction: 0.8,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(1.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text("Close"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      // ElevatedButton.icon(
                      //   onPressed: () {
                      //     Navigator.pop(context);
                      //     // Add schedule viewing logic here
                      //   },
                      //   icon: Icon(Icons.calendar_today),
                      //   label: Text("View Schedule"),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.blue,
                      //     foregroundColor: Colors.white,
                      //     padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(20),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

Widget _buildContentList() {
  // final contentList = dataDailyPuja.isNotEmpty ? dataDailyPuja : data6;
  final contentList = dataDailyPuja.isNotEmpty ? dataDailyPuja : data6;


  if (contentList.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 15.w,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 2.h),
          Text(
            "No Records Found",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Try selecting a different category",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  return GridView.builder(
    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2, // Set the number of items per row (2 in this case)
      crossAxisSpacing: 2.w, // Space between columns
      mainAxisSpacing: 2.h, // Space between rows
      childAspectRatio: 0.7, // Adjust the aspect ratio for card sizing
    ),
    itemCount: contentList.length,
    itemBuilder: (context, index) {
      final item = contentList[index];
      return dataDailyPuja.isNotEmpty ? _buildPujaCard(item) : _buildSportsCard(item);
    },
  );
}


  Widget _buildSportsCard(dynamic item) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            launch(item["url"]);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section with overlay
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: "${ApiService.careerdefenceacademy2}includes/uploads/daily_sports_activity/" +
                        item['image'],
                    height: 20.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 20.h,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 20.h,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported_outlined,
                            size: 10.w,
                            color: Colors.grey.shade400,
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
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
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
                  ),
                  // Date badge
                  Positioned(
                    top: 1.h,
                    right: 2.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 3.w,
                            color: Colors.white,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            DateFormat('dd MMM yyyy').format(DateTime.parse(item["created"])),
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Title on image
                  Positioned(
                    bottom: 1.h,
                    left: 2.w,
                    right: 2.w,
                    child: Text(
                      item['topic'],
                      style: TextStyle(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 1),
                            blurRadius: 3.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              // Content area
              Padding(
                padding: EdgeInsets.all(3.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Location info
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on,
                            size: 4.w,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          selected_school == 1
                              ? 'Ambala'
                              : selected_school == 2
                                  ? 'Yamunanagar'
                                  : 'Patiala',
                          style: TextStyle(
                            fontSize: 6.sp,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    // View button
                    ElevatedButton.icon(
                      onPressed: () {
                        launch(item["url"]);
                      },
                      icon: Icon(Icons.visibility_outlined, size: 4.w),
                      label: Text(
                        'View',
                        style: TextStyle(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 2,
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

  Widget _buildPujaCard(dynamic item) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            launch(item["url"]);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section with overlay
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: "${ApiService.careerdefenceacademy2}includes/uploads/daily_pooja/" +
                        item['image'],
                    height: 20.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 20.h,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 20.h,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported_outlined,
                            size: 10.w,
                            color: Colors.grey.shade400,
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
                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
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
                  ),
                  // Date badge
                  Positioned(
                    top: 1.h,
                    right: 2.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 3.w,
                            color: Colors.white,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            DateFormat('dd MMM yyyy').format(DateTime.parse(item["created_at"])),
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Title on image
                  Positioned(
                    bottom: 1.h,
                    left: 2.w,
                    right: 2.w,
                    child: Text(
                      item['title'],
                      style: TextStyle(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 1),
                            blurRadius: 3.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              // Content area
              Padding(
                padding: EdgeInsets.all(3.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Temple info
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.temple_hindu,
                            size: 4.w,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Daily Updates',
                          style: TextStyle(
                            fontSize: 6.sp,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    // View button
                    ElevatedButton.icon(
                      onPressed: () {
                        launch(item["url"]);
                      },
                      icon: Icon(Icons.visibility_outlined, size: 4.w),
                      label: Text(
                        'View',
                        style: TextStyle(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 2,
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

  Widget _buildFAQs() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: sportsFAQs.length,
      itemBuilder: (context, index) {
        final faq = sportsFAQs[index];
        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            childrenPadding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.h),
            leading: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.question_mark,
                size: 5.w,
                color: Colors.blue,
              ),
            ),
            title: Text(
              faq["question"]!,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            children: [
              Text(
                faq["answer"]!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: EdgeInsets.only(bottom: 2.h),
            height: 30.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      },
    );
  }

  void _showSportsScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Container(
            width: 90.w,
            padding: EdgeInsets.all(2.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.schedule,
                        size: 6.w,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      "Sports Schedule",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(2.h),
                  child: Column(
                    children: [
                      _scheduleItem("Morning PT", "5:30 AM - 6:30 AM", "Daily"),
                      Divider(color: Colors.grey.shade300, height: 3.h),
                      _scheduleItem("Evening Sports", "4:30 PM - 7:00 PM", "Daily"),
                      Divider(color: Colors.grey.shade300, height: 3.h),
                      _scheduleItem("Inter-Sports Matches", "9:00 AM - 12:00 PM", "Sat & Sun"),
                      Divider(color: Colors.grey.shade300, height: 3.h),
                      _scheduleItem("Yoga & Meditation", "6:30 AM - 7:30 AM", "Mon, Wed, Fri"),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Close"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _scheduleItem(String activity, String time, String days) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            days,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade800,
            ),
          ),
        ),
      ],
    );
  }
}