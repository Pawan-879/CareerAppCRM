import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:careerapp/screens/leadership_training.dart';
import 'package:careerapp/screens/student_calling_report.dart';
import 'package:careerapp/screens/student_canteen_report.dart';
import 'package:careerapp/screens/student_details.dart';
import 'package:careerapp/screens/student_fee_paid_forms.dart';
import 'package:careerapp/screens/student_feedback.dart';
import 'package:careerapp/screens/student_fees_detail.dart';
import 'package:careerapp/screens/student_fine_charges.dart';
import 'package:careerapp/screens/student_hostel_hygiene.dart';
import 'package:careerapp/screens/student_import_updates.dart';
import 'package:careerapp/screens/student_medical_report.dart';
import 'package:careerapp/screens/student_references.dart';
import 'package:careerapp/screens/student_results.dart';
import 'package:careerapp/screens/student_study_report.dart';
import 'package:careerapp/screens/student_weekly_activity.dart';
import 'package:careerapp/screens/student_weekly_report.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:url_launcher/url_launcher.dart';

class Dashboard33 extends StatefulWidget {
  static const routeName = '/Dashboard33';

  const Dashboard33({Key? key}) : super(key: key);

  @override
  State<Dashboard33> createState() => _Dashboard33State();
}

class _Dashboard33State extends State<Dashboard33> {
  var data;
  var user = {};
  var full_name = "Loading...";
  var father_name = "";
  var class_name = "";
  var location = "";
  var due_fee = "";
  var batch = "...";
  var dateofjoining = "";
  var balance = "0";
  var dob = "";
  var form1 = 0;
  var pocket_money = "0";
  var mobile = "";
  var father_mobile = "";

  var student_type = "";
  var due_date = "-";
  var staff_name = '';
  var staff_mobile = '';
  var data7 = [];
  var due_fees = '0';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)?.settings.arguments;
      loadStudentData(data["user_id"]);
      loadFreePaidForms(data["user_id"]);
      getData(data["user_id"]);
    });
    setState(() {});
  }

  loadStudentData(id) async {
    var res = await ApiService.getMethod3("/getStudentDetail?user_id=" + id);

    dynamic d = jsonDecode(res.body);

    user = d["data"];
    loadStaffDetail(user["user_id"]);
    print(user);
    setState(() {
      full_name = user["first_name"];
      if (user["last_name"] != null) {
        full_name += " ${user["last_name"]}";
      }
      student_type = user["student_type"];
      father_name = user["father_name"].toString();
      if (user["class_for"] != null && user["class_for"] != '') {
        class_name = user["class_for"];
      }
      if (user["city"] != null) location = user["city"];
      if (user["state"] != null) location += "${"(" + user["state"]})";
      if (user["balance"] != null) {
        balance = user["balance"];
      }
      if (user["mobile"] != null) {
        mobile = user["mobile"];
      }
      if (user["father_mobile"] != null) {
        mobile = user["father_mobile"];
      }
      if (user["pocket_money"] != null) {
        pocket_money = user["pocket_money"];
      }
      if (user["batch"] != null) {
        batch = "Batch: ${user["batch"]}";
      }
      if (user["created"] != null) {
        dateofjoining =
            "Date of joining: ${DateFormat('dd MMM yyyy').format(DateTime.parse(user["created"]))}";
      }
      if (user["dob"] != null) {
        dob = user["dob"].toString();
      }
      // if (user["due_fees"] != null) {
      //   due_fee = user["due_fees"];
      // }
      // if (user["due_date"] != null) {
      //   due_date =
      //       DateFormat('dd MMM yyyy').format(DateTime.parse(user["due_date"]));
      // }
    });
  }

  getData(id) async {
    var res = await ApiService.getMethod3("/getFeeDetails?user_id=" + id);
    dynamic d = jsonDecode(res.body);
    data7 = d["data"];
    print("vikas");
    print(data7);
    if (data7[0]["due_fees"] != null && data7[0]["due_fees"] != '0') {
      due_fees = data7[0]["due_fees"];
    }
    if (data7[0]["due_date"] != null && data7[0]["due_date"] != '') {
      due_date = DateFormat('dd MMM yyyy')
          .format(DateTime.parse(data7[0]["due_date"]));
    }
    setState(() {});
  }

  loadStaffDetail(staffId) async {
    var res =
        await ApiService.getMethod3("/getStaffDetail?user_id=" + staffId);

    dynamic d = jsonDecode(res.body);
    if (d["status"] == "200" || d["status"] == 200) {
      staff_name = d["data"]["name"];
      staff_mobile = d["data"]["mobile"];
    }
    setState(() {});
  }

  loadFreePaidForms(id) async {
    var res =
        await ApiService.getMethod3("/getUserFreePaidForms?user_id=" + id);
    print("/getUserFreePaidForms?user_id=" + id);

    dynamic d = jsonDecode(res.body);
    if (d["status"] == "200" || d["status"] == 200) {
      form1 = d["data"].length;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xfff4f4f4),
      appBar: AppBar(
        title: const Text(
          "Dashboard33",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 15),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: ListView(children: [
          Stack(
            children: [
              Positioned(
                child: Container(
                    padding: const EdgeInsets.only(
                        left: 0.0, right: 0.0, top: 0.0, bottom: 30.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(0),
                          bottomRight: Radius.circular(30),
                          bottomLeft: Radius.circular(30),
                          topLeft: Radius.circular(0)),
                      color: Colors.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 6.0),
                      ],
                    ),
                    child: Column(
                      children: [
                        Column(children: [
                          Container(
                            height: 90,
                            margin: const EdgeInsets.only(top: 40),
                            child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(50),
                                    bottomRight: Radius.circular(50),
                                    bottomLeft: Radius.circular(50),
                                    topLeft: Radius.circular(50)),
                                child: Image.network(
                                    "${ApiService.websiteUrl}ads/profileimg.png",
                                    height: 90.0,
                                    fit: BoxFit.fill)),
                          ),
                        ]),
                        const Padding(
                          padding: EdgeInsets.all(0),
                        ),
                        Text(
                          full_name,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "S/O: $father_name",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          batch,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        if (location != '') const SizedBox(height: 5),
                        if (location != '')
                          Text(
                            location,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 5),
                        Text(
                          dateofjoining,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )),
              ),
              Positioned(
                  child: Container(
                      margin:
                          const EdgeInsets.only(top: 250, left: 40, right: 40),
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: Colors.white,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 6.0),
                        ],
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                      child: GestureDetector(
                                          onTap: () {},
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Image.asset(
                                                  "assets/icon/class.png",
                                                  fit: BoxFit.fitHeight,
                                                  height: 20),
                                              const SizedBox(width: 5.0),
                                              Column(
                                                children: [
                                                  const Text(
                                                    "Student Class",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 14.0),
                                                  ),
                                                  Text(
                                                    class_name,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 14.0),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ))),
                                  Expanded(
                                    child: GestureDetector(
                                        onTap: () {},
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Image.asset("assets/icon/star.png",
                                                fit: BoxFit.fitHeight,
                                                height: 20),
                                            const SizedBox(width: 5.0),
                                            Column(
                                              children: [
                                                const Text(
                                                  "Student Number",
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      TextStyle(fontSize: 14.0),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    launch("tel://$mobile");
                                                  },
                                                  child: Text(
                                                    mobile,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color: Colors.blue,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        fontSize: 14.0),
                                                  ),
                                                ),
                                                 GestureDetector(
                                                  onTap: () {
                                                    launch("tel://$father_mobile");
                                                  },
                                                  child: Text(
                                                    father_mobile,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color: Colors.blue,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        fontSize: 14.0),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        )),
                                  ),
                                ]),
                            const SizedBox(height: 15),
                            if (user["school_id"] == '1' ||
                                user["school_id"] == 1)
                              Column(
                                children: [
                                  Row(children: [
                                    const Text(
                                        'Senior Counsellor - Ms Nancy Garg: '),
                                    GestureDetector(
                                        onTap: () {
                                          launch("tel://7027333764");
                                        },
                                        child: const Text("7889086372",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline))),
                                  ]),
                                  const SizedBox(height: 10),
                                  Row(children: [
                                    const Text(
                                        'Chief Warden - Mr Naresh (Ex Army): '),
                                    GestureDetector(
                                        onTap: () {
                                          launch("tel://9254031719");
                                        },
                                        child: const Text("9254031719",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline))),
                                  ]),
                                ],
                              ),
                            if (user["school_id"] == '2' ||
                                user["school_id"] == 2)
                              Column(
                                children: [
                                  Row(children: [
                                    const Text(
                                        'Senior Counsellor - Ms Nancy Garg: '),
                                    GestureDetector(
                                        onTap: () {
                                          launch("tel://7027333764");
                                        },
                                        child: const Text("7027333764",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline))),
                                  ]),
                                  const SizedBox(height: 10),
                                  Row(children: [
                                    const Text('Chief Warden - Mr Milap '),
                                    GestureDetector(
                                        onTap: () {
                                          launch("tel://9254995157");
                                        },
                                        child: const Text("9254995157",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline))),
                                  ]),
                                ],
                              ),

                            if (student_type == 'Hostel')
                              Column(
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        launch("tel://7889086372");
                                      },
                                      child: const Text(
                                          "Senior Counsellor - Neetu No 7889086372")),
                                  if (staff_mobile != '')
                                    GestureDetector(
                                        onTap: () {
                                          launch("tel://$staff_mobile");
                                        },
                                        child: Text(" Counsellor - $staff_name No $staff_mobile")),
                                ],
                              ),
                            const SizedBox(height: 5),
                            if (student_type == 'Evening')
                              Column(
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        launch("tel://8950618074");
                                      },
                                      child: const Text(
                                          "Senior Counsellor -Rakhi No 8950618074")),
                                  if (staff_mobile != '')
                                    GestureDetector(
                                        onTap: () {
                                          launch("tel://$staff_mobile");
                                        },
                                        child: Text(" Counsellor - $staff_name No $staff_mobile")),
                                ],
                              ),
                            const SizedBox(height: 5),
                            if (student_type == 'Recorded')
                              Column(
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        launch("tel://8950618074");
                                      },
                                      child: const Text(
                                          "Senior Counsellor -Rakhi No 8950618074")),
                                  if (staff_mobile != '')
                                    GestureDetector(
                                        onTap: () {
                                          launch("tel://$staff_mobile");
                                        },
                                        child: Text(" Counsellor - $staff_name No $staff_mobile")),
                                ],
                              ),
                            const SizedBox(height: 5),
                            if (student_type == 'Only Products')
                              Column(
                                children: [
                                  GestureDetector(
                                      onTap: () {
                                        launch("tel://7419999228");
                                      },
                                      child: const Text(
                                          "Senior Counsellor - Office No 7419999228")),
                                  if (staff_mobile != '')
                                    GestureDetector(
                                        onTap: () {
                                          launch("tel://$staff_mobile");
                                        },
                                        child: Text(" Counsellor - $staff_name No $staff_mobile")),
                                ],
                              )
                          ])))
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(10),
                minimumSize: const Size(150, 50),
                backgroundColor: Colors.teal[400],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
              child: const Text('Important Updates',
                  style: TextStyle(fontSize: 12, color: Colors.white)),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StudentImportUpdates()));
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(10),
                minimumSize: const Size(150, 50),
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
              child: const Text('Form Details',
                  style: TextStyle(fontSize: 12, color: Colors.white)),
              onPressed: () {
                if (form1 != 0) {
                  Navigator.of(context).pushNamed(
                      StudentFreePaidForms.routeName,
                      arguments: user);
                }
                // Navigator.of(context)
                //     .pushNamed(StudentRequirements.routeName, arguments: user);
              },
            ),
          ]),
          const SizedBox(height: 5),
          Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                              StudentFeesDetail.routeName,
                              arguments: user);
                        },
                        child: Container(
                            padding: const EdgeInsets.all(20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              color: Colors.white,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    offset: const Offset(0, 2),
                                    blurRadius: 6.0),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Due Fees: ",
                                      style: TextStyle(fontSize: 14.0),
                                    ),
                                    Text(
                                      "Rs $due_fees",
                                      style: const TextStyle(fontSize: 14.0),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      "Due Date: ",
                                      style: TextStyle(fontSize: 14.0),
                                    ),
                                    Text(
                                      due_date,
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                  ],
                                )
                              ],
                            ))),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        if (form1 != 0) {
                          Navigator.of(context).pushNamed(
                              StudentFreePaidForms.routeName,
                              arguments: user);
                        }
                      },
                      child: Container(
                          padding: const EdgeInsets.all(20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color: Colors.white,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 6.0),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Free Forms: ",
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                  Text(
                                    "3",
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    "Filled Forms: ",
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                  Text(
                                    form1.toString(),
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              )
                            ],
                          )),
                    ),
                  ])),
          Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 20.0, bottom: 30.0),
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(0),
                    bottomLeft: Radius.circular(0),
                    topLeft: Radius.circular(30)),
                color: Colors.white,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        "Student Activity Report",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      StudentDetails.routeName,
                                      arguments: user);
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(20),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      color: Colors.white,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            offset: const Offset(0, 2),
                                            blurRadius: 6.0),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Image.asset("assets/icon/student.png",
                                            fit: BoxFit.fitHeight, height: 20),
                                        const SizedBox(width: 5.0),
                                        const Text(
                                          "Student Details",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 14.0),
                                        ),
                                      ],
                                    ))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        StudentWeeklyReport.routeName,
                                        arguments: user);
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(20),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Colors.white,
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.3),
                                              offset: const Offset(0, 2),
                                              blurRadius: 6.0),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Image.asset("assets/icon/medical.png",
                                              fit: BoxFit.fitHeight,
                                              height: 20),
                                          const SizedBox(width: 5.0),
                                          const Text(
                                            "Emergency No.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                        ],
                                      )))),
                        ]),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      Expanded(
                        child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  StudentMedicalReport.routeName,
                                  arguments: user);
                            },
                            child: Container(
                                padding: const EdgeInsets.all(20),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  color: Colors.white,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        offset: const Offset(0, 2),
                                        blurRadius: 6.0),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Image.asset("assets/icon/medical.png",
                                        fit: BoxFit.fitHeight, height: 20),
                                    const SizedBox(width: 5.0),
                                    const Text(
                                      "Medical Report",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 14.0),
                                    ),
                                  ],
                                ))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                    StudentCanteenReport.routeName,
                                    arguments: user);
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(20),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    color: Colors.white,
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          offset: const Offset(0, 2),
                                          blurRadius: 6.0),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Image.asset("assets/icon/pm_wallet.png",
                                          fit: BoxFit.fitHeight, height: 20),
                                      const SizedBox(width: 5.0),
                                      const Text(
                                        "Pocket Money",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 14.0),
                                      ),
                                    ],
                                  )))),
                    ]),
                    const SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      StudentFeesDetail.routeName,
                                      arguments: user);
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(20),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      color: Colors.white,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            offset: const Offset(0, 2),
                                            blurRadius: 6.0),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Image.asset("assets/icon/fee.png",
                                            fit: BoxFit.fitHeight, height: 20),
                                        const SizedBox(width: 5.0),
                                        const Text(
                                          "Fee Details",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 14.0),
                                        ),
                                      ],
                                    ))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        StudentWeeklyActivity.routeName,
                                        arguments: user);
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(20),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Colors.white,
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.3),
                                              offset: const Offset(0, 2),
                                              blurRadius: 6.0),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Image.asset("assets/icon/class.png",
                                              fit: BoxFit.fitHeight,
                                              height: 20),
                                          const SizedBox(width: 5.0),
                                          const Text(
                                            "Weekly Activity",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                        ],
                                      )))),
                        ]),
                    const SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      StudentFineCharges.routeName,
                                      arguments: user);
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(20),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      color: Colors.white,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            offset: const Offset(0, 2),
                                            blurRadius: 6.0),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Image.asset("assets/icon/fine_icon.png",
                                            fit: BoxFit.fitHeight, height: 20),
                                        const SizedBox(width: 5.0),
                                        const Text(
                                          "Fine Charges",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 14.0),
                                        ),
                                      ],
                                    ))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        StudentStudyReport.routeName,
                                        arguments: user);
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(20),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Colors.white,
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.3),
                                              offset: const Offset(0, 2),
                                              blurRadius: 6.0),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Image.asset("assets/icon/study.png",
                                              fit: BoxFit.fitHeight,
                                              height: 20),
                                          const SizedBox(width: 5.0),
                                          const Text(
                                            "Study Report",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                        ],
                                      )))),
                        ]),
                    const SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      StudentCallingReport.routeName,
                                      arguments: user);
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(20),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      color: Colors.white,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            offset: const Offset(0, 2),
                                            blurRadius: 6.0),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Image.asset("assets/icon/phone.png",
                                            fit: BoxFit.fitHeight, height: 20),
                                        const SizedBox(width: 5.0),
                                        const Text(
                                          "Calling Report",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 14.0),
                                        ),
                                      ],
                                    ))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        StudentFeedback.routeName,
                                        arguments: user);
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(20),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Colors.white,
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.3),
                                              offset: const Offset(0, 2),
                                              blurRadius: 6.0),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Image.asset(
                                              "assets/icon/cleaning.png",
                                              fit: BoxFit.fitHeight,
                                              height: 20),
                                          const SizedBox(width: 5.0),
                                          const Text(
                                            "Cleaning Report",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                        ],
                                      )))),
                        ]),
                    const SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      StudentReferences.routeName,
                                      arguments: user);
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(20),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      color: Colors.white,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            offset: const Offset(0, 2),
                                            blurRadius: 6.0),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Image.asset("assets/icon/reference.png",
                                            fit: BoxFit.fitHeight, height: 20),
                                        const SizedBox(width: 5.0),
                                        const Text(
                                          "Reference",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 14.0),
                                        ),
                                      ],
                                    ))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        StudentHostelHygiene.routeName,
                                        arguments: user);
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(20),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Colors.white,
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.3),
                                              offset: const Offset(0, 2),
                                              blurRadius: 6.0),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Image.asset(
                                              "assets/icon/hostel-icon.png",
                                              fit: BoxFit.fitHeight,
                                              height: 20),
                                          const SizedBox(width: 5.0),
                                          const Text(
                                            "Hostel Hygiene",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                        ],
                                      )))),
                        ]),
                    const SizedBox(height: 10),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LeadershipTrainingScreen()));
                                },
                                child: Container(
                                    padding: const EdgeInsets.only(
                                        top: 20, bottom: 20, left: 10),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      color: Colors.white,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            offset: const Offset(0, 2),
                                            blurRadius: 6.0),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Icon(Icons.play_arrow,
                                            color: Colors.red),
                                        Text(
                                          "Leadership Training",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 14.0),
                                        ),
                                      ],
                                    ))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const StudentResults()));
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(20),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Colors.white,
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.3),
                                              offset: const Offset(0, 2),
                                              blurRadius: 6.0),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(Icons.rocket,
                                              color: Colors.blue),
                                          Text(
                                            "Our Results",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                        ],
                                      )))),
                        ]),
                    const SizedBox(height: 10),
                  ]))
        ]),
      ),
    );
  }
}
