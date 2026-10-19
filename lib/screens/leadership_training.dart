import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_services.dart';
import 'youtube_player.dart';

class LeadershipTrainingScreen extends StatefulWidget {
  const LeadershipTrainingScreen({Key? key}) : super(key: key);

  @override
  State<LeadershipTrainingScreen> createState() =>
      _LeadershipTrainingScreenState();
}

class _LeadershipTrainingScreenState extends State<LeadershipTrainingScreen> {
  var data6 = [];
  var heading = "Leadership Training";
  var userData;
  var user_id;
  Color textColor = const Color(0xff2A2E48);
  String incharge = '';
  dynamic data = {};

  var isSelected = [false, false, false, false];
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
        "/getLeaderShipTraining?school_id=$selected_school");

    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      data6 = d["data"];
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
                  child: Text('Leadership\nTraining',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 26.sp)),
                ),
                SizedBox(
                  height: 78.h,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                                  padding: const EdgeInsets.fromLTRB(
                                      5.0, 16.0, 5.0, 16.0),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text("AMBALA"),
                                    ],
                                  ),
                                ),
                                Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.fromLTRB(
                                      5.0, 16.0, 5.0, 16.0),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text("YAMUNANAGR"),
                                    ],
                                  ),
                                ),
                                Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.fromLTRB(
                                      5.0, 16.0, 5.0, 16.0),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text("PATIALA"),
                                    ],
                                  ),
                                ),
                                Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.fromLTRB(
                                      5.0, 16.0, 5.0, 16.0),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text("BADDI"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5.w, top: 1.h),
                          child: Text(
                            'Most Popular',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        SizedBox(
                          height: 70.h,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: data6.length,
                            itemBuilder: (context, index) {
                              return listItem(data6[index]);
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

  Widget listItem(item) {
    return InkWell(
      onTap: () {
        if (item['content_type'] == 'youtube') {
          Navigator.of(context)
              .pushNamed(Youtubevideo.routeName, arguments: item["url"]);
        }
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
              height: 15.h,
              child: Column(
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
                      CircleAvatar(
                        radius: 3.w,
                        backgroundColor: Colors.blue,
                        backgroundImage: const AssetImage(
                          "assets/profileimg.png",
                        ),
                      ),
                      SizedBox(
                        width: 1.5.h,
                      ),
                      Expanded(
                        child: Text(
                          item['speaker'],
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontSize: 11.sp),
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy')
                            .format(DateTime.parse(item["date"])),
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w400,
                            fontSize: 12.sp),
                      ),
                    ],
                  ),
                  if (item['content_type'] == 'photo')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(children: [
                          Icon(
                            Icons.camera,
                            color: Colors.red,
                          ),
                          Text("Photos: ", style: TextStyle(fontSize: 16)),
                        ]),
                        ElevatedButton.icon(
                          onPressed: () {
                            launch(item['url']);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.5.w, vertical: 0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                          icon: Padding(
                            padding: EdgeInsets.only(right: 0.w),
                            child: Text(
                              'View',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  fontSize: 12.sp),
                            ),
                          ),
                          label: const Icon(
                            Icons.arrow_forward,
                            size: 12,
                          ),
                        )
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
