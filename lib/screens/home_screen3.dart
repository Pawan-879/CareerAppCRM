import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careerapp/screens/consultant_leads.dart';
import 'package:careerapp/screens/student_feedback.dart';
import 'package:careerapp/screens/student_results.dart';
import 'package:careerapp/screens/student_weekly_activity.dart';
import 'dart:convert';
import '../services/api_services.dart';

class Home3 extends StatefulWidget {
  const Home3({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _Home3State createState() => _Home3State();
}

class _Home3State extends State<Home3> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  var search = "";
  final _authData = {'id': '', 'status': '', 'remark': ''};

  final scrollController = ScrollController();
  var staff_id, parent_id;
  var page = 1;
  var name = "";
  var phone = "";
  var email = "";
  var area = "";
  var user;
  var counsellor_name = "";
  var counsellor_no = "";
  dynamic staffData;
  @override
  void initState() {
    super.initState();

    getUserData();
  }

  getUserData() async {
    page = 1;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('consulData') &&
        prefs.getString('consulData') != '') {
      staffData = json.decode(prefs.getString('consulData')!);
      user = json.decode(prefs.getString('consulData')!);
      if (staffData["id"] != '') {
        staff_id = staffData["id"];
        name = staffData["name"];
        phone = staffData["mobile"];
        email = staffData["email"];
        area = staffData["area"];
        parent_id = staffData["parent_id"];
        getStaffDetail(staffData["user_id"]);
      }

      setState(() {});
    }
  }

  getStaffDetail(id) async {
    var res = await ApiService.getMethod3("/getConsultantStaff?user_id=" + id);

    var d = jsonDecode(res.body)["data"];
    counsellor_name = d["name"];
    counsellor_no = d["mobile"];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xfff4f4f4),
      body: ListView(children: [
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
                        "Name: $name",
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Mobile No.: $phone",
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Email: $email",
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Area: $area",
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Counsellor Name: $counsellor_name",
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Counsellor No.: $counsellor_no",
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      const Text("Senior Counsellor: Neha Sood 9996600233")
                    ],
                  )),
            ),
          ],
        ),
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "Consultant Dashboard",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Expanded(
                    child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                              ConsultantLeads.routeName,
                              arguments: staffData);
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Image.asset("assets/icon/cleaning.png",
                                    fit: BoxFit.fitHeight, height: 20),
                                const SizedBox(width: 5.0),
                                const Text(
                                  "Leads",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14.0),
                                ),
                              ],
                            )))),
                const SizedBox(width: 10),
                Expanded(
                    child: GestureDetector(
                        onTap: () {},
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
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Icon(Icons.rocket, color: Colors.blue),
                                SizedBox(width: 5.0),
                                Text(
                                  "Revenue",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14.0),
                                ),
                              ],
                            )))),
              ]),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Expanded(
                  child: GestureDetector(
                      onTap: () {},
                      child: Container(
                          padding: const EdgeInsets.only(
                              top: 20, bottom: 20, left: 10),
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
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.play_arrow, color: Colors.red),
                              Text(
                                "Offers",
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Image.asset("assets/icon/cleaning.png",
                                    fit: BoxFit.fitHeight, height: 20),
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
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Expanded(
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const StudentResults()));
                      },
                      child: Container(
                          padding: const EdgeInsets.only(
                              top: 20, bottom: 20, left: 10),
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
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(Icons.rocket, color: Colors.blue),
                              Text(
                                "Our Results",
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Image.asset("assets/icon/class.png",
                                    fit: BoxFit.fitHeight, height: 20),
                                const SizedBox(width: 5.0),
                                const Text(
                                  "Weekly Activity",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14.0),
                                ),
                              ],
                            )))),
              ]),
            ]))
      ]),
    );
  }
}
