import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentFreePaidForms extends StatefulWidget {
  static const routeName = '/StudentFreePaidForms';

  const StudentFreePaidForms({super.key});

  @override
  _StudentFreePaidFormsState createState() => _StudentFreePaidFormsState();
}

class _StudentFreePaidFormsState extends State<StudentFreePaidForms> {
  var data6 = [];
  var userData;
  var user_id;
  Color textColor = const Color(0xff2A2E48);
  String incharge = '';
  dynamic data = {};
  List<String> uniquelist = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)!.settings.arguments;

      getData(data["id"]);
      setState(() {});
    });
  }

  getData(id) async {
    var res =
        await ApiService.getMethod3("/getUserFreePaidForms?user_id=" + id);

    List<String> years = [];
    dynamic d = jsonDecode(res.body);
    data6 = d["data"];
    for (var element in data6) {
      years.add(element["year"]);
    }

    var seen = <String>{};
    uniquelist = years.where((country) => seen.add(country)).toList();

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
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.only(top: 18.h),
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
                    child: Text('Student Filled Forms',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 26.sp)),
                  ),
                  topcard(),
                  if (uniquelist.isNotEmpty)
                    Container(
                        margin: const EdgeInsets.all(20),
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: uniquelist.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 5.w, top: 2.h),
                                    child: Text(
                                      'Important Exam Form ${uniquelist[index]}',
                                      style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: data6.length,
                                    itemBuilder: (context, index2) {
                                      return data6[index2]["year"] ==
                                              uniquelist[index]
                                          ? listItem(data6[index2])
                                          : const SizedBox(height: 0);
                                    },
                                  )
                                ],
                              );
                            })),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget topcard() {
    return Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: 80,
              child: Image.asset(
                'assets/tax-form.png',
              ),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total number of applications',
                  style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w400)),
              Text(
                  "You Have Submit ${data6.length} Applications",
                  style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500)),
              SizedBox(
                height: 1.h,
              ),
              Text('Below You Can Get Info',
                  maxLines: 3,
                  style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.indigo.shade900,
                      fontWeight: FontWeight.w500)),
              SizedBox(
                height: 1.h,
              ),
              Text("Name: " + data["first_name"] + " " + data["last_name"]),
              SizedBox(
                height: 1.h,
              ),
              Text("DOB: ${DateFormat('dd MMM yyyy')
                      .format(DateTime.parse(data["dob"]))}"),
            ]),
          ],
        ));
  }

  Widget listItem(item) {
    return GestureDetector(
        onTap: () {
          print(item);
          showAlert(item);
        },
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item["form_name"].trim() ?? '',
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 10.sp),
                    ),
                    SizedBox(
                      height: 0.5.h,
                    ),
                    Text(
                      item["form_type"].trim(),
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w400,
                          fontSize: 10.sp),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Admit Card',
                      style: TextStyle(color: Colors.blue, fontSize: 12.sp),
                    ),
                    SizedBox(
                      height: 0.5.h,
                    ),
                    item["upload_admit_card"] == null
                        ? const Text('-')
                        : GestureDetector(
                            onTap: () async {
                              var path2 = "${ApiService.careerdefenceacademy2}includes/uploads/students_documents/upload_admit_card/" +
                                  item["upload_admit_card"];

                              launch(path2);
                              // final status = await Permission.storage.request();

                              // if (status.isGranted) {
                              //   final externalDir =
                              //       await getExternalStorageDirectory();

                              //   final id = await FlutterDownloader.enqueue(
                              //     url: path2,
                              //     savedDir: externalDir!.path,
                              //     fileName: item["upload_admit_card"],
                              //     showNotification: true,
                              //     openFileFromNotification: true,
                              //   );
                              // } else {
                              //   print("Permission deined");
                              // }
                            },
                            child: Row(
                              children: [
                                Text("Download",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    )),
                                const Icon(
                                  Icons.download,
                                  size: 14,
                                )
                              ],
                            ))
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Transaction Date',
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                            fontSize: 8.sp),
                      ),
                      Text(
                        item["transection_date"] == null
                            ? '-'
                            : DateFormat('dd MMM yyyy').format(
                                DateTime.parse(item["transection_date"])),
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 10.sp),
                      ),
                      SizedBox(
                        height: 0.5.h,
                      ),
                      Text(
                        'Amount Paid',
                        style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp),
                      ),
                      SizedBox(
                        height: 0.5.h,
                      ),
                      Text(
                        "Rs." + item["amt_paid"].trim(),
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w400,
                            fontSize: 10.sp),
                      )
                    ],
                  ))
            ],
          ),
        ));
  }

  showAlert(item) {
    return showDialog<bool>(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(item["form_name"]),
            actions: <Widget>[
              Container(
                child: DataTable(
                  columnSpacing: 30,
                  headingRowHeight: 40,
                  horizontalMargin: 5,
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                  headingRowColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.grey.shade300),
                  columns: const [
                    DataColumn(label: Text("Field Name")),
                    DataColumn(label: Text("Value")),
                  ],
                  rows: [
                    DataRow(cells: [
                      const DataCell(Text("Form Name")),
                      DataCell(Text(item["form_name"])),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text("Form Type")),
                      DataCell(Text(item["form_type"])),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text("Form Date")),
                      DataCell(item["form_date"] != null
                          ? Text(DateFormat('dd MMM yyyy')
                              .format(DateTime.parse(item["form_date"])))
                          : const Text('N/A')),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text("Exam Date")),
                      DataCell(item["exam_date"] != null
                          ? Text(DateFormat('dd MMM yyyy')
                              .format(DateTime.parse(item["exam_date"])))
                          : const Text('N/A')),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text("Admit Card")),
                      DataCell(item["upload_admit_card"] != null
                          ? GestureDetector(
                              onTap: () async {
                                var path2 = "${ApiService.careerdefenceacademy2}includes/uploads/students_documents/upload_admit_card/" +
                                    item["upload_admit_card"];

                                launch(path2);
                              },
                              child: Text("Download",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  )),
                            )
                          : const Text('N/A')),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text("Filled Form")),
                      DataCell(item["upload_fill_form"] != null
                          ? GestureDetector(
                              onTap: () async {
                                var path2 = "${ApiService.careerdefenceacademy2}includes/uploads/students_documents/upload_fill_form/" +
                                    item["upload_fill_form"];

                                launch(path2);
                              },
                              child: Text("Download",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  )),
                            )
                          : const Text('N/A')),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text("Transaction ID")),
                      DataCell(item["transection_id"] == null ||
                              item["transection_id"] == ''
                          ? const Text('N/A')
                          : Text(item["transection_id"])),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text("Transaction Date")),
                      DataCell(item["transection_date"] != null
                          ? Text(DateFormat('dd MMM yyyy')
                              .format(DateTime.parse(item["transection_date"])))
                          : const Text('N/A')),
                    ]),
                    DataRow(cells: [
                      const DataCell(Text("Amount Paid")),
                      DataCell(Text("Rs." + item["amt_paid"].trim())),
                    ]),
                  ],
                ),
              ),
            ],
          );
        });
  }
}
