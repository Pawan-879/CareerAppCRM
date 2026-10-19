import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../services/api_services.dart';
import 'package:intl/intl.dart';

import 'openurl.dart';

class StudentAttendanceReport extends StatefulWidget {
  static const routeName = '/StudentAttendanceReport';

  const StudentAttendanceReport({Key? key}) : super(key: key);

  @override
  State<StudentAttendanceReport> createState() =>
      _StudentAttendanceReportState();
}

class _StudentAttendanceReportState extends State<StudentAttendanceReport> {
  dynamic data = {};
  var school_id = "1";
  var report = [];
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
    var res = await ApiService.getMethod3(
        "/getStudentAttendanceReport?student_id=" + data["id"]);
    dynamic d = jsonDecode(res.body);
    report = d["data"];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Attendance Report",
          style: TextStyle(fontSize: 18.0),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(2.5.h),
            child: Text('Hi, ${data['first_name']}',
                style: TextStyle(
                    fontSize: 17.sp,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: deviceSize.height - 160,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 0.5.h),
              children:
                  report // Loops through dataColumnText, each iteration assigning the value to element
                      .map(
                        ((element) => listTile(
                              holidays: element["holidays"],
                              image: element["leave_application"],
                              status: element["status"],
                              reason: element["reason"],
                              date: DateFormat('dd MMM yyyy')
                                  .format(DateTime.parse(element["date"])),
                            )),
                      )
                      .toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget listTile(
      {String? holidays,
      String? image,
      String? status,
      String? reason,
      String? date}) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 3,
          ),
        ],
        borderRadius: const BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ListTile(
          contentPadding: EdgeInsets.all(2.h),
          title: Text("Days: ${holidays!}",
              style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500)),
          subtitle: Padding(
            padding: EdgeInsets.only(top: .7.h),
            child: Text("Status: ${status!}",
                style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500)),
          ),
          trailing: GestureDetector(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Leave Date',
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500))
                  ],
                ),
                Text(date!,
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.indigo.shade900,
                        fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            "Reason: $reason",
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height:10),
        const Padding(
          padding: EdgeInsets.only(left: 15),
          child: Text(
            "Leave Application Image",
            style: TextStyle(fontSize: 16),
          ),
        ),
        GestureDetector(
            onTap: () {
              dynamic data3 = {
                "school_name": "Leave Application",
                "url": "${ApiService.careerdefenceacademy2}includes/uploads/leave_application/$image"
              };
              Navigator.of(context)
                  .pushNamed(OpenUrl.routeName, arguments: data3);
            },
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.network(
                    "${ApiService.careerdefenceacademy2}includes/uploads/leave_application/${image!}",
                    fit: BoxFit.fill,
                    )))
      ]),
    );
  }
}
