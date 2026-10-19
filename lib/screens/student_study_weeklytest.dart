import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:careerapp/screens/openurl.dart';
import 'package:careerapp/services/api_services.dart';

class StudentStudyWeeklyTest extends StatefulWidget {
  static const routeName = '/StudentStudyWeeklyTest';

  const StudentStudyWeeklyTest({Key? key}) : super(key: key);

  @override
  State<StudentStudyWeeklyTest> createState() => _StudentStudyWeeklyTestState();
}

class _StudentStudyWeeklyTestState extends State<StudentStudyWeeklyTest> {
  var isSelected = [true, false, false, false];
  var selectedButton = 0;
  var data6 = {};
  var data7 = [];
  var data8 = {};
  var data9 = [];
  var entrance = {};
  var ptmdetails = [];
  dynamic data = {};
  var date = "";
  var userData;
  var user_id;
  var study_status = "";
  var review = "";
  var page = 1;
  var obtain_marks = 0;
  var total_marks2 = 0;
  double total_average = 0;
  var present_days = 0;
  var total_days = 0;
  var attendance = {};
  var class_rank = "-";
  var school_rank = "-";
  var class_teacher_name = '';
  var class_teacher_mobile = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)!.settings.arguments;
      print(data);

      getData0();

      setState(() {});
    });
  }

  /* tab 1 start */

  getData0() async {
    obtain_marks = 0;
    total_marks2 = 0;
    var res = await ApiService.getMethod3("${"/getWeeklyResultReport2?user_id=" +
        data["id"]}&page=$page");

    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      data8 = d["data"];
      date = data8["date"];

      if (data8.isNotEmpty) {
        if (data8["english"] != null) {
          findtotals("English", data8["english"], data8["eng_total"],
              data8["eng_remark"]);
        }

        if (data8["maths"] != null) {
          findtotals("Maths", data8["maths"], data8["math_total"],
              data8["math_remark"]);
        }
        // if (data8["reasoning"] != null) {
        //   findtotals("Reasoning", data8["reasoning"], data8["reasoning_total"],
        //       data8["reasoning_remark"]);
        // }
        if (data8["science"] != null) {
          findtotals("Science", data8["science"], data8["science_total"],
              data8["science_remark"]);
        }
        if (data8["social_science"] != null) {
          findtotals("Social Science", data8["social_science"],
              data8["social_science_total"], data8["social_science_remark"]);
        }
        if (data8["gk"] != null) {
          findtotals("General Knowledge", data8["gk"], data8["gk_total"],
              data8["gk_remark"]);
        }
        if (data8["hindi"] != null) {
          findtotals(
              "Hindi", data8["hindi"], data8["hin_total"], data8["hin_remark"]);
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  findtotals(subject, marks, totalMarks, remark) {
    obtain_marks = obtain_marks + int.parse(marks);
    total_marks2 = total_marks2 + int.parse(totalMarks);
    total_average = (obtain_marks * 100) / total_marks2;

    if (total_average == 0) {
      study_status = "Not present";
    } else {
      if (total_average >= 70) {
        study_status = "Excellent";
      } else if (total_average >= 40 && total_average < 70) {
        study_status = "Good";
      } else {
        study_status = "Poor";
      }
    }

    setState(() {});
  }

  setPage(p) {
    page = 1;
    if (p == 0) {
      // getData0();
      // getStudentAttendance();
      // getData();
    }
  }

  prePage() {
    setState(() {
      page++;
      if (page >= 1) {
        if (selectedButton == 0) {
          getData0();
        }
      }
    });
  }

  nextPage() {
    setState(() {
      page--;
      if (page >= 1) {
        if (selectedButton == 0) {
          getData0();
        }
      }
    });
  }

  getAttendancePer() {
    var str = "";
    double val = 0;
    var status = "";
    if (total_days != 0) {
      val = (present_days / total_days) * 100;
    }
    if (val >= 91 && val <= 100) {
      status = "Excellent";
    } else if (val >= 81 && val <= 90) {
      status = "Very Good";
    } else if (val >= 71 && val <= 80) {
      status = "Good";
    } else {
      status = "Poor";
    }
    str = "${val.toStringAsFixed(0)}% $status";
    return str;
  }

  //   getClassRank() async {
  //   study_status = "";
  //   var res =
  //       await ApiService.getMethod3("/getClassRank?user_id=" + data["id"]);
  //   dynamic d = jsonDecode(res.body);
  //   if (d["error"] == false) {
  //     class_rank = d["data"];
  //   }
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  // getSchoolRank() async {
  //   study_status = "";
  //   var res =
  //       await ApiService.getMethod3("/getSchoolRank?user_id=" + data["id"]);
  //   print("/getSchoolRank?user_id=" + data["id"]);
  //   dynamic d = jsonDecode(res.body);
  //   if (d["error"] == false) {
  //     school_rank = d["data"];
  //   }
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text(
            "Student Old Weekly Test Results",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 15),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: const [],
        ),
        body: ListView(padding: const EdgeInsets.all(16.0), children: <Widget>[
          Stack(
            children: <Widget>[
              if (date != '')
                SizedBox(
                    height: 50.0,
                    width: double.infinity,
                    child: Center(
                        child: Text(
                            DateFormat('dd MMM yyyy')
                                .format(DateTime.parse(date)),
                            style: const TextStyle(fontSize: 20)))),
              Positioned(
                right: 0,
                top: 0.0,
                child: MaterialButton(
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
              ),
              Positioned(
                left: 0,
                top: 0.0,
                child: MaterialButton(
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
              ),
            ],
          ),
          Column(children: [
            const SizedBox(height: 10),
            // if (total_average >= 65)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              margin: const EdgeInsets.only(bottom: 10, top: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    "Subjects",
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: Colors.black),
                  ),
                  Text(
                    "Total Marks: $obtain_marks/$total_marks2 = ${total_average.toStringAsFixed(2)}%",
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  )
                ],
              ),
            ),
            //  if (total_average >= 65)
            SizedBox(
                child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    padding: const EdgeInsets.all(2),
                    children: [
                  if (data8["english"] != null)
                    anwersheet("English", data8["english"], data8["eng_total"],
                        data8["eng_remark"], data8["eng_file"], 'eng_file'),
                  if (data8["maths"] != null)
                    anwersheet(
                        "Maths",
                        data8["maths"],
                        data8["math_total"],
                        data8["math_remark"],
                        data8["maths_file"],
                        'maths_file'),
                  // if (data8["reasoning"] != null)
                  //   anwersheet(
                  //       "Reasoning",
                  //       data8["reasoning"],
                  //       data8["reasoning_total"],
                  //       data8["reasoning_remark"],
                  //       data8["reasoning_file"],
                  //       'reasoning_file'),
                  if (data8["science"] != null)
                    anwersheet(
                        "Science",
                        data8["science"],
                        data8["science_total"],
                        data8["science_remark"],
                        data8["science_file"],
                        'science_file'),
                  if (data8["social_science"] != null)
                    anwersheet(
                        "Social Science",
                        data8["social_science"],
                        data8["social_science_total"],
                        data8["social_science_remark"],
                        data8["social_science_file"],
                        'social_science_file'),
                  if (data8["gk"] != null)
                    anwersheet(
                        "General Knowledge",
                        data8["gk"],
                        data8["gk_total"],
                        data8["gk_remark"],
                        data8["gk_file"],
                        'gk_file'),
                  if (data8["hindi"] != null)
                    anwersheet("Hindi", data8["hindi"], data8["hin_total"],
                        data8["hin_remark"], data8["hindi_file"], 'hindi_file'),
                  if (data8["punjabi"] != null)
                    anwersheet(
                        "Punjabi",
                        data8["punjabi"],
                        data8["punjabi_total"],
                        data8["punjabi_remark"],
                        data8["punjabi_file"],
                        'punjabi_file'),
                ]))
          ]),
        ]));
  }

  getTotals(record) {
    var obtains = int.parse(entrance['english']) +
        int.parse(entrance['maths']) +
        int.parse(entrance['reasoning']) +
        int.parse(entrance['gk']);
    var totals = int.parse(entrance['eng_total']) +
        int.parse(entrance['maths_total']) +
        int.parse(entrance['reasoning_total']) +
        int.parse(entrance['gk_total']);
    return '$obtains/$totals';
  }

  getPercentage(record) {
    var obtains = int.parse(entrance['english']) +
        int.parse(entrance['maths']) +
        int.parse(entrance['reasoning']) +
        int.parse(entrance['gk']);
    var totals = int.parse(entrance['eng_total']) +
        int.parse(entrance['maths_total']) +
        int.parse(entrance['reasoning_total']) +
        int.parse(entrance['gk_total']);

    var per = (obtains / totals) * 100;
    return '${per.toStringAsFixed(2)}%';
  }

  getQualified(record) {
    var obtains = int.parse(entrance['english']) +
        int.parse(entrance['maths']) +
        int.parse(entrance['reasoning']) +
        int.parse(entrance['gk']);
    var totals = int.parse(entrance['eng_total']) +
        int.parse(entrance['maths_total']) +
        int.parse(entrance['reasoning_total']) +
        int.parse(entrance['gk_total']);

    var per = (obtains / totals) * 100;
    var str = "";
    if (per >= 75) {
      str = "Qualified for \nInterview";
    } else {
      str = "Not Qualified \nfor Interview";
    }
    return str.toString();
  }

  //  if (data8["ncc_training"] != null)
  //                         anwersheet(
  //                             "NCC Training",
  //                             data8["ncc_training"],
  //                             data8["ncc_training_total"],
  //                             data8["ncc_training_remark"],
  //                             data8["ncc_training_file"],
  //                             'ncc_training_file'),
  //                       if (data8["communication_classes"] != null)
  //                         anwersheet(
  //                             "Communication Classes",
  //                             data8["communication_classes"],
  //                             data8["communication_classes_total"],
  //                             data8["communication_classes_remark"],
  //                             data8["communication_classes_file"],
  //                             'communication_classes_file'),
  //                       if (data8["sport_activity"] != null)
  //                         anwersheet(
  //                             "Sport Activity",
  //                             data8["sport_activity"],
  //                             data8["sport_activity_total"],
  //                             data8["sport_activity_remark"],
  //                             data8["sport_activity_file"],
  //                             'sport_activity_file'),

  Widget anwersheet(
      subject, marks, totalMarks, remark, answerSheet, filepath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                subject,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[900]),
              ),
              Text("Remark: $remark")
            ],
          ),
          if (answerSheet != null)
            GestureDetector(
              child: const Text("Answer Sheet"),
              onTap: () {
                dynamic data3 = {
                  "school_name": subject,
                  "url": "${ApiService.careerdefenceacademy2}includes/uploads/answersheets/" +
                      filepath +
                      "/" +
                      answerSheet
                };
                Navigator.of(context)
                    .pushNamed(OpenUrl.routeName, arguments: data3);
              },
            ),
          Text("$marks/$totalMarks")
        ],
      ),
    );
  }
}
