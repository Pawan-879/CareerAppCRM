import 'dart:convert';

import 'package:careerapp/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class StaffSalary extends StatefulWidget {
  static const routeName = '/StaffSalary';

  const StaffSalary({Key? key}) : super(key: key);

  @override
  State<StaffSalary> createState() => _StaffSalaryState();
}

class _StaffSalaryState extends State<StaffSalary> {
  var data = [];
  late bool loading = false;

  @override
  void initState() {
    super.initState();

    getUserData();
  }

  getUserData() async {
    data = [];

    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('staffData') && prefs.getString('staffData') != '') {
      var staffData = json.decode(prefs.getString('staffData')!);

      if (staffData["user_id"] != '') {
        getSalaries(staffData["user_id"]);
      }
    }
  }

  getSalaries(staffId) async {
    loading = true;
    data = [];
    // var res = await ApiService.getMethod3("/getWeeklyCopyStamping");

    var res = await ApiService.getMethod3(
        "/getSalaries?user_id=$staffId");
    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      data = d["data"];
      print(data);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            "Staff Salary",
            textAlign: TextAlign.left,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 15,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: const [],
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.isNotEmpty)
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return _getStudentCard(data[index]);
                    },
                  ),
                )),
              if (data.isEmpty)
                const Center(
                  child: Text("Record not found."),
                )
            ]));
  }

  Widget _getStudentCard(student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade300,
              offset: const Offset(0, 0),
              spreadRadius: 1,
            ),
          ]),
      child: Column(children: [
        Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.blue.shade300,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5), topRight: Radius.circular(5))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Invoice: ${student["id"]}'.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ],
            )),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Salary',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Paid: ₹${student["amount"]}'.toUpperCase(),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${student["date"]}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        'Mode: Bank',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ]),
    );
  }
}
