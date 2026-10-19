import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrganicFarming extends StatefulWidget {
  static const routeName = '/OrganicFarming';

  const OrganicFarming({Key? key}) : super(key: key);

  @override
  _OrganicFarmingState createState() => _OrganicFarmingState();
}

class _OrganicFarmingState extends State<OrganicFarming> {
  var isSelected = [true, false, false, false];
  var data6 = [], data6_copy = [];
  var selected_school = 1;
  var selectedIndex = 0;
  Color textColor = const Color(0xFF2A2E48);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, getData);
  }

  Future<void> getData() async {
    try {
      var res = await ApiService.getMethod3(
          "/getOrganicFarming?school_id=$selected_school");

      if (res.statusCode == 200) {
        dynamic d = jsonDecode(res.body);

        if (d["error"] == false) {
          setState(() {
            data6 = d["data"];
            data6_copy = List.from(d["data"]);
          });
        } else {
          setState(() {
            data6 = [];
            data6_copy = [];
          });
          print("Error: ${d["message"]}");
        }
      } else {
        print("Failed to load data. Status Code: ${res.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> getFarmingVideos() async {
    try {
      var res = await ApiService.getMethod3("/getFarmingVideos");

      if (res.statusCode == 200) {
        dynamic d = jsonDecode(res.body);
        print("API Response: ${res.body}");

        if (d["error"] == false && d["data"] is List) {
          setState(() {
            data6 = d["data"]
                .map((item) => {
                      "name":
                          item["name"] ?? "No Title", // Fix: Use correct key
                      "image": item["image"]?.trim() ??
                          "placeholder.jpg", // Fix: Trim any unwanted spaces
                      "video_link": item["video_link"]?.trim() ??
                          "" // Fix: Trim spaces from video link
                    })
                .toList();
            data6_copy = List.from(data6);
          });
        } else {
          setState(() {
            data6 = [];
            data6_copy = [];
          });
          print("Error: ${d["message"]}");
        }
      } else {
        print("Failed to load farming videos. Status Code: ${res.statusCode}");
      }
    } catch (e) {
      print("Error fetching farming videos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
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
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
            child: Text(
              "Organic Farming",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 26.sp),
            ),
          ),
          Expanded(
            child: Container(
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
                    child: sliderSection(),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ToggleButtons(
                      isSelected: isSelected,
                      fillColor: Colors.blue,
                      borderColor: Colors.grey.shade300,
                      color: Colors.grey.shade800,
                      selectedColor: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      children: [
                        _toggleButton("CDS\nAmbala"),
                        _toggleButton("CDS\nYamunanagar"),
                        _toggleButton("CDS\nPatiala"),
                        _toggleButton("Farming\nVideos"),
                      ],
                      onPressed: (index) {
                        setState(() {
                          selectedIndex = index;
                          for (int i = 0; i < isSelected.length; i++) {
                            isSelected[i] = (i == index);
                          }
                        });

                        if (index == 3) {
                          // Farming Videos Selected
                          getFarmingVideos();
                        } else {
                          selected_school = index + 1;
                          getData();
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: data6.isNotEmpty
                        ? ListView.builder(
                            itemCount: data6.length,
                            itemBuilder: (context, index) {
                              return selectedIndex ==
                                      4 // If "Farming Videos" is selected
                                  ? listItem2(data6[index])
                                  : listItem(data6[index]);
                            },
                          )
                        : Center(
                            child: Text(
                              "No records found",
                              style: TextStyle(
                                  fontSize: 14.sp, color: Colors.grey),
                            ),
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

  Widget _toggleButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12.0),
      ),
    );
  }

  Widget listItem(item) {
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
        onTap: () async {
          if (await canLaunchUrlString(item["url"])) {
            await launchUrlString(item["url"]);
          } else {
            throw "Could not launch ${item["url"]}";
          }
        },
        leading: Image.network(
          "https://careerdefenceacademy.com/includes/uploads/organic_farming/" +
              item["image"],
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.image, size: 50, color: Colors.grey),
        ),
        title: Text(
          item["topic"].trim(),
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.w600, fontSize: 11.sp),
        ),
        subtitle: Text(
          DateFormat('dd MMM yyyy').format(DateTime.parse(item["created"])),
          style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w400,
              fontSize: 10.sp),
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.remove_red_eye, color: textColor),
            const SizedBox(height: 2),
            Text(
              "View",
              style: TextStyle(color: textColor, fontSize: 9.sp),
            ),
          ],
        ),
      ),
    );
  }
}

Widget sliderSection() {
  final points = [
    {"name": "Organic Farming", "image": "assets/organic.jpg"},
    {"name": "Sustainable Farming", "image": "assets/organic2.jpg"},
    {"name": "Eco-Friendly Farming", "image": "assets/organic3.jpg"},
    {"name": "Permaculture Farming", "image": "assets/organic4.jpg"},
    {"name": "Natural Farming", "image": "assets/organic5.jpg"},
    {"name": "Biodynamic Farming", "image": "assets/organic6.jpg"},
    {"name": "Regenerative", "image": "assets/organic7.jpg"},
    {"name": "Agroecology Farming", "image": "assets/organic8.jpg"}
  ];

  return CarouselSlider.builder(
    itemCount: (points.length / 2).ceil(),
    itemBuilder: (context, index, realIdx) {
      final point1 = points[index * 2];
      final point2 =
          index * 2 + 1 < points.length ? points[index * 2 + 1] : null;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: pointBox(
              context,
              point1["name"] ?? "Unknown",
              point1["image"] ?? "assets/placeholder.png",
              points, // Pass the list of points
              index * 2, // Pass the initial index
            ),
          ),
          SizedBox(width: 2.w),
          if (point2 != null)
            Expanded(
              child: pointBox(
                context,
                point2["name"] ?? "Unknown",
                point2["image"] ?? "assets/placeholder.png",
                points, // Pass the list of points
                index * 2 + 1, // Pass the initial index
              ),
            ),
        ],
      );
    },
    options: CarouselOptions(
      height: 15.h, // Reduced height for better card design
      enlargeCenterPage: true,
      autoPlay: true,
      autoPlayInterval: const Duration(seconds: 2),
    ),
  );
}

// Individual Point Box with Image

Widget pointBox(BuildContext context, String point, String imagePath,
    List<Map<String, String>> points, int initialIndex) {
  return GestureDetector(
    onTap: () {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
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
                            style: TextStyle(
                                fontSize: 12.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    },
                    options: CarouselOptions(
                      height: 35.h,
                      initialPage: initialIndex,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 2),
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
          Text(point,
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}

Widget listItem2(item) {
  String itemName = item["name"] ?? "Unknown";
  String itemImage = item["image"] ?? "placeholder.jpg";
  String? videoLink = item["video_link"];

  return Container(
    margin: EdgeInsets.symmetric(horizontal: 3.h, vertical: 1.5.h),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Colors.grey.shade50],
      ),
      borderRadius: BorderRadius.circular(15.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (videoLink != null &&
                videoLink.isNotEmpty &&
                await canLaunchUrlString(videoLink)) {
              await launchUrlString(videoLink);
            } else {
              print("Invalid video link: ${videoLink ?? "None"}");
            }
          },
          splashColor: Colors.blue.withOpacity(0.3),
          highlightColor: Colors.blue.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Image with rounded corners and border
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade100, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      "https://careerdefenceacademy.com/includes/uploads/farming_videos/$itemImage",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(Icons.image,
                            size: 40, color: Colors.grey.shade400),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            color: Colors.blue.shade300,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                          color: Colors.black.withOpacity(0.8),
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            size: 16,
                            color: Colors.blue.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Watch Video",
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.blue.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Play button
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade400, Colors.blue.shade700],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 30,
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
