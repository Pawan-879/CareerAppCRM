import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentActivityReport extends StatefulWidget {
  static const routeName = '/StudentActivityReport';

  const StudentActivityReport({Key? key}) : super(key: key);

  @override
  _StudentActivityReportState createState() => _StudentActivityReportState();
}

class _StudentActivityReportState extends State<StudentActivityReport> {
  var data6 = [];
  var heading = "Award & Reward";
  var userData;
  var user_id;
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
    var res =
        await ApiService.getMethod3("/getActivityReport?user_id=" + data["id"]);
    dynamic d = jsonDecode(res.body);
    data6 = d["data"];
    print(data6);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          heading,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 15),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: const [],
      ),
      body: Container(
          child: ListView(children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              child: Container(
                  padding: const EdgeInsets.only(
                      left: 0.0, right: 0.0, top: 0.0, bottom: 1.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(0),
                        bottomRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                        topLeft: Radius.circular(0)),
                    color: Colors.blue,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 6.0),
                    ],
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Hello",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white)),
                          const SizedBox(height: 10),
                          Text(
                              data["first_name"] +
                                  " " +
                                  data["last_name"].toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 35,
                                  color: Colors.white)),
                          const SizedBox(height: 10),
                          Image.asset("assets/awards.png")
                        ],
                      ))),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            "Reward Details",
            style: TextStyle(fontSize: 20),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: data6.length,
          itemBuilder: (context, index) {
            return listTile(data6[index]);
          },
        ),
      ])),
    );
  }

  Widget listTile(dynamic item) {
    return Container(
        margin: EdgeInsets.only(bottom: 2.h, left: 2.w, right: 2.w),
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
              width: 20.w,
              height: 12.h,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                    "${ApiService.careerdefenceacademy2}includes/uploads/activity_report/image/" +
                        item["image"],
                  ),
                ),
              ),
            ),
            SizedBox(width: 2.h),
            SizedBox(
              width: 60.w,
              child: ListTile(
                onTap: () {},
                contentPadding: EdgeInsets.zero,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item["activity_name"],
                        style: TextStyle(
                            fontSize: 17.sp,
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
                // subtitle: Padding(
                //   padding: EdgeInsets.only(top: 1.h),
                //   child: Row(
                //     children: [
                //       Text('Incharge: '+item["incharge"],
                //           style: TextStyle(
                //               fontSize: 13.sp,
                //               color: Colors.grey.shade800,
                //               fontWeight: FontWeight.w500)),

                //     ],
                //   ),
                // ),
                trailing: Column(
                  children: [
                    const Icon(
                      Icons.download,
                      color: Colors.grey,
                    ),
                    GestureDetector(
                        onTap: () async {
                          var path2 = "${ApiService.careerdefenceacademy2}includes/uploads/activity_report/attachment_certificate/" +
                              item["attachment_certificate"];

                          launch(path2);
                          // final status =
                          //     await Permission.storage.request();

                          // if (status.isGranted) {
                          //   final externalDir =
                          //       await getExternalStorageDirectory();

                          //   final id =
                          //       await FlutterDownloader.enqueue(
                          //     url: path2,
                          //     savedDir: externalDir!.path,
                          //     fileName:
                          //         item["attachment_certificate"],
                          //     showNotification: true,
                          //     openFileFromNotification: true,
                          //   );
                          // } else {
                          //   print("Permission deined");
                          // }
                        },
                        child: Text('Download',
                            style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500)))
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}


/*
SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 30,
            headingRowHeight: 40,
            dataRowHeight: 100,
            horizontalMargin: 5,
            headingTextStyle: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
            headingRowColor: MaterialStateProperty.resolveWith(
                (states) => Colors.grey.shade300),
            columns: const [
              DataColumn(label: Text('#')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Image')),
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Incharge')),
              DataColumn(label: Text('Certificate')),
            ],
            rows:
                data6 // Loops through dataColumnText, each iteration assigning the value to element
                    .map(
                      ((element) => DataRow(
                            cells: <DataCell>[
                              DataCell(Text(
                                  (data6.indexOf(element) + 1).toString())), //
                              DataCell(Text(element[
                                  "activity_name"])), //Extracting from Map element the value
                              DataCell(Image.network(
                                  ApiService.careerdefenceacademy2 +
                                      "includes/uploads/activity_report/image/" +
                                      element["image"],
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              }, width: 80.0, height: 80.0, fit: BoxFit.fill)),

                              DataCell(Text(element["date"])),
                              DataCell(Text(element["incharge"])),
                              DataCell(GestureDetector(
                                  onTap: () async {
                                    var path2 = ApiService
                                            .careerdefenceacademy2 +
                                        "includes/uploads/activity_report/attachment_certificate/" +
                                        element["attachment_certificate"];
                                    final status =
                                        await Permission.storage.request();

                                    if (status.isGranted) {
                                      final externalDir =
                                          await getExternalStorageDirectory();

                                      final id =
                                          await FlutterDownloader.enqueue(
                                        url: path2,
                                        savedDir: externalDir!.path,
                                        fileName:
                                            element["attachment_certificate"],
                                        showNotification: true,
                                        openFileFromNotification: true,
                                      );
                                    } else {
                                      print("Permission deined");
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          const Radius.circular(20.0)),
                                      gradient: LinearGradient(
                                        colors: <Color>[
                                          Colors.red[200]!,
                                          Colors.red
                                        ],
                                      ),
                                    ),
                                    child: const Icon(Icons.archive,
                                        color: Colors.white),
                                  ))),
                            ],
                          )),
                    )
                    .toList(),
          ),
        ),
      ) */