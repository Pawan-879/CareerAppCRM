import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as p;
import '../services/api_services.dart';

class WeeklyCopyStamping extends StatefulWidget {
  static const routeName = '/weekly_copy_stamping';

  const WeeklyCopyStamping({Key? key}) : super(key: key);

  @override
  State<WeeklyCopyStamping> createState() => _WeeklyCopyStampingState();
}

class _WeeklyCopyStampingState extends State<WeeklyCopyStamping> {
  var data6 = [];
  var heading = "Weekly Copy Stamping";
  var userData;
  var user_id;
  Color textColor = const Color(0xff2A2E48);
  String incharge = '';
  dynamic data = {};

  var isSelected = [false, false, false, false];
  var selected_school = 0;
  var selectedButton = 0;
  var subject = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)!.settings.arguments;
      subject = data["subject"];
      // selected_school = data["school_id"];
      print(data);
      getData();
    });
  }

  getData() async {
    data6 = [];
    // var res = await ApiService.getMethod3("/getWeeklyCopyStamping");

    var res = await ApiService.getMethod3(
        "/getWeeklyCopyStamping2?class_name=" +
            data["class_name"] +
            "&school_id=" +
            data["school_id"] +
            "&subject_name=" +
            data["subject_name"]);
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
                  child: Text(subject,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 26.sp)),
                ),
                SizedBox(height: 2.5.h),
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

  Widget listTile(item) {
    var type = p.extension(item['image']).toLowerCase();
    var subject =
        item['subject_name'].replaceAll('_', ' ').toString().toUpperCase();
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
            if (type == ".pdf")
              SizedBox(
                  width: 17.w,
                  height: 10.h,
                  child: Image.asset('assets/pdffile.png')),
            if (type != ".pdf")
              Container(
                width: 17.w,
                height: 10.h,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(
                      "${ApiService.careerdefenceacademy2}includes/uploads/weekly_copy_stamping/" +
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
                  launch("${ApiService.careerdefenceacademy2}includes/uploads/weekly_copy_stamping/" +
                      item['image']);
                  // dynamic row = {
                  //   "school_name": "Medical Report",
                  //   "url": ApiService.careerdefenceacademy2 +
                  //       "home/medical_report/" +
                  //       report.id!
                  // };
                  // Navigator.of(context)
                  //     .pushNamed(OpenUrl.routeName, arguments: row);
                },
                contentPadding: EdgeInsets.zero,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject,
                        style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500)),
                    Text(
                      DateFormat('dd MMM yyyy')
                          .format(DateTime.parse(item["created"])),
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

  //  DateFormat('dd MMM yyyy').format(DateTime.parse(item["date"])),
}
