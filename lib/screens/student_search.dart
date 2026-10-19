import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard.dart';
import 'openurl.dart';

class StudentSearch extends StatefulWidget {
  static const routeName = '/StudentSearch';

  const StudentSearch({Key? key}) : super(key: key);

  @override
  _StudentSearchState createState() => _StudentSearchState();
}

class _StudentSearchState extends State<StudentSearch> {
  dynamic data = [];
  var heading = "Student Search";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context)!.settings.arguments;
    print(data);
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
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xfffdddddd)),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: data.length,
          itemBuilder: (context, index) {
            return _listshowstudent(context, data[index]);
          },
        ),
      ),
    );
  }

  _listshowstudent(BuildContext context, dynamic row) {
    return GestureDetector(
     onTap: () async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String> storedStudents = prefs.getStringList('saved_students') ?? [];

  // Convert current selected row to JSON string
  String newStudent = jsonEncode(row);

  // Prevent duplicates
  if (!storedStudents.contains(newStudent)) {
    storedStudents.add(newStudent);
    await prefs.setStringList('saved_students', storedStudents);
  }

  // Navigate to Dashboard
  dynamic data = {"id": row["id"]};
  Navigator.of(context).pushNamed(Dashboard.routeName, arguments: data);
},

      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            color: Colors.white.withOpacity(0.3),
          ),
          child: Row(
            children: [
              const SizedBox(height: 10),
              Expanded(
                flex: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              width: 250,
                              child: Text(
                                row["first_name"].toString() +
                                    ' ' +
                                    row["last_name"].toString() +
                                    " (" +
                                    row["class_for"].toString() +
                                    ")",
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black),
                              )),
                          const SizedBox(height: 5),
                          Text("Father: ${row["father_name"]} (${row["mobile"]})"),
                          const SizedBox(height: 5),
                          Text(
                            getBranch(row),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(FontAwesomeIcons.angleRight, color: Colors.red.shade300)
            ],
          ),
        ),
        const SizedBox(height: 3),
      ]),
    );
  }

  getBranch(row) {
    if (row["school_id"] == 1 || row["school_id"] == "1") {
      return "Branch: Ambala";
    } else if (row["school_id"] == 2 || row["school_id"] == "2") {
      return "Branch: Patiala";
    } else if (row["school_id"] == 3 || row["school_id"] == "3") {
      return "Branch: Yamunanagar";
    } else {
      return "Branch: BADDI";
    }
  }
}
