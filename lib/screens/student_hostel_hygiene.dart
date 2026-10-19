import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:careerapp/models/stu_med-report_model.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentHostelHygiene extends StatefulWidget {
  static const routeName = '/StudentHostelHygiene';

  const StudentHostelHygiene({Key? key}) : super(key: key);

  @override
  _StudentHostelHygieneState createState() => _StudentHostelHygieneState();
}

class _StudentHostelHygieneState extends State<StudentHostelHygiene> {
  var data6 = [];
  var heading = "Hostel Hygiene Performa";
  var userData;
  var user_id;
  var date = '';
  var page = 1;
  StuHostelModel reportModel = StuHostelModel(data: []);
  List<StudentHostel> reportList = [];
  dynamic data = {};
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
        "${"/getHostelHygiene?user_id=" + data["id"]}&page=$page");
    dynamic d = jsonDecode(res.body);
    data6 = d["data"];
    date = data6[0]["date"];
    reportList = [];
    if (List.from(data6)
        .map((item) => StudentHostel.fromJson(item))
        .toList()
        .isNotEmpty) {
      reportList.addAll(List.from(data6)
          .map((item) => StudentHostel.fromJson(item))
          .toList());
    }
    reportModel = StuHostelModel(
        data: reportList,
        error: jsonDecode(res.body)['error'],
        status: jsonDecode(res.body)['status']);

    setState(() {});
  }

  prePage() {
    setState(() {
      page++;
      getData();
    });
  }

  nextPage() {
    setState(() {
      page--;
      getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            heading,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 15),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: [
            Container(
              height: 20.h,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50.0),
                    bottomRight: Radius.circular(50.0)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(2.5.h),
              child: Text('Hi, ${data['first_name']}',
                  style: TextStyle(
                      fontSize: 17.sp,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold)),
            ),
            Column(
              children: [
                Container(
                    margin: EdgeInsets.only(
                        bottom: 2.h, top: 7.h, left: 6.w, right: 6.w),
                    padding: EdgeInsets.all(2.5.h),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          FontAwesomeIcons.fileWaveform,
                          size: 40.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 2.h,
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Weekly Hostel Hygiene Record\nPerforma',
                                  maxLines: 3,
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.indigo.shade900,
                                      fontWeight: FontWeight.w500)),
                            ])
                      ],
                    )),
                if (date != '')
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MaterialButton(
                          elevation: 0,
                          textColor: Colors.white,
                          minWidth: 0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 10.0,
                          ),
                          color: Colors.grey[800],
                          onPressed: () {
                            prePage();
                          },
                          child: const Icon(Icons.keyboard_arrow_left),
                        ),
                        SizedBox(
                            height: 50.0,
                            width: 200,
                            child: Center(
                                child: Text(
                                    DateFormat('dd MMM yyyy')
                                        .format(DateTime.parse(date)),
                                    style: const TextStyle(fontSize: 20)))),
                        MaterialButton(
                          elevation: 0,
                          textColor: Colors.white,
                          minWidth: 0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 10.0,
                          ),
                          color: Colors.grey[800],
                          onPressed: () {
                            nextPage();
                          },
                          child: const Icon(Icons.keyboard_arrow_right),
                        ),
                      ]),
                SizedBox(
                  height: 450,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: reportList.length,
                    itemBuilder: (context, index) {
                      return listTile(report: reportList[index]);
                    },
                  ),
                ),
              ],
            )
          ],
        ));
    //   body: SafeArea(
    //       child: SingleChildScrollView(
    //           scrollDirection: Axis.horizontal,
    //           child: DataTable(
    //             columnSpacing: 30,
    //             headingRowHeight: 40,
    //             horizontalMargin: 5,
    //             headingTextStyle: const TextStyle(
    //                 fontWeight: FontWeight.bold, color: Colors.black),
    //             headingRowColor: MaterialStateProperty.resolveWith(
    //                 (states) => Colors.grey.shade300),
    //             columns: const [
    //               DataColumn(label: Text('#')),
    //               DataColumn(label: Text('Sick')),
    //               DataColumn(label: Text(' Details')),
    //               DataColumn(label: Text('Fee')),
    //               DataColumn(label: Text('Image')),
    //               DataColumn(label: Text('Date Time'))
    //             ],
    //             rows:
    //                 data6 // Loops through dataColumnText, each iteration assigning the value to element
    //                     .map(
    //                       ((element) => DataRow(
    //                             cells: <DataCell>[
    //                               DataCell(Text((data6.indexOf(element) + 1)
    //                                   .toString())), //
    //                               DataCell(Text(element["sick"])),
    //                               DataCell(SizedBox(
    //                                 width: 50,
    //                                 height: 25,
    //                                 child: TextButton(
    //                                   style: TextButton.styleFrom(
    //                                       backgroundColor: Colors.teal,
    //                                       padding: const EdgeInsets.all(5),
    //                                       shape: RoundedRectangleBorder(
    //                                         borderRadius:
    //                                             BorderRadius.circular(5),
    //                                       ),
    //                                       textStyle: const TextStyle(
    //                                         fontSize: 12,
    //                                         color: Colors.white,
    //                                       )),
    //                                   child: const Text(
    //                                     'View',
    //                                     style: TextStyle(color: Colors.white),
    //                                   ),
    //                                   onPressed: () {
    //                                     dynamic row = {
    //                                       "school_name": "Medical Report",
    //                                       "url":
    //                                           ApiService.careerdefenceacademy2 +
    //                                               "home/medical_report/" +
    //                                               element["id"]
    //                                     };
    //                                     Navigator.of(context).pushNamed(
    //                                         OpenUrl.routeName,
    //                                         arguments: row);
    //                                   },
    //                                 ),
    //                               )),

    //                               DataCell(Text(element["total_fee"])),
    //                               DataCell(element["image"] != null
    //                                   ? GestureDetector(
    //                                       onTap: () {
    //                                         dynamic row = {
    //                                           "school_name": "Image",
    //                                           "url": ApiService
    //                                                   .careerdefenceacademy2 +
    //                                               "includes/uploads/medical_form/" +
    //                                               element["image"]
    //                                         };
    //                                         Navigator.of(context).pushNamed(
    //                                             OpenUrl.routeName,
    //                                             arguments: row);
    //                                       },
    //                                       child: Image.network(
    //                                           ApiService.careerdefenceacademy2 +
    //                                               "includes/uploads/medical_form/thumb/" +
    //                                               element["image"],
    //                                           loadingBuilder:
    //                                               (BuildContext context,
    //                                                   Widget child,
    //                                                   ImageChunkEvent?
    //                                                       loadingProgress) {
    //                                         if (loadingProgress == null) {
    //                                           return child;
    //                                         }
    //                                         return Center(
    //                                           child: CircularProgressIndicator(
    //                                             value: loadingProgress
    //                                                         .expectedTotalBytes !=
    //                                                     null
    //                                                 ? loadingProgress
    //                                                         .cumulativeBytesLoaded /
    //                                                     loadingProgress
    //                                                         .expectedTotalBytes!
    //                                                 : null,
    //                                           ),
    //                                         );
    //                                       },
    //                                           width: 40.0,
    //                                           height: 40.0,
    //                                           fit: BoxFit.fill))
    //                                   : const Text("no image")),
    //                               DataCell(Text(element["created"]))
    //                             ],
    //                           )),
    //                     )
    //                     .toList(),
    //           ))),
    // );
  }

  Widget listTile({StudentHostel? report}) {
    return Container(
        margin: EdgeInsets.only(bottom: 2.h, left: 6.w, right: 6.w),
        padding: const EdgeInsets.all(10),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 80.w,
                  child: ListTile(
                      onTap: () {},
                      contentPadding: EdgeInsets.zero,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Floor Inchg.: ${report!.wardenName!}",
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 10),
                          Text("Floor Inchg. No.: ",
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500)),
                          GestureDetector(
                            onTap: () {
                              launch("tel://${report.wardenNo!}");
                            },
                            child: Text(report.wardenNo!,
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(height: 10),
                          Text('Floor: ${report.floor!}',
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                      trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Hostel No: ${report.hostelNo!}',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 5),
                            Text(
                              'Bed No: ${report.bedNo!}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey,
                              ),
                            )
                          ])),
                ),
              ],
            ),
            DataTable(
              columnSpacing: 20,
              headingRowHeight: 30,
              dataRowHeight: 30,
              horizontalMargin: 5,
              headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
              headingRowColor:
                  WidgetStateProperty.resolveWith((states) => Colors.cyan),
              columns: const [
                DataColumn(label: Text("#")),
                DataColumn(label: Text("Parameter of Inspection")),
                DataColumn(label: Text("Status")),
              ],
              rows: [
                DataRow(cells: [
                  const DataCell(Text("1")),
                  const DataCell(Text("Almira Management Status")),
                  DataCell(Text(report.almiraStatus!)),
                ]),
                DataRow(cells: [
                  const DataCell(Text("2")),
                  const DataCell(Text("Bedding Management Status")),
                  DataCell(Text(report.beddingStatus!)),
                ]),
                DataRow(cells: [
                  const DataCell(Text("3")),
                  const DataCell(Text("Hair Cutting Status")),
                  DataCell(Text(report.haircuttingStatus!)),
                ]),
                DataRow(cells: [
                  const DataCell(Text("4")),
                  const DataCell(Text("Laundry Status")),
                  DataCell(Text(report.laundryStatus!)),
                ]),
                DataRow(cells: [
                  const DataCell(Text("5")),
                  const DataCell(Text("Room Cleaning Status")),
                  DataCell(Text(report.roomCleaningStatus!)),
                ]),
                DataRow(cells: [
                  const DataCell(Text("6")),
                  const DataCell(Text("Wash Rooms Cleanness Status")),
                  DataCell(Text(report.washroomsCleannessStatus!)),
                ]),
                DataRow(cells: [
                  const DataCell(Text("7")),
                  const DataCell(Text("Electricity Status")),
                  DataCell(Text(report.electricityStatus!)),
                ]),
                DataRow(cells: [
                  const DataCell(Text("8")),
                  const DataCell(Text("Water Supply Status")),
                  DataCell(Text(report.waterSupplyStatus!)),
                ]),
                DataRow(cells: [
                  const DataCell(Text("9")),
                  const DataCell(Text("Discipline & Punctuality Status")),
                  DataCell(Text(report.disciplinePunctualityStatus!)),
                ]),
              ],
            ),
            const Divider(),
            const SizedBox(height: 5),
            Text('Remarks: ${report.remark!}',
                style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500)),
          ],
        ));
  }
}
