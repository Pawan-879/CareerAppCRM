import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';

class EducationalTrip extends StatefulWidget {
  const EducationalTrip({Key? key}) : super(key: key);

  @override
  State<EducationalTrip> createState() => _EducationalTripState();
}

class _EducationalTripState extends State<EducationalTrip>
    with SingleTickerProviderStateMixin {
  var data6 = [];
  var heading = "Junior Wing";
  var userData;
  var user_id;
  Color textColor = const Color(0xff2A2E48);
  String incharge = '';
  dynamic data = {};
  late TabController _tabController;

  var isSelected = [true, false, false]; // First option selected by default
  var selected_school = 1;
  var selectedButton = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedButton = _tabController.index;
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
    data6 = [];
    var res = await ApiService.getMethod3(
        "/getEducationalTrip?school_id=$selected_school");

    dynamic d = jsonDecode(res.body);
    print(res.body);

    if (d["error"] == false) {
      data6 = d["data"];
      print(data6);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient background
          SliverAppBar(
            expandedHeight: 15.h,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade700,
                    Colors.blue.shade500,
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  'Educational Trips',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                background: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'assets/trip1.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () {
                  // Show info dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('About Educational Trips'),
                      content: const Text(
                          'Educational trips provide students with real-world experiences that enhance classroom learning. These trips are carefully planned to align with curriculum objectives.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          // Featured Destinations Carousel (Added at the top)
          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Our Trips',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                size: 4.w,
                                color: Colors.blue.shade700,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Popular',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  sliderSection(),
                  SizedBox(height: 1.h),
                ],
              ),
            ),
          ),

          // School Selection Tabs
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      'Select School',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Row(
                      children: [
                        _buildSchoolTab("AMBALA", 0),
                        _buildSchoolTab("YAMUNANAGAR", 1),
                        _buildSchoolTab("PATIALA", 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Trip List Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Trips',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${data6.length} Trips',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Trip List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (data6.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 15.w,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No trips found',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return listTile(data6[index]);
              },
              childCount: data6.isEmpty ? 1 : data6.length,
            ),
          ),

          // Bottom Padding
          SliverToBoxAdapter(
            child: SizedBox(height: 2.h),
          ),
        ],
      ),
      // Floating Action Button for quick filtering
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade700,
        child: const Icon(Icons.filter_list_rounded, color: Colors.white),
        onPressed: () {
          // Show filter options
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => Container(
              padding: EdgeInsets.all(4.w),
              height: 40.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Trips',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'By Date',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  // Date filter options would go here
                  Wrap(
                    spacing: 2.w,
                    children: [
                      _buildFilterChip('This Month', true),
                      _buildFilterChip('Last Month', false),
                      _buildFilterChip('This Year', false),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'By Type',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  // Type filter options would go here
                  Wrap(
                    spacing: 2.w,
                    children: [
                      _buildFilterChip('Educational', false),
                      _buildFilterChip('Cultural', false),
                      _buildFilterChip('Historical', true),
                      _buildFilterChip('Scientific', false),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            side: BorderSide(color: Colors.blue.shade700),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Reset'),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            backgroundColor: Colors.blue.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue.shade700,
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue.shade700 : Colors.grey.shade800,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      onSelected: (bool selected) {
        // Handle filter selection
      },
    );
  }

  Widget _buildSchoolTab(String name, int index) {
    bool selected = isSelected[index];
    return GestureDetector(
      onTap: () {
        setState(() {
          for (int i = 0; i < isSelected.length; i++) {
            isSelected[i] = (i == index);
          }
          selected_school = index + 1;
        });
        getData();
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 1.w),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: selected ? Colors.blue.shade700 : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.blue.shade200.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Text(
          name,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 10.sp,
          ),
        ),
      ),
    );
  }

  Widget sliderSection() {
    final points = [
      {"name": "IIT Delhi", "image": "assets/iitdelhi.jpg"},
      {"name": "IIT Roorkee", "image": "assets/iitroorkee.jpg"},
      {"name": "IIT Ropar", "image": "assets/iitropar.jfif"},
      {"name": "IMA Dehradun", "image": "assets/imadehradun.avif"},
      {"name": "Sainik Schools", "image": "assets/sainik.jfif"},
      {"name": "Military Schools", "image": "assets/military.jpg"},
      {"name": "Mansa Devi Temple", "image": "assets/MansaTemple.jpg"},
      {"name": "Partition Museum", "image": "assets/trip1.jpg"},
      {"name": "Thappar University", "image": "assets/trip2.jpg"},
      {"name": "Chitkara University", "image": "assets/trip3.jpg"},
      {"name": "LPU", "image": "assets/trip5.jpg"},
      {"name": "Chandigarh University", "image": "assets/trip6.jpg"},
      {"name": "Amity University", "image": "assets/trip7.jpg"},
      {"name": "MM University", "image": "assets/trip8.jpg"},
    ];

    return CarouselSlider(
      items: points.map((point) {
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Container(
                    width: double.infinity,
                    height: 50.h,
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            point["image"] ?? "assets/placeholder.png",
                            width: double.infinity,
                            height: 30.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          point["name"] ?? "Unknown",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Popular destination for educational trips',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 2.h),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 1.2.h),
                          ),
                          child: Text(
                            "Close",
                            style: TextStyle(fontSize: 11.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 1.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15.0)),
                  child: Stack(
                    children: [
                      Image.asset(
                        point["image"] ?? "assets/placeholder.png",
                        width: double.infinity,
                        height: 14.h,
                        fit: BoxFit.cover,
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                              stops: const [0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 1.h,
                        left: 2.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 3.w,
                                color: Colors.white,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Popular',
                                style: TextStyle(
                                  fontSize: 8.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        point["name"] ?? "Unknown",
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 3.w,
                            color: Colors.blue.shade700,
                          ),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              'Educational Destination',
                              style: TextStyle(
                                fontSize: 8.sp,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
      }).toList(),
      options: CarouselOptions(
        height: 22.h,
        viewportFraction: 0.75,
        enlargeCenterPage: true,
        enlargeFactor: 0.25,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        pauseAutoPlayOnTouch: true,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget listTile(dynamic item) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15.0),
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
                  // Main image
                  SizedBox(
                    height: 18.h,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15.0)),
                      child: Image.network(
                        "${ApiService.careerdefenceacademy2}includes/uploads/educational_trip/" +
                            item['image'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey.shade400,
                              size: 10.w,
                            ),
                          ),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey.shade100,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: Colors.blue.shade400,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15.0)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Class label
                  Positioned(
                    top: 1.h,
                    left: 2.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 0.6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        item['class'],
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Date overlay
                  Positioned(
                    bottom: 1.h,
                    right: 2.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(15),
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
                            DateFormat('dd MMM yyyy')
                                .format(DateTime.parse(item["created"])),
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

                  // Title overlay at bottom of image
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(15.0)),
                        color: Colors.black.withOpacity(0.6),
                      ),
                      child: Text(
                        item['topic'],
                        style: TextStyle(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                    // Trip details
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on_outlined,
                            size: 5.w,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Educational Visit',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              'Organized by CDS on ${DateFormat('dd MMM yyyy').format(DateTime.parse(item["created"]))}',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
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
                            Colors.blue.shade400,
                            Colors.blue.shade700,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
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
                          SizedBox(width: 1.w),
                          Text(
                            'View',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
