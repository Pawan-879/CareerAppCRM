import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:convert';
import 'dart:async';

import '../widgets/custom_stepper.dart';

class StudentFeedback extends StatefulWidget {
  static const routeName = '/StudentFeedbacks';

  const StudentFeedback({Key? key}) : super(key: key);

  @override
  _StudentFeedbackState createState() => _StudentFeedbackState();
}

class _StudentFeedbackState extends State<StudentFeedback> {
  var isSelected = [false, false, false];
  var selected_school = 0;
  var selectedButton = 0;
  var data6 = [];
  var heading = "Cleaning & Maintenance Report";
  var userData;
  var user_id;
  dynamic data = {};
  Color textColor = const Color(0xFF2A2E48);
  List<CustomStep> todoSteps = [];
  late PageController _pageController;
  late Timer _timer;
  final int _currentPage = 0;
  final List<String> cleaningTimes = [
    "Daily Cleaning time 8 am to 1 pm (Morning)",
    "Daily Cleaning time 4 pm to 6 pm (Evening)",
    "Daily Cleaning Time 8 pm to 12 pm (Night)",
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)!.settings.arguments;

      getData();
      setState(() {});
    });
  }

  myfilter() {
    getData();
    setState(() {});
  }

  getData() async {
    var res = await ApiService.getMethod3(
        "/getFeedbacksV2?school_id=$selected_school");
    dynamic d = jsonDecode(res.body);
    print(d);

    setState(() {
      data6 = d["data"];
      todoSteps = data6.asMap().entries.map<CustomStep>((e) {
        var todo = e.value;
        return CustomStep(
          title: InkWell(
            onTap: () async {
              if (await canLaunchUrlString(todo["url"])) {
                await launchUrlString(todo["url"]);
              } else {
                throw "Could not launch " + todo["url"];
              }
            },
            child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(15.0),
                    )),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.h, vertical: 2.h),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Image.asset(
                          'assets/clean.png',
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 11.0.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              todo['cleaning'].trim() ?? '',
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.sp),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              DateFormat('EEEE')
                                  .format(DateTime.parse(todo['date'])),
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10.sp),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              DateFormat('dd MMM yyyy')
                                  .format(DateTime.parse(todo['date'])),
                              style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10.sp),
                            )
                          ],
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.only(top: 4.5.h),
                          alignment: Alignment.bottomRight,
                          child: Image.asset(
                            'assets/clean_arrow.png',
                            filterQuality: FilterQuality.high,
                          ))
                    ],
                  ),
                )),
          ),
          content: const Text(''),
          isActive: true,
        );
      }).toList();
    });
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
        backgroundColor: Colors.blue[500],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 15, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            // Container(
            //   margin: EdgeInsets.only(top: 12.h),
            //   decoration: const BoxDecoration(
            //       color: Color(0xFFF4F5FD),
            //       borderRadius: BorderRadius.only(
            //         topLeft: Radius.circular(45.0),
            //         topRight: Radius.circular(45.0),
            //       )),
            // ),

            Padding(
              padding: const EdgeInsets.only(
                  // top: 24.h,
                  // left: 1.w,
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
                    child: SizedBox(
                      width: double.infinity, // Full width
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              Colors.blue, // Background color changed to blue
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(2.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Daily Cleaning Times:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    Colors.white, // Text color changed to white
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              "Daily Cleaning time 8 am to 1 pm (Morning)",
                              style: TextStyle(
                                color:
                                    Colors.white, // Text color changed to white
                                fontSize: 11.sp,
                              ),
                            ),
                            Text(
                              "Daily Cleaning time 4 pm to 6 pm (Evening)",
                              style: TextStyle(
                                color:
                                    Colors.white, // Text color changed to white
                                fontSize: 11.sp,
                              ),
                            ),
                            Text(
                              "Daily Cleaning Time 8 pm to 12 pm (Night)",
                              style: TextStyle(
                                color:
                                    Colors.white, // Text color changed to white
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  ToggleButtons(
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
                            Text(
                              "AMBALA",
                              style: TextStyle(fontSize: 12),
                            ),
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
                            Text(
                              "YAMUNANAGR",
                              style: TextStyle(fontSize: 12),
                            ),
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
                            Text(
                              "PATIALA",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  todoSteps.isEmpty
                      ? SizedBox(
                          height: 40.h,
                          child: const Center(child: Text('Loading...')),
                        )
                      : SizedBox(
                          height: 51.2.h,
                          child: CustomStepper(
                            steps: todoSteps,
                            lineHeight: 34,
                          ),
                        )
                ],
              ),
            ),
          ],
        ),
      ),
      // body: SafeArea(
      //     child: SingleChildScrollView(
      //         scrollDirection: Axis.horizontal,
      //         child: DataTable(
      //           columnSpacing: 30,
      //           headingRowHeight: 40,
      //           horizontalMargin: 5,
      //           headingTextStyle: const TextStyle(
      //               fontWeight: FontWeight.bold, color: Colors.black),
      //           headingRowColor: MaterialStateProperty.resolveWith(
      //               (states) => Colors.grey.shade300),
      //           columns: const [
      //             DataColumn(label: Text('#')),
      //             DataColumn(label: Text('Cleaning')),
      //             DataColumn(label: Text('URL')),
      //             DataColumn(label: Text('Date')),
      //           ],
      //           rows:
      //               data6 // Loops through dataColumnText, each iteration assigning the value to element
      //                   .map(
      //                     ((element) => DataRow(
      //                           cells: <DataCell>[
      //                             DataCell(Text((data6.indexOf(element) + 1)
      //                                 .toString())), //
      //                             DataCell(Text(element["cleaning"])),
      //                             DataCell(TextButton(
      //                               style: TextButton.styleFrom(
      //                                 shape: RoundedRectangleBorder(
      //                                     borderRadius:
      //                                         BorderRadius.circular(5)),
      //                                 textStyle: const TextStyle(
      //                                     fontSize: 12, color: Colors.white),
      //                                 backgroundColor: Colors.teal[400],
      //                                 padding: const EdgeInsets.all(5),
      //                               ),
      //                               child: const Text('View',
      //                                   style: TextStyle(color: Colors.white)),
      //                               onPressed: () async {
      //                                 if (await canLaunch(element["url"]))
      //                                   await launch(element["url"]);
      //                                 else
      //                                   // can't launch url, there is some error
      //                                   throw "Could not launch " +
      //                                       element["url"];
      //                               },
      //                             )), //Extracting from Map element the value

      //                             DataCell(Text(element["date"]))
      //                           ],
      //                         )),
      //                   )
      //                   .toList(),
      //         ))),
    );
  }
}
