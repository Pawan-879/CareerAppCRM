import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher_string.dart';


class StudentWeeklyActivity extends StatefulWidget {
  static const routeName = '/StudentWeeklyActivitys';

  const StudentWeeklyActivity({Key? key}) : super(key: key);

  @override
  _StudentWeeklyActivityState createState() => _StudentWeeklyActivityState();
}


class _StudentWeeklyActivityState extends State<StudentWeeklyActivity> {
  var isSelected = [true, false, false, false, false, false, false]; // Updated length for Shark Tank
  var data6 = [], data6_copy = [], data7 = [], data8 = [], dataSharkTank = [];
  var selected_school = 1;
  var heading = "Student Weekly Activity";
  var userData;
  var user_id;
  List dataDailyPuja = [];
  List dataHobbies = [];
  String selectedHobbyCategory = "all";

String selectedMovieClass = "all";

Map<String, List<dynamic>> groupBySchool(List data) {
  Map<String, List<dynamic>> groupedData = {};
  for (var item in data) {
    String school = item["school"] ?? "Unknown School";
    if (!groupedData.containsKey(school)) {
      groupedData[school] = [];
    }
    groupedData[school]!.add(item);
  }
  return groupedData;
}



Widget movieClassFilterChip(String label, String value) {
  bool isSelected = selectedMovieClass == value;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4.0),
    child: ChoiceChip(
      label: Text(label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
      selected: isSelected,
      selectedColor: Colors.blue,
      onSelected: (selected) {
        setState(() {
          selectedMovieClass = value;
        });
      },
    ),
  );
}

  var selectedIndex = 1;
  Color textColor = const Color(0xFF2A2E48);
  dynamic data = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)!.settings.arguments;
      getData();
      getData7();
      getData8();
      getSharkTankDetails(); // Fetch Shark Tank details
      getDailyPuja(); // Fetch Shark Tank details
      getHobbiesTraining();

      setState(() {});
    });
  }

  getData() async {
    var res = await ApiService.getMethod3("/getWeeklyActivityReport");
    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      data6 = d["data"];
      data6_copy = d["data"];
      myfilter();
    }
    setState(() {});
  }

getData7() async {
  var res = await ApiService.getMethod3("/getWeeklyMovies");

  print("Raw Response from /getWeeklyMovies: ${res.body}");

  try {
    dynamic d = jsonDecode(res.body);

    if (d["error"] == false && d["data"] != null) {
      setState(() {
        data7 = d["data"];
      });
      print("Parsed Weekly Movies: ${data7.length} items");
    } else {
      print("Weekly Movies Error or Empty: ${d["message"] ?? "No message"}");
    }
  } catch (e) {
    print("Error parsing weekly movies response: $e");
  }
}



  getData8() async {
    var res = await ApiService.getMethod3("/getAudioMovies");
    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      data8 = d["data"];
    }
    setState(() {});
  }

  getSharkTankDetails() async {
    var res = await ApiService.getMethod3("/getsharkTankDetails");
    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      dataSharkTank = d["data"];
    }
    setState(() {});
  }

getDailyPuja() async {
    var res = await ApiService.getMethod3("/getDailyPuja");
    dynamic d = jsonDecode(res.body);

    if (d != null && d["error"] == false && d["data"] != null) {
      dataDailyPuja = d["data"];
    } else {
      dataDailyPuja = []; // Ensure it's not null
    }
    setState(() {}); // Refresh UI
}

getHobbiesTraining() async {
    var res = await ApiService.getMethod3("/getHobbiesTraining");
    dynamic d = jsonDecode(res.body);
    print("API Responsekdjhbjkdhrbdhk: ${res.body}");

    if (d != null && d["error"] == false && d["data"] != null) {
      dataHobbies = d["data"];
    } else {
      dataHobbies = []; // Ensure it's not null
    }
    setState(() {}); // Refresh UI
}

  myfilter() {
    data6 = [];
    for (var element in data6_copy) {
      if (int.parse(element["school_id"]) == selected_school) {
        data6.add(element);
      }
    }

    setState(() {});
  }

  Widget hobbyFilterChip(String label, String value) {
    bool isSelected = selectedHobbyCategory == value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
        selected: isSelected,
        selectedColor: Colors.blue,
        onSelected: (selected) {
          setState(() {
            selectedHobbyCategory = value;
          });
        },
      ),
    );
  }

  List getFilteredHobbies() {
    if (selectedHobbyCategory == "all") {
      return dataHobbies;
    }
    return dataHobbies.where((item) {
      String? category = item["new_column_name"]?.toLowerCase().replaceAll(" ", "_");
      return category == selectedHobbyCategory;
    }).toList();
  }

  String normalizeCategory(String category) {
    switch (category.toLowerCase()) {
      case 'music & dance':
        return 'music';
      default:
        return category.toLowerCase().replaceAll(" ", "_");
    }
  }

// List getFilteredMovies() {
//   if (selectedMovieClass == "all") return data7;

//   return data7.where((item) {
//     String movieClass = item["class"]?.toString().toLowerCase() ?? '';
//     return movieClass == selectedMovieClass.toLowerCase();
//   }).toList();
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 15),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 1.h),
              child: Text('Weekly/Hobby Classes\nActivity Report',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20.sp)),
            ),
            Container(
              margin: EdgeInsets.only(top: 3.h),
              // padding: EdgeInsets.only(top: 3.h),
              height: 84.h,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45.0),
                    topRight: Radius.circular(45.0),
                  )),
              //         Padding(
              //   padding: EdgeInsets.symmetric(vertical: 0.h),
              //   child: sliderSection(),
              // ),

              child: Column(
                children: [
                   Padding(
      padding: EdgeInsets.symmetric(vertical: 0.h),
      child: sliderSection(),
    ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                    child: ToggleButtons(
                      fillColor: Colors.blue,
                      hoverColor: Colors.blue,
                      renderBorder: true,
                      borderColor: Colors.grey.shade300,
                      color: Colors.grey.shade800,
                      selectedColor: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      isSelected: isSelected,
                      onPressed: (index) {
                        selected_school = index + 1;
                        setState(() {
                          selectedIndex = index;
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
                        myfilter();
                      },
                      children: <Widget>[
                        Container(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 16.0, 10.0, 16.0),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text("CDS\nAmbala",
                               style: TextStyle(
      fontSize: 12.0, 
    )),
                              
                            ],
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 16.0, 10.0, 16.0),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text("CDS\nPatiala", style: TextStyle(
      fontSize: 12.0, 
    )),
                            ],
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 16.0, 10.0, 16.0),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text("CDS\nYamunanagar", style: TextStyle(
      fontSize: 12.0, 
    )),
                            ],
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 16.0, 10.0, 16.0),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text("Weekly\nMovies 🍿", style: TextStyle(
      fontSize: 12.0, 
    )),
                            ],
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 16.0, 10.0, 16.0),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text("Shark\nTank 🦈", style: TextStyle(
      fontSize: 12.0, 
    )),
    
                            ],
                          ),
                        ),
                         Container(
  padding: const EdgeInsets.fromLTRB(10.0, 16.0, 10.0, 16.0),
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      SizedBox(height: 8.0),
      Text(
        "Daily\n Puja",
        style: TextStyle(fontSize: 12.0),
      ),
      // Icon(Icons.temple_hindu, size: 12.0, color: Colors.brown),
    ],
  ),
),
 Container(
  padding: const EdgeInsets.fromLTRB(10.0, 16.0, 10.0, 16.0),
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      SizedBox(height: 8.0),
      Text(
        "Hobbies\n Traning",
        style: TextStyle(fontSize: 12.0),
      ),
      // Icon(Icons.temple_hindu, size: 12.0, color: Colors.brown),
    ],
  ),
),
                      ],
                    ),
                  ),
                  if (selectedIndex == 0 ||
                      selectedIndex == 1 ||
                      selectedIndex == 2 ||
                      selectedIndex == 3)
                    SizedBox(
                        height: 450,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: data6.length,
                          itemBuilder: (context, index) {
                            return listItem(data6[index]);
                          },
                        )),
//                   if (selectedIndex == 3)
//                    SizedBox(
//   height: 450,
//   child: ListView.builder(
//     shrinkWrap: true,
//     itemCount: getFilteredMovies().length,
//     itemBuilder: (context, index) {
//       return listItem2(getFilteredMovies()[index]);
//     },
//   ),
// ),
 if (selectedIndex == 3)
 
                    SizedBox(
                        height: 450,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: data7.length,
                          itemBuilder: (context, index) {
                            return listItem2(data7[index]);
                          },
                        )),

//                         Padding(
//   padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
//   child: SingleChildScrollView(
//     scrollDirection: Axis.horizontal,
//     child: Row(
//       children: [
//         movieClassFilterChip("All", "all"),
//         movieClassFilterChip("Sub-Junior", "Sub-Junior"),
//         movieClassFilterChip("Junior", "Junior"),
//         movieClassFilterChip("Senior", "Senior"),
//       ],
//     ),
//   ),
// ),

                  if (selectedIndex == 4)
                    SizedBox(
                        height: 450,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: dataSharkTank.length,
                          itemBuilder: (context, index) {
                            return listItem2(dataSharkTank[index]);
                          },
                        )),
                       if (selectedIndex == 5)
  Expanded(
    child: ListView(
      padding: EdgeInsets.only(bottom: 3.h),
      children: [
        ...groupBySchool(dataDailyPuja).entries.map((entry) {
          String schoolName = entry.key;
          List items = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                child: Text(
                  schoolName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
              ...items.map((item) => listItem3(item)).toList(),
            ],
          );
        }).toList(),
      ],
    ),
  ),

 if (selectedIndex == 6)
  Column(
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              hobbyFilterChip("All", "all"),
              hobbyFilterChip("Art & Craft", "art_craft"),
              hobbyFilterChip("Music", "music"),
              hobbyFilterChip("Dance", "dance"),
              hobbyFilterChip("Spoken English", "spoken_english"),
              hobbyFilterChip("Computer", "computer"),
            ],
          ),
        ),
      ),
      SizedBox(
        height: 450,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: getFilteredHobbies().length,
          itemBuilder: (context, index) {
            return listItem3(getFilteredHobbies()[index]);
          },
        ),
      ),
    ],
  ),


                ],
              ),
            ),
          ],
        ));
  }


Widget sliderSection() {
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
  ];

  return CarouselSlider.builder(
    itemCount: (points.length / 2).ceil(),
    itemBuilder: (context, index, realIdx) {
      final point1 = points[index * 2];
      final point2 = index * 2 + 1 < points.length ? points[index * 2 + 1] : null;

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
Widget pointBox(BuildContext context, String point, String imagePath, List<Map<String, String>> points, int initialIndex) {
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
                            fit: BoxFit.contain,
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
          Text(point, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}
  Widget listItem(item) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 3.h, vertical: 1.2.h),
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 3,
              ),
            ],
            color: Colors.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(10.0),
            )),
        child: ListTile(
          onTap: (() async {
            if (await canLaunchUrlString(item["url"])) {
              await launchUrlString(item["url"]);
            } else {
              throw "Could not launch " + item["url"];
            }
          }),
          leading: Image.asset(
            'assets/fitness.png',
            filterQuality: FilterQuality.high,
          ),
          title: Text(
            item["activity_name"].trim() ?? '',
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.w600, fontSize: 11.sp),
          ),
          subtitle: Text(
            DateFormat('dd MMM yyyy').format(DateTime.parse(item["date"])),
            style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w400,
                fontSize: 10.sp),
          ),
          trailing: Icon(
            Icons.remove_red_eye,
            color: textColor,
          ),
        ));
  }

  Widget listItem2(Map<String, dynamic> item) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 3.h, vertical: 1.2.h),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 3,
          ),
        ],
        color: Colors.white,
        borderRadius: const BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            "${ApiService.careerdefenceacademy2}includes/uploads/movie_details/" +
                (item["image"] ?? ''),
            height: 60.0,
            width: 60.0,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.image_not_supported,
              size: 60.0,
              color: Colors.grey,
            ),
          ),
        ),
        title: Text(
          item["movie_name"]?.trim() ?? 'Unknown Movie',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 10.sp,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Available On',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w400,
                fontSize: 9.sp,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item["date"] != null
                  ? DateFormat('dd MMM yyyy').format(DateTime.parse(item["date"]))
                  : 'Unknown Date',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w400,
                fontSize: 10.sp,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Class: ${item["class_type"] ?? 'Unknown Class'}",
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.w800,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Category',
              style: TextStyle(color: Colors.grey, fontSize: 9.sp),
            ),
            const SizedBox(height: 4),
            Text(
              item["category"]?.trim().length > 10
                  ? item["category"].trim().substring(0, 10) + "..."
                  : item["category"]?.trim() ?? 'N/A',
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
  
Widget listItem3(dynamic item) {
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
            Stack(
              children: [
                SizedBox(
                  height: 22.h,
                  width: double.infinity,
                  child: Image.network(
                    "${ApiService.careerdefenceacademy2}includes/uploads/daily_pooja/" + item['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Icon(Icons.image_not_supported_outlined, size: 12.w, color: Colors.grey.shade400),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
                if (item['new_column_name'] != null) // Only show category if not null
                  Positioned(
                    top: 2.h,
                    left: 3.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item['new_column_name'],
                        style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 1.h,
                  right: 3.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 3.w, color: Colors.white),
                        SizedBox(width: 1.w),
                        Text(
                          DateFormat('dd MMM yyyy').format(DateTime.parse(item["created_at"])),
                          style: TextStyle(fontSize: 9.sp, color: Colors.white, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'],
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.grey.shade800, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (item['new_column_name'] != null) // Only show category if not null
                        Text(
                          'Category: ${item['new_column_name']}',
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                     GestureDetector(
  onTap: () {
    launch(item["url"]);
  },
  child: Container(
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

}



