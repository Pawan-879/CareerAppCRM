import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:careerapp/screens/youtube_player.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';

class StudentResults extends StatefulWidget {
  static const routeName = '/StudentResults';

  const StudentResults({Key? key}) : super(key: key);

  @override
  _StudentResultsState createState() => _StudentResultsState();
}

class _StudentResultsState extends State<StudentResults> with SingleTickerProviderStateMixin {
  var data6 = [];
  var data7 = [];
  var heading = "Our Results";
  var userData;
  var user_id;
  Color primaryColor = const Color(0xFF1E88E5);
  Color accentColor = const Color(0xFF42A5F5);
  Color textColor = const Color(0xff2A2E48);
  Color backgroundColor = const Color(0xffF8F8FA);
  String incharge = '';
  dynamic data = {};
  var totalTestimonials = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Filter variables
  String selectedState = 'All';
  String selectedDistrict = 'All';
  List<String> states = ['All'];
  List<String> districts = ['All'];
  List<dynamic> filteredData = [];

  @override
  void initState() {
    super.initState();
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
    getData();
    getDataImages();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  getData() async {
    var res = await ApiService.getMethod3("/getOurResults");
    dynamic d = jsonDecode(res.body);
    print(d);

    if (d["error"] == false) {
      setState(() {
        data6 = d["data"];
        totalTestimonials = data6.length;
        filteredData = List.from(data6);
        
        // Extract unique states
        Set<String> stateSet = {'All'};
        for (var item in data6) {
          if (item['state'] != null && item['state'].toString().isNotEmpty) {
            stateSet.add(item['state']);
          }
        }
        states = stateSet.toList();
        
        // Extract unique districts for the initial state
        updateDistricts();
      });
    }
  }

  void updateDistricts() {
    Set<String> districtSet = {'All'};
    
    if (selectedState == 'All') {
      // Get all districts from all data
      for (var item in data6) {
        if (item['district'] != null && item['district'].toString().isNotEmpty) {
          districtSet.add(item['district']);
        }
      }
    } else {
      // Get districts only for the selected state
      for (var item in data6) {
        if (item['state'] == selectedState && 
            item['district'] != null && 
            item['district'].toString().isNotEmpty) {
          districtSet.add(item['district']);
        }
      }
    }
    
    setState(() {
      districts = districtSet.toList();
      // Reset district selection if it's not available in the new list
      if (!districts.contains(selectedDistrict)) {
        selectedDistrict = 'All';
      }
    });
    
    applyFilters();
  }

  void applyFilters() {
    setState(() {
      if (selectedState == 'All' && selectedDistrict == 'All') {
        filteredData = List.from(data6);
      } else if (selectedState == 'All') {
        filteredData = data6.where((item) => item['district'] == selectedDistrict).toList();
      } else if (selectedDistrict == 'All') {
        filteredData = data6.where((item) => item['state'] == selectedState).toList();
      } else {
        filteredData = data6.where((item) => 
          item['state'] == selectedState && item['district'] == selectedDistrict).toList();
      }
    });
  }

  getDataImages() async {
    var res = await ApiService.getMethod3("/getOurResultImages");
    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      setState(() {
        data7 = d["data"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Our Results & Testimonials',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, size: 22),
              onPressed: () async {
                const url = 'https://careerdefenceacademy.com/HomeController/our_results';
                if (await canLaunchUrlString(url)) {
                  await launchUrlString(url, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Could not launch the URL")),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor,
              accentColor,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Stack(
            children: [
              // Background design
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              
              // Main content
              Column(
                children: [
                  SizedBox(height: 10.h),
                  // Top carousel
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: topCarousel(),
                  ),
                  SizedBox(height: 2.h),
                  // Main content area with rounded corners
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: backgroundColor,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(5.w, 3.h, 5.w, 1.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Student Testimonials",
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "${filteredData.length} Reviews",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Filter section
                         // Replace the Filter section with this
// Updated Filter Section in your widget
Padding(
  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // State filter chips
      Text(
        'Select State',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
        ),
      ),
      SizedBox(height: 1.h),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: states.map((String state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: ChoiceChip(
                label: Text(
                  state,
                  style: TextStyle(
                    color: selectedState == state ? Colors.white : primaryColor,
                    fontSize: 12.sp,
                  ),
                ),
                selected: selectedState == state,
                selectedColor: primaryColor,
                backgroundColor: Colors.white,
                onSelected: (bool selected) {
                  if (selected) {
                    setState(() {
                      selectedState = state;
                      selectedDistrict = 'All'; // Reset district selection
                      updateDistricts();
                    });
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
      SizedBox(height: 2.h),

      // Display the district filter only if a state is selected
      if (selectedState != 'All') ...[
        // Text(
        //   'Select District',
        //   style: TextStyle(
        //     color: textColor,
        //     fontWeight: FontWeight.bold,
        //     fontSize: 14.sp,
        //   ),
        // ),
        SizedBox(height: 1.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: districts.map((String district) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: ChoiceChip(
                  label: Text(
                    district,
                    style: TextStyle(
                      color: selectedDistrict == district
                          ? Colors.white
                          : primaryColor,
                      fontSize: 12.sp,
                    ),
                  ),
                  selected: selectedDistrict == district,
                  selectedColor: primaryColor,
                  backgroundColor: Colors.white,
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        selectedDistrict = district;
                        applyFilters(); // Apply the filter when a district is selected
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ],
  ),
),


                          
                          // Grid view of testimonials
                          Expanded(
                            child: data6.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          color: primaryColor,
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          "Loading testimonials...",
                                          style: TextStyle(
                                            color: textColor.withOpacity(0.7),
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : filteredData.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search_off_rounded,
                                            size: 40.sp,
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            "No testimonials found\nfor selected filters",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: textColor.withOpacity(0.7),
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                                      child: GridView.builder(
                                        padding: EdgeInsets.only(bottom: 2.h, top: 1.h),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.8,
                                          crossAxisSpacing: 15,
                                          mainAxisSpacing: 15,
                                        ),
                                        itemCount: filteredData.length,
                                        itemBuilder: (BuildContext ctx, index) {
                                          return testimonialCard(filteredData[index], index);
                                        },
                                      ),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget topCarousel() {
    if (data7.isEmpty) {
      return Container(
        height: 20.h,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      height: 20.h,
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    "${ApiService.careerdefenceacademy2}includes/uploads/our_results/" + data7[index]['image'],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.white,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            color: primaryColor,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient overlay for better text visibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                        stops: const [0.7, 1.0],
                      ),
                    ),
                  ),
                  // Indicator for swipeable
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${index + 1}/${data7.length}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: data7.length,
        autoplay: true,
        autoplayDelay: 3000,
        control: const SwiperControl(
          color: Colors.white,
          size: 20,
          padding: EdgeInsets.all(10),
        ),
      ),
    );
  }

  Widget testimonialCard(dynamic item, int index) {
    bool hasVideo = item['type'] == 'video' && item['url'].isNotEmpty;
    
    return Hero(
      tag: 'testimonial_${item['id']}',
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: hasVideo
                  ? () {
                      Navigator.of(context).pushNamed(
                        Youtubevideo.routeName,
                        arguments: item["url"],
                      );
                    }
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section with play button overlay
                  Stack(
                    children: [
                      SizedBox(
                        height: 14.h,
                        width: double.infinity,
                        child: Image.network(
                          "${ApiService.careerdefenceacademy2}includes/uploads/our_results/" + item['image'],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: primaryColor,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 30,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (hasVideo)
                        // Positioned.fill(
                        //   child: Container(
                        //     color: Colors.black.withOpacity(0.3),
                        //     child: Center(
                        //       child: Container(
                        //         padding: EdgeInsets.all(8),
                        //         decoration: BoxDecoration(
                        //           color: primaryColor,
                        //           shape: BoxShape.circle,
                        //           boxShadow: [
                        //             BoxShadow(
                        //               color: primaryColor.withOpacity(0.5),
                        //               blurRadius: 10,
                        //               spreadRadius: 2,
                        //             ),
                        //           ],
                        //         ),
                        //         child: Icon(
                        //           Icons.play_arrow_rounded,
                        //           color: Colors.white,
                        //           size: 25,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      // Label for video/image type
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: hasVideo ? Colors.red : Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            hasVideo ? "Video" : "Image",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Content section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Description with limited lines
                          Text(
                            item['description'],
                            style: TextStyle(
                              color: textColor,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Location and date
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item['state'] != null && item['state'].toString().isNotEmpty)
                                Text(
                                  "${item['state']}${item['district'] != null && item['district'].toString().isNotEmpty ? ', ${item['district']}' : ''}",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('dd MMM yyyy').format(DateTime.parse(item['date'])),
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 9.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // This function builds each chip button
Widget buildFilterChip({
  required String label,
  required List<String> options,
  required Function(String) onSelected,
}) {
  return Row(
    children: options.map((String option) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: ChoiceChip(
          label: Text(
            option,
            style: TextStyle(
              color: label == option ? Colors.white : primaryColor,
              fontSize: 12.sp,
            ),
          ),
          selected: label == option,
          selectedColor: primaryColor,
          backgroundColor: Colors.white,
          onSelected: (bool selected) {
            if (selected) {
              onSelected(option);
            }
          },
        ),
      );
    }).toList(),
  );
}
}