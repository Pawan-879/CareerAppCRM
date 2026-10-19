import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class NDATrainingScreen extends StatefulWidget {
  const NDATrainingScreen({Key? key}) : super(key: key);

  @override
  State<NDATrainingScreen> createState() => _NDATrainingScreenState();
}

class _NDATrainingScreenState extends State<NDATrainingScreen> with TickerProviderStateMixin {

  var data6 = [];
  var heading = "NDA/NCC Training";
  var userData;
  var user_id;
  Color textColor = const Color(0xff2A2E48);
  String incharge = '';
  dynamic data = {};

  var isSelected = [false, false, false, false, false, false];
  var selected_school = 1;
  late TabController _nccTabController;

  var selectedButton = 0;
  late TabController _tabController;
  bool isLoading = true;
  int currentCarouselPage = 0;
  final CarouselSliderController carouselController = CarouselSliderController();
  String selectedTrainingType = "All"; // Default filter

  final List<String> trainingTypes = ["All", "Physical", "Written", "SSB", "Drill", "Weapons"];

  @override
  void initState() {

    super.initState();
    _nccTabController = TabController(length: 3, vsync: this);
    _tabController = TabController(length: 6, vsync: this);
 _tabController.addListener(() {
  setState(() {
    for (int i = 0; i < isSelected.length; i++) {
      isSelected[i] = i == _tabController.index;
    }

    selected_school = _tabController.index + 1;

   if (_tabController.index == 3) {
  fetchNccCadetsData();
} else {
  getData();
}
  });
});

    
    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)!.settings.arguments;
      getData();
    });
  }


Future<void> fetchNccCadetsData() async {
  setState(() {
    isLoading = true;
  });

  int newSchoolId = 1; // default Ambala
  if (selected_school == 1) {
    newSchoolId = 1;
  } else if (selected_school == 2) {
    newSchoolId = 3;
  } else if (selected_school == 3) {
    newSchoolId = 2;
  }

  var res = await ApiService.getMethod3("/getNCCcadets?school_id=$newSchoolId");
  dynamic d = jsonDecode(res.body);
  print("Response Status Code: $d");

  if (d["error"] == false) {
    setState(() {
      data6 = d["data"];
      isLoading = false;
    });
  } else {
    setState(() {
      data6 = [];
      isLoading = false;
    });
  }
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
        "/getNDATraining?school_id=$selected_school");

    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      data6 = d["data"];
    }
    setState(() {
      isLoading = false;
    });
  }

  List<dynamic> getFilteredData() {
    if (selectedTrainingType == "All") {
      return data6;
    } else {
      // This is a simple filter - you might need to adjust based on your actual data structure
      return data6.where((item) => 
        item['topic'].toString().toLowerCase().contains(selectedTrainingType.toLowerCase())
      ).toList();
    }
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
        backgroundColor: Colors.green.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 15),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        flexibleSpace: FlexibleSpaceBar(
          title: Text(
            'NDA/NCC Training',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16.sp,
            ),
          ),
          background: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/nda1.jpg',
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green.shade800.withOpacity(0.3),
                      Colors.green.shade800.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 8.h,
                left: 4.w,
                right: 4.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Comprehensive training for NDA & NCC aspirants',
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
  preferredSize: Size.fromHeight(3.h), // Reduced height
  child: Container(
    color: Colors.white,
    child: TabBar(
      controller: _tabController,
      isScrollable: true,
      padding: EdgeInsets.zero, // Remove all padding
      indicatorColor: Colors.green.shade800,
      labelColor: Colors.green.shade800,
      unselectedLabelColor: Colors.grey,
      labelPadding: EdgeInsets.symmetric(horizontal: 3.w), // Reduced horizontal padding
      indicatorPadding: EdgeInsets.zero,
      tabs: [
        Tab(icon: Icon(Icons.location_on, size: 4.w), text: 'Ambala'),
        Tab(icon: Icon(Icons.location_on, size: 4.w), text: 'Ymngr'),
        Tab(icon: Icon(Icons.location_on, size: 4.w), text: 'Patiala'),
        Tab(icon: Icon(Icons.people, size: 4.w), text: 'NCC Students'),
        Tab(icon: Icon(Icons.military_tech, size: 4.w), text: 'NDA Details'),
        Tab(icon: Icon(Icons.shield, size: 4.w), text: 'NCC Training'),
      ],
    ),
  ),
),
      ),
    ];
  },
  body: Column(
    children: [
      // Training Highlights Carousel
      Container(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 1.h, top: 1.h),
              child: Text(
                'Training Highlights',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                7,
                (index) => GestureDetector(
                  onTap: () => carouselController.animateToPage(index),
                  child: Container(
                    width: 2.w,
                    height: 2.w,
                    margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentCarouselPage == index
                          ? Colors.green.shade800
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Training Type Filter
      // Container(
      //   height: 5.h,
      //   margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      //   child: ListView.builder(
      //     scrollDirection: Axis.horizontal,
      //     itemCount: trainingTypes.length,
      //     itemBuilder: (context, index) {
      //       final type = trainingTypes[index];
      //       final isActive = selectedTrainingType == type;

      //       return GestureDetector(
      //         onTap: () {
      //           setState(() {
      //             selectedTrainingType = type;
      //           });
      //         },
      //         child: Container(
      //           margin: EdgeInsets.only(right: 2.w),
      //           padding: EdgeInsets.symmetric(horizontal: 3.w),
      //           decoration: BoxDecoration(
      //             color: isActive ? Colors.green.shade800 : Colors.white,
      //             borderRadius: BorderRadius.circular(20),
      //             border: Border.all(
      //               color: isActive ? Colors.green.shade800 : Colors.grey.shade300,
      //             ),
      //             boxShadow: isActive
      //                 ? [
      //                     BoxShadow(
      //                       color: Colors.green.shade800.withOpacity(0.3),
      //                       blurRadius: 4,
      //                       offset: Offset(0, 2),
      //                     ),
      //                   ]
      //                 : null,
      //           ),
      //           alignment: Alignment.center,
      //           child: Text(
      //             type,
      //             style: TextStyle(
      //               color: isActive ? Colors.white : Colors.grey.shade700,
      //               fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      //               fontSize: 11.sp,
      //             ),
      //           ),
      //         ),
      //       );
      //     },
      //   ),
      // ),

      // Main List Area
      Expanded(
        child: isLoading
            ? _buildLoadingShimmer()
            : _tabController.index == 3
                ? Column(
                    children: [
                      TabBar(
                        controller: _nccTabController,
                        labelColor: Colors.green,
                        unselectedLabelColor: Colors.grey,
                        tabs: const [
                          Tab(text: "Ambala"),
                          Tab(text: "Patiala"),
                          Tab(text: "Yamunanagar"),
                        ],
                        onTap: (index) {
                          setState(() {
                            selected_school = index == 0 ? 1 : (index == 1 ? 3 : 2);
                            fetchNccCadetsData();
                          });
                        },
                      ),
                      // Expanded(child: _buildTrainingList()),
                      Expanded(child: _buildCadetsList())

                    ],
                  )
                : _buildTrainingList(),
      ),
    ],
  ),
),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green.shade800,
        child: const Icon(Icons.military_tech),
        onPressed: () {
          _showTrainingScheduleDialog();
        },
      ),
    );
  }

  List<Widget> buildCarouselItems() {
    final points = [
      {"name": "Ranks In India", "image": "assets/nda1.jpg"},
      {"name": "Army Ranking", "image": "assets/nda2.jpg"},
      {"name": "Exam Pattern", "image": "assets/nda3.jpg"},
      {"name": "OLQ Explained", "image": "assets/nda4.jpg"},
      {"name": "15 Qualities", "image": "assets/nda5.webp"},
      {"name": "NDA Uniforms", "image": "assets/nda6.jpeg"},
      {"name": "Cadets", "image": "assets/nda7.webp"},
      {"name": "NDA Cadets", "image": "assets/nda8.png"},
      {"name": "RM School", "image": "assets/nda9.jpg"},
      {"name": "Join IMA", "image": "assets/nda10.jpg"},
      {"name": "Sainik School", "image": "assets/nda11.jpg"},
      {"name": "RIMC", "image": "assets/nda12.jpg"},
      {"name": "NCA Pune", "image": "assets/nda13.jpg"},
      {"name": "NCC Cadets", "image": "assets/nda14.jpg"},
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
                child: _buildTrainingCard(point1["name"]!, point1["image"]!, index * 2),
              ),
              SizedBox(width: 2.w),
              if (point2 != null)
                Expanded(
                  child: _buildTrainingCard(point2["name"]!, point2["image"]!, index * 2 + 1),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrainingCard(String title, String imagePath, int index) {
    return GestureDetector(
      onTap: () => _showTrainingDetailsDialog(index),
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
                    color: Colors.green.shade800,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrainingDetailsDialog(int initialIndex) {
    final points = [
      {"name": "Ranks In India", "image": "assets/nda1.jpg", "desc": "Hierarchy of ranks in the Indian Armed Forces"},
      {"name": "Army Ranking", "image": "assets/nda2.jpg", "desc": "Detailed structure of Army ranks from Sepoy to General"},
      {"name": "Exam Pattern", "image": "assets/nda3.jpg", "desc": "NDA exam consists of Mathematics, GAT and SSB interview"},
      {"name": "OLQ Explained", "image": "assets/nda4.jpg", "desc": "Officer Like Qualities assessed during SSB interviews"},
      {"name": "15 Qualities", "image": "assets/nda5.webp", "desc": "15 essential qualities required for military leadership"},
      {"name": "NDA Uniforms", "image": "assets/nda6.jpeg", "desc": "Different uniforms worn by NDA cadets for various occasions"},
      {"name": "Cadets", "image": "assets/nda7.webp", "desc": "NDA cadets undergoing rigorous training at the academy"},
      {"name": "NDA Cadets", "image": "assets/nda8.png", "desc": "Cadets participating in parade and ceremonial activities"},
      {"name": "RM School", "image": "assets/nda9.jpg", "desc": "Rashtriya Military School prepares students for military careers"},
      {"name": "Join IMA", "image": "assets/nda10.jpg", "desc": "Indian Military Academy trains officers for commission"},
      {"name": "Sainik School", "image": "assets/nda11.jpg", "desc": "Sainik Schools prepare students for NDA entrance"},
      {"name": "RIMC", "image": "assets/nda12.jpg", "desc": "Rashtriya Indian Military College is a feeder institution for NDA"},
      {"name": "NCA Pune", "image": "assets/nda13.jpg", "desc": "National Cadet Academy in Pune trains future officers"},
      {"name": "NCC Cadets", "image": "assets/nda14.jpg", "desc": "National Cadet Corps develops leadership and discipline"},
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
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: Text(
                              points[index]["desc"]!,
                              style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
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
                      //     // Add learn more logic here
                      //   },
                      //   icon: Icon(Icons.school),
                      //   label: Text("Learn More"),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.green.shade800,
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

  Widget _buildTrainingList() {
    final filteredData = getFilteredData();
    
    if (filteredData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.military_tech_outlined,
              size: 15.w,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 2.h),
            Text(
              "No Training Items Found",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              "Try selecting a different category or location",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        final item = filteredData[index];
        return _buildTrainingItemCard(item);
      },
    );
  }

  Widget _buildTrainingItemCard(dynamic item) {
    // Determine training type icon and color
    IconData trainingIcon = Icons.military_tech;
    Color trainingColor = Colors.green.shade800;
    String trainingType = "Training";
    
    if (item['topic'].toString().toLowerCase().contains('physical')) {
      trainingIcon = Icons.fitness_center;
      trainingColor = Colors.orange;
      trainingType = "Physical";
    } else if (item['topic'].toString().toLowerCase().contains('written') || 
               item['topic'].toString().toLowerCase().contains('exam')) {
      trainingIcon = Icons.edit_note;
      trainingColor = Colors.blue;
      trainingType = "Written";
    } else if (item['topic'].toString().toLowerCase().contains('ssb')) {
      trainingIcon = Icons.psychology;
      trainingColor = Colors.purple;
      trainingType = "SSB";
    } else if (item['topic'].toString().toLowerCase().contains('drill')) {
      trainingIcon = Icons.directions_run;
      trainingColor = Colors.red;
      trainingType = "Drill";
    } else if (item['topic'].toString().toLowerCase().contains('weapon')) {
      trainingIcon = Icons.gps_fixed;
      trainingColor = Colors.brown;
      trainingType = "Weapons";
    } else if (item['topic'].toString().toLowerCase().contains('ncc')) {
      trainingIcon = Icons.shield;
      trainingColor = Colors.teal;
      trainingType = "NCC";
    } else if (item['topic'].toString().toLowerCase().contains('nda')) {
      trainingIcon = Icons.military_tech;
      trainingColor = Colors.green.shade800;
      trainingType = "NDA";
    }

    return Container(
      margin: EdgeInsets.only(bottom: 2.h, left: 2.w, right: 2.w),
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
                    imageUrl: "${ApiService.careerdefenceacademy2}includes/uploads/leadership_training/" +
                        item['image'],
                    height: 18.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 18.h,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 18.h,
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
                  // Training type badge
                  Positioned(
                    top: 1.h,
                    left: 2.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: trainingColor,
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
                            trainingIcon,
                            size: 3.w,
                            color: Colors.white,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            trainingType,
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
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
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
              
              // Training details
              Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Class info if available
                    if (item['class'] != null && item['class'].toString().isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(2.w),
                        margin: EdgeInsets.only(bottom: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.class_,
                              size: 4.w,
                              color: Colors.green.shade800,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                "Class: ${item['class']}",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Bottom row with location and view button
                    Row(
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
                                      : selected_school == 3
                                          ? 'Patiala'
                                          : selected_school == 4
                                              ? 'NCC Cadets'
                                              : selected_school == 5
                                                  ? 'NDA Training'
                                                  : 'NCC Training',
                              style: TextStyle(
                                fontSize: 11.sp,
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
                            'View Details',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade800,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

  void _showTrainingScheduleDialog() {
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
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.schedule,
                        size: 6.w,
                        color: Colors.green.shade800,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      "Training Schedule",
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
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(2.h),
                  child: Column(
                    children: [
                      _scheduleItem("Physical Training", "5:30 AM - 7:00 AM", "Daily"),
                      Divider(color: Colors.grey.shade300, height: 3.h),
                      _scheduleItem("Written Classes", "9:00 AM - 12:00 PM", "Mon-Fri"),
                      Divider(color: Colors.grey.shade300, height: 3.h),
                      _scheduleItem("Drill Practice", "4:00 PM - 5:30 PM", "Mon, Wed, Fri"),
                      Divider(color: Colors.grey.shade300, height: 3.h),
                      _scheduleItem("SSB Training", "10:00 AM - 1:00 PM", "Sat & Sun"),
                      Divider(color: Colors.grey.shade300, height: 3.h),
                      _scheduleItem("Weapons Training", "2:00 PM - 4:00 PM", "Tue & Thu"),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
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
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            days,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: Colors.green.shade800,
            ),
          ),
        ),
      ],
    );
  }
Widget _buildCadetsList() {
  if (data6.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_rounded,
            size: 70,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 2.h),
          Text(
            "No Cadets Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Try adjusting your search or filters",
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  return ListView.builder(
    itemCount: data6.length,
    padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
    itemBuilder: (context, index) {
      final cadet = data6[index];
      // final fullName = "${cadet['first_name']} ${cadet['last_name']}";
      final firstName = cadet['first_name'] ?? '';
final lastName = cadet['last_name'] ?? '';
final fullName = lastName.isNotEmpty ? "$firstName $lastName" : firstName;

      final wing = cadet['wing'];
      
      // Generate a consistent color based on the wing name
      final wingColor = _getWingColor(wing);
      
      // Get initials for the avatar
      final initials = (firstName.isNotEmpty ? firstName[0] : '') + 
                 (lastName.isNotEmpty ? lastName[0] : '');


      return Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        child: Card(
          elevation: 3,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // Handle tap event - could navigate to cadet details
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Avatar with initials
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: wingColor.withOpacity(0.2),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: wingColor,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, 
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: wingColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.shield_outlined,
                                    size: 14,
                                    color: wingColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    wing,
                                    style: TextStyle(
                                      color: wingColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // You can add more badges or info here
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

// Helper function to get a color based on wing name
Color _getWingColor(String wing) {
  // Create a consistent color based on the wing name
  switch (wing.toLowerCase()) {
    case 'alpha':
      return Colors.blue.shade700;
    case 'bravo':
      return Colors.red.shade700;
    case 'charlie':
      return Colors.green.shade700;
    case 'delta':
      return Colors.orange.shade700;
    case 'echo':
      return Colors.purple.shade700;
    default:
      // Generate a color based on the string hash if not in predefined list
      return Colors.primaries[wing.hashCode % Colors.primaries.length];
  }
}
}
