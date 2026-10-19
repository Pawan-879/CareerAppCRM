import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentReportCard extends StatefulWidget {
  static const routeName = '/StudentReportCard';

  const StudentReportCard({super.key});

  @override
  _StudentReportCardState createState() => _StudentReportCardState();
}

class _StudentReportCardState extends State<StudentReportCard> {
  var data6 = [];
  var userData;
  var user_id;
  Color textColor = const Color(0xff2A2E48);
  String incharge = '';
  dynamic data = {};
  double amount = 0;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)!.settings.arguments;
      getData();
      setState(() {});
    });
  }

  getData() async {
    data6 = [];
    // var res = await ApiService.getMethod3("/getEducationalTrip");

    var res = await ApiService.getMethod3("/getParentsTips");

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
            margin: EdgeInsets.only(top: 11.h),
            width: double.infinity,
            height: 80.h,
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
                  child: Text('Parenting Tips',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 24.sp)),
                ),
                SizedBox(
                  height: 70,
                  child: Padding(
                    padding: EdgeInsets.only(left: 6.w, right: 6.w, top: 10),
                    child: const Text(
                      "Make Time for Your Kids",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  height: 60.h,
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

  Widget listTile(item) {
    return Container(
        margin: EdgeInsets.only(bottom: 2.h, left: 6.w, right: 6.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 3,
            ),
          ],
          borderRadius: const BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 17.w,
              height: 10.h,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                    "${ApiService.careerdefenceacademy2}includes/uploads/parent_tips/" +
                        item['image'],
                  ),
                ),
              ),
            ),
            SizedBox(width: 2.h),
            SizedBox(
              width: 60.w,
              child: ListTile(
                onTap: () {
                  launch((item["url"]));
                },
                contentPadding: EdgeInsets.zero,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'],
                        style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500)),
                    Text(
                      DateFormat('dd MMM yyyy')
                          .format(DateTime.parse(item["date"])),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
                trailing: Column(
                  children: [
                    const Icon(
                      Icons.remove_red_eye,
                      color: Colors.grey,
                    ),
                    Text('View',
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500))
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
