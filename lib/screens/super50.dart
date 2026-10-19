import 'dart:convert';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:intl/intl.dart';
import 'dart:math' show pi;
import 'dart:ui' show ImageFilter;


class Super50 extends StatefulWidget {
  static const routeName = '/Super50';

  const Super50({Key? key}) : super(key: key);

  @override
  _Super50State createState() => _Super50State();
}

class _Super50State extends State<Super50> {
  int selectedIndex = 0; // Default to first tab
  List<dynamic> sportsData = [];
  List<dynamic> academicsData = [];
   List<dynamic> calendarData = []; // Store calendar events
   List<dynamic> copyStampingData = [];
int copyStampingTabIndex = 0; // 0 - Junior, 1 - Senior
int calendarTabIndex = 0; // 0 - Sports, 1 - Academic
   

  @override
  void initState() {
    super.initState();
    getFaqData();
  }

  getFaqData() async {
    var res = await ApiService.getMethod3("/super50");
    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      setState(() {
        sportsData = d["data"]
                ?.where((item) => item["school_id"]?.toString() == "1")
                .toList() ??
            [];
        academicsData = d["data"]
                ?.where((item) => item["school_id"]?.toString() == "2")
                .toList() ??
            [];
             copyStampingData = d["data"]
    ?.where((item) => item["school_id"]?.toString() == "3")
    .toList() ?? [];

      });
    }
  }
  


getData6() async {
  var res = await ApiService.getMethod3("/getSportsEvents");
  dynamic d = jsonDecode(res.body);
  print(res.body);

  if (d["error"] == false) {
    setState(() {
      calendarData = d["data"]; // Store fetched events
    });
  }
}


List<dynamic> getFilteredCopyStampingData() {
  return copyStampingData.where((item) {
    String topic = (item["topic"] ?? "").toLowerCase();
    if (copyStampingTabIndex == 0) {
      // Junior: Class 5 to Class 8
      return topic.contains("class 5") || topic.contains("class 6") || topic.contains("class 7") || topic.contains("class 8");
    } else {
      // Senior: Class 9 to Class 12
      return topic.contains("class 9") || topic.contains("class 10") || topic.contains("class 11") || topic.contains("class 12");
    }
  }).toList();
}

List<dynamic> getFilteredCalendarData() {
  return calendarData.where((item) {
    final type = (item["tournament_type"] ?? "").toString().toLowerCase();
    return calendarTabIndex == 0
        ? type == "sports"
        : type == "academic";
  }).toList();
}

  @override
  Widget build(BuildContext context) {
  List<List<dynamic>> tabsData = [
  academicsData,
  sportsData,
  calendarData,
  copyStampingData // Add this line
];



    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Super 50 Yamunanagar'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 15),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 1.h),
            child: Text('Super 50 Yamunanagar',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 26.sp)),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 3.h),
              // padding: EdgeInsets.only(top: 3.h),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(45.0),
                  topRight: Radius.circular(45.0),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.h),
                    child: sliderSection(), // Updated slider
                  ),
                 SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: ToggleButtons(
    isSelected: [
      selectedIndex == 0,
      selectedIndex == 1,
      selectedIndex == 2,
      selectedIndex == 3
    ],
    fillColor: Colors.blue,
    borderColor: Colors.grey.shade300,
    color: Colors.grey.shade800,
    selectedColor: Colors.white,
    borderRadius: BorderRadius.circular(10.0),
    children: [
      _toggleButton("Super 50 \nAcademics"),
      _toggleButton("Super 50 \nSports"),
      _toggleButton("Exam/Events \nCalendar 📅"),
      _toggleButton("Super 50 \nCopy Stamping"),
    ],
    onPressed: (index) {
      setState(() {
        selectedIndex = index;
        if (index == 2) {
          getData6();
        } else if (index == 3) {
          getFaqData();
        }
      });
    },
  ),
),
const SizedBox(height: 10),
                Expanded(
  child: selectedIndex == 3
      ? Column(
          children: [
            ToggleButtons(
              isSelected: [copyStampingTabIndex == 0, copyStampingTabIndex == 1],
              fillColor: Colors.blue,
              borderColor: Colors.grey.shade300,
              color: Colors.grey.shade800,
              selectedColor: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            children: [
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Junior Wing', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Class 5th to 8th', style: TextStyle(fontSize: 9.sp)),
      ],
    ),
  ),
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Senior Wing', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Class 9th to 12th', style: TextStyle(fontSize: 9.sp)),
      ],
    ),
  ),
],

              onPressed: (index) {
                setState(() {
                  copyStampingTabIndex = index;
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: getFilteredCopyStampingData().length,
                itemBuilder: (context, index) {
                  return listItem(getFilteredCopyStampingData()[index]);
                },
              ),
            ),
          ],
        )
     : selectedIndex == 2
    ? Column(
        children: [
          ToggleButtons(
            isSelected: [calendarTabIndex == 0, calendarTabIndex == 1],
            fillColor: Colors.blue,
            borderColor: Colors.grey.shade300,
            color: Colors.grey.shade800,
            selectedColor: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text("Sports Calendar", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text("Academic Calendar", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold)),
              ),
            ],
            onPressed: (index) {
              setState(() {
                calendarTabIndex = index;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: getFilteredCalendarData().length,
              itemBuilder: (context, index) {
                return calendarCard(getFilteredCalendarData()[index]);
              },
            ),
          ),
        ],
      )
          : ListView.builder(
              itemCount: tabsData[selectedIndex].length,
              itemBuilder: (context, index) {
                return listItem(tabsData[selectedIndex][index]);
              },
            ),
),


                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget listItem(dynamic item) {
    String? imageUrl = item["image"] != null
        ? "https://careerdefenceacademy.com/includes/uploads/super50/${item["image"]}"
        : null;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.h, vertical: 1.2.h),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 3)
        ],
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      child: ListTile(
        title: Text(
          item["topic"] ?? "No Title",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          DateFormat('dd MMM yyyy').format(DateTime.parse(item["created"])),
          style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w400, fontSize: 10.sp),
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.remove_red_eye, color: Colors.blue),
            const SizedBox(height: 2),
            Text(
              "View",
              style: TextStyle(color: Colors.blue, fontSize: 9.sp),
            ),
          ],
        ),
        leading: imageUrl != null
            ? Image.network(
                imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.image_not_supported, size: 50),
        onTap: () async {
          String? url = item["url"];
          if (url != null && await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url));
          } else {
            print("Could not launch $url");
          }
        },
      ),
    );
  }

Widget sliderSection() {
  final academicPoints = [
    {"name": "CLAT Exam", "image": "assets/clat50.jpg"},
    {"name": "CLAT Details", "image": "assets/clat250.jpg"},
    {"name": "CUET Exam", "image": "assets/cuet50.jpg"},
    {"name": "CUET Details", "image": "assets/cuet250.jpg"},
    {"name": "IIT-JEE", "image": "assets/jee50.jpg"},
    {"name": "NEET Exam", "image": "assets/neet250.jpg"},
  ];

  final sportsPoints = [
    {"name": "Super Trophies", "image": "assets/sport502.webp"},
    {"name": "Volly-Ball", "image": "assets/sport503.jpeg"},
    {"name": "Cycling", "image": "assets/sport504.jpeg"},
    {"name": "Chess", "image": "assets/sport505.jpeg"},
    {"name": "Basket-Ball", "image": "assets/sport507.jpg"},
    {"name": "Horse-Riding", "image": "assets/sport508.webp"},


  ];

  final points = selectedIndex == 0 ? academicPoints : sportsPoints;

  return CarouselSlider.builder(
    itemCount: (points.length / 2).ceil(),
    itemBuilder: (context, index, realIdx) {
      final point1 = points[index * 2];
      final point2 = index * 2 + 1 < points.length ? points[index * 2 + 1] : null;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: pointBox(point1["name"]!, point1["image"]!, points, index * 2),
          ),
          SizedBox(width: 2.w),
          if (point2 != null)
            Expanded(
              child: pointBox(point2["name"]!, point2["image"]!, points, index * 2 + 1),
            ),
        ],
      );
    },
    options: CarouselOptions(
      height: 15.h,
      enlargeCenterPage: true,
      autoPlay: true,
      autoPlayInterval: const Duration(seconds: 2),
    ),
  );
}

Widget pointBox(String point, String imagePath, List<Map<String, String>> points, int initialIndex) {
  return GestureDetector(
    onTap: () {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: Container(
              width: double.infinity,
              height: 40.h,
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CarouselSlider.builder(
                    itemCount: points.length,
                    itemBuilder: (context, index, realIdx) {
                      return Column(
                        children: [
                          Image.asset(
                            points[index]["image"] ?? "assets/placeholder.png",
                            width: double.infinity,
                            height: 30.h,
                            fit: BoxFit.fill,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            points[index]["name"] ?? "Unknown",
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    },
                    options: CarouselOptions(
                      height: 35.h,
                      initialPage: initialIndex,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
    child: Container(
      width: 35.w,
      height: 12.h,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Image.asset(imagePath, width: 30.w, height: 6.h, fit: BoxFit.cover),
          SizedBox(height: 1.h),
          Text(point, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}
 Widget _toggleButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.0)),
    );
  }
}


// Add these imports at the top of your file


// For the CachedNetworkImage error, you have two options:

// Option 1: Replace CachedNetworkImage with regular Image.network
// This doesn't require additional packages but won't have caching benefits
Widget calendarCard(dynamic event) {
  // Determine file type for notice_pic
  String? filePath = event["notice_pic"];
  bool isImage = filePath != null && 
      (filePath.toLowerCase().endsWith('.jpg') || 
       filePath.toLowerCase().endsWith('.jpeg') || 
       filePath.toLowerCase().endsWith('.png'));
  bool isPdf = filePath != null && filePath.toLowerCase().endsWith('.pdf');
  bool isDoc = filePath != null && 
      (filePath.toLowerCase().endsWith('.doc') || 
       filePath.toLowerCase().endsWith('.docx'));
  
  // Tournament type styling
  final isSports = event["tournament_type"]?.toLowerCase() == "sports";
  final isAcademic = event["tournament_type"]?.toLowerCase() == "academic";
  
  // Define colors based on tournament type
  final Color primaryColor = isSports 
      ? const Color(0xFF1E88E5) // Blue for sports
      : isAcademic 
          ? const Color(0xFF7E57C2) // Purple for academic
          : const Color(0xFF26A69A); // Teal for default
  
  final Color secondaryColor = isSports 
      ? const Color(0xFFE53935) // Red for sports
      : isAcademic 
          ? const Color(0xFFFFB300) // Amber for academic
          : const Color(0xFF66BB6A); // Green for default
  
  // Get event date for card background gradient angle
  final eventDate = event["event_date"] != null 
      ? DateTime.parse(event["event_date"]) 
      : DateTime.now();
  final gradientAngle = (eventDate.day % 4) * 45.0; // Vary angle based on day
  
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 3.h, vertical: 1.2.h),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.2),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.8),
              ],
              stops: const [0.0, 1.0],
              transform: GradientRotation(gradientAngle * pi / 180),
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tournament type badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSports ? Icons.sports : isAcademic ? Icons.school : Icons.event,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event["tournament_type"] ?? "Event",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Media content
              if (filePath != null)
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: isImage
                    ? Hero(
                        tag: "event-image-${event["id"] ?? DateTime.now().millisecondsSinceEpoch}",
                        child: Image.network(
                          "https://careerdefenceacademy.com/uploads/notices/$filePath",
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / 
                                      loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey, size: 20),
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade100,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isPdf ? Icons.picture_as_pdf : isDoc ? Icons.description : Icons.insert_drive_file,
                                color: isPdf ? Colors.red : isDoc ? Colors.blue : Colors.grey,
                                size: 50,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isPdf ? "PDF Document" : isDoc ? "Word Document" : "Document",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Implement document opening logic here
                                  // Replace with your URL launcher implementation
                                  launchUrl(Uri.parse("https://careerdefenceacademy.com/uploads/notices/$filePath"));
                                },
                                icon: const Icon(Icons.open_in_new, size: 16),
                                label: const Text("Open"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ),
              
              // Event details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Name with animated gradient
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        event["tournament_name"] ?? "No Title",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Info cards in a grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 3.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        // Event Date
                        _buildInfoCard(
                          icon: Icons.date_range,
                          iconColor: Colors.blue,
                          title: "Event Date",
                          value: event["event_date"] != null
                              ? DateFormat('dd MMM yyyy').format(DateTime.parse(event["event_date"]))
                              : "No Date",
                        ),
                        
                        // Registration Deadline
                        _buildInfoCard(
                          icon: Icons.timer,
                          iconColor: Colors.orange,
                          title: "Register by",
                          value: event["registration_lastdate"] != null
                              ? DateFormat('dd MMM yyyy').format(DateTime.parse(event["registration_lastdate"]))
                              : "No Deadline",
                        ),
                        
                        // Duration
                        _buildInfoCard(
                          icon: Icons.schedule,
                          iconColor: Colors.green,
                          title: "Duration",
                          value: event["duration"] ?? "No Duration",
                        ),
                        
                        // Game Level
                        _buildInfoCard(
                          icon: isSports ? Icons.sports_esports : Icons.grade,
                          iconColor: Colors.purple,
                          title: isSports ? "Game Level" : "Level",
                          value: event["game_level"] ?? "No Level",
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Location with map-like background
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.location_on, color: Colors.red, size: 14),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Location",
                                  style: TextStyle(
                                    fontSize: 8.sp,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  event["location"] ?? "No Location",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Created date with subtle styling
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event["created_at"] != null
                              ? "Created: ${DateFormat('dd MMM yyyy').format(DateTime.parse(event["created_at"]))}"
                              : "No Date",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                // child: Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     _buildActionButton(
                //       icon: Icons.info_outline,
                //       label: "Details",
                //       color: primaryColor,
                //       onTap: () {
                //         // Implement details action
                //       },
                //     ),
                //     _buildActionButton(
                //       icon: Icons.share,
                //       label: "Share",
                //       color: Colors.teal,
                //       onTap: () {
                //         // Implement share action
                //       },
                //     ),
                //     _buildActionButton(
                //       icon: Icons.calendar_today,
                //       label: "Add to Calendar",
                //       color: secondaryColor,
                //       onTap: () {
                //         // Implement calendar action
                //       },
                //     ),
                //   ],
                // ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// Helper widget for info cards
Widget _buildInfoCard({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String value,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Helper widget for action buttons
Widget _buildActionButton({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}


