import 'dart:convert';
import 'youtube_player.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import '../services/api_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CCTVCamera extends StatefulWidget {
  const CCTVCamera({Key? key}) : super(key: key);

  @override
  State<CCTVCamera> createState() => _CCTVCameraState();
}

class _CCTVCameraState extends State<CCTVCamera> {
  var data6 = [];
  var heading = "CCTV Cameras";
  var userData;
  var user_id;
  Color textColor = const Color(0xff2A2E48);
  String incharge = '';
  dynamic data = {};

  var isSelected = [false, false, false];
  var selected_school = 1;
  var selectedButton = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)!.settings.arguments;
      getData();
    });
  }

  getData() async {
    data6 = [];

    var res = await ApiService.getMethod3(
        "/getCCTVCameras?school_id=$selected_school");

    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      data6 = d["data"];
      print(data6);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 15),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.blue,
      body: Stack(
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.only(top: 12.h),
            width: double.infinity,
            height: 85.h,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(40),
              ),
              color: Color(0xffF8F8FA),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 2.w, right: 2.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 6.w,
                    right: 6.w,
                  ),
                  child: Text('CCTV Cameras',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 26.sp)),
                ),
                const SizedBox(height: 45),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.h),
                  child: sliderSection(),
                ),
                // SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ToggleButtons(
                      fillColor: Colors.blue,
                      hoverColor: Colors.blue,
                      renderBorder: true,
                      borderColor: Colors.grey.shade300,
                      color: Colors.grey.shade800,
                      selectedColor: Colors.green,
                      borderRadius: BorderRadius.circular(10.0),
                      isSelected: isSelected,
                      onPressed: (index) {
                        selected_school = index + 1;
                        setState(() {
                          for (int buttonIndex = 0;
                              buttonIndex < isSelected.length;
                              buttonIndex++) {
                            if (buttonIndex == index) {
                              isSelected[buttonIndex] = true;
                            } else {
                              isSelected[buttonIndex] = false;
                            }
                          }
                        });
                        getData();
                      },
                      children: <Widget>[
                        Container(
                          color: Colors.white,
                          padding:
                              const EdgeInsets.fromLTRB(5.0, 16.0, 5.0, 16.0),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text("AMBALA"),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          padding:
                              const EdgeInsets.fromLTRB(5.0, 16.0, 5.0, 16.0),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text("YAMUNANAGR"),
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          padding:
                              const EdgeInsets.fromLTRB(5.0, 16.0, 5.0, 16.0),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text("PATIALA"),
                            ],
                          ),
                        ),
                        // Container(
                        //   color: Colors.white,
                        //   padding:
                        //       const EdgeInsets.fromLTRB(5.0, 16.0, 5.0, 16.0),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     mainAxisSize: MainAxisSize.min,
                        //     children: const <Widget>[
                        //       Text("BADDI"),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),
                SizedBox(
                  height: 65.h,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 65.h,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: data6.length,
                            itemBuilder: (context, index) {
                              return listTile(data6[index]);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget sliderSection() {
    final points = [
      {"name": "Class Rooms", "image": "assets/ClassRoom.jpg"},
      {"name": "Movie Nights", "image": "assets/MovieNight.jpg"},
      {"name": "Evening Classes", "image": "assets/eveclass.jpg"},
      {"name": "Sports", "image": "assets/sports.jpg"},
      // {"name": "Sainik Schools", "image": "assets/sainik.jfif"},
      // {"name": "Military Schools", "image": "assets/military.jpg"},
      // {"name": "Mansa Devi Temple", "image": "assets/MansaTemple.jpg"},
      // {"name": "Sukhna Lake", "image": "assets/Sukhna.jpg"},
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
        autoPlayInterval: const Duration(seconds: 3),
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
                              points[index]["image"] ??
                                  "assets/placeholder.png",
                              width: double.infinity,
                              height: 30.h,
                              fit: BoxFit.contain,
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

  // Widget listTile(item) {
  //   return Container(
  //       margin: EdgeInsets.only(bottom: 2.h, left: 6.w, right: 6.w),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.grey.shade300,
  //             blurRadius: 3,
  //           ),
  //         ],
  //         borderRadius: const BorderRadius.all(
  //           Radius.circular(15.0),
  //         ),
  //       ),
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Container(
  //             width: 17.w,
  //             height: 10.h,
  //             decoration: BoxDecoration(
  //               borderRadius: const BorderRadius.all(Radius.circular(15.0)),
  //               image: DecorationImage(
  //                 fit: BoxFit.fill,
  //                 image: NetworkImage(
  //                   ApiService.careerdefenceacademy2 +
  //                       "includes/uploads/cctv_cameras/" +
  //                       item['image'],
  //                 ),
  //               ),
  //             ),
  //           ),
  //           SizedBox(width: 2.h),
  //           SizedBox(
  //             width: 60.w,
  //             child: ListTile(
  //               onTap: () {
  //                 launch((item["url"]));
  //                 // dynamic row = {
  //                 //   "school_name": "Medical Report",
  //                 //   "url": ApiService.careerdefenceacademy2 +
  //                 //       "home/medical_report/" +
  //                 //       report.id!
  //                 // };
  //                 // Navigator.of(context)
  //                 //     .pushNamed(OpenUrl.routeName, arguments: row);
  //               },
  //               contentPadding: EdgeInsets.zero,
  //               title: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(item['topic'],
  //                       style: TextStyle(
  //                           fontSize: 14.sp,
  //                           color: Colors.grey.shade800,
  //                           fontWeight: FontWeight.w500)),
  //                   Text(
  //                     DateFormat('dd MMM yyyy')
  //                         .format(DateTime.parse(item["created"])),
  //                     style: TextStyle(
  //                       fontSize: 10.sp,
  //                       color: Colors.grey,
  //                     ),
  //                   )
  //                 ],
  //               ),
  //               trailing: Column(
  //                 children: [
  //                   const Icon(
  //                     Icons.remove_red_eye,
  //                     color: Colors.grey,
  //                   ),
  //                   Text('View',
  //                       style: TextStyle(
  //                           fontSize: 10.sp,
  //                           color: Colors.blue,
  //                           fontWeight: FontWeight.w500))
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ));
  // }
  Widget listTile(dynamic item) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            launch(item["url"]);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full-width image at the top
              Stack(
                children: [
                  // Main image
                  Container(
                    height: 22.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image
                        Image.network(
                          "${ApiService.careerdefenceacademy2}includes/uploads/cctv_cameras/" +
                              item['image'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
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
                        // Gradient overlay for better text visibility
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(0.6),
                              ],
                              stops: const [0.6, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category label
                  // Positioned(
                  //   top: 2.h,
                  //   left: 3.w,
                  //   child: Container(
                  //     padding: EdgeInsets.symmetric(
                  //       horizontal: 3.w,
                  //       vertical: 0.8.h,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: Colors.blue.shade600,
                  //       borderRadius: BorderRadius.circular(20),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.black.withOpacity(0.2),
                  //           blurRadius: 4,
                  //           offset: const Offset(0, 2),
                  //         ),
                  //       ],
                  //     ),
                  //     child: Text(
                  //       'Sports Activity',
                  //       style: TextStyle(
                  //         fontSize: 10.sp,
                  //         color: Colors.white,
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  // Date overlay
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
                ],
              ),

              // Content area
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item['topic'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 2.h),

                    // Bottom row with additional info and view button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Additional info (could be author, source, etc.)
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(1.w),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.sports,
                                size: 4.w,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Daily Update',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade600,
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
                                Colors.blue.shade400,
                                Colors.blue.shade600,
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
    );
  }

  Widget listItem(item) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .pushNamed(Youtubevideo.routeName, arguments: item["url"]);
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 2.5.h, vertical: 1.2.h),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 3,
              ),
            ],
            color: Colors.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(6.0),
            )),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(6.0),
              ),
              child: Image.network(
                  "${ApiService.careerdefenceacademy2}includes/uploads/leadership_training/" +
                      item['image']),
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 5.h),
              child: CircleAvatar(
                radius: 3.h,
                backgroundColor: Colors.red,
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 5.h,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 16.h),
              padding: EdgeInsets.all(1.2.h),
              width: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 3,
                  ),
                ],
                color: Colors.white,
                borderRadius: const BorderRadius.all(
                  Radius.circular(6.0),
                ),
              ),
              height: 12.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['topic'],
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp),
                  ),
                  Divider(
                    color: Colors.grey.shade300,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Class: " + item['class'],
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontSize: 11.sp),
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy')
                            .format(DateTime.parse(item["created"])),
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w400,
                            fontSize: 8.sp),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  DateFormat('dd MMM yyyy').format(DateTime.parse(item["date"])),
}
