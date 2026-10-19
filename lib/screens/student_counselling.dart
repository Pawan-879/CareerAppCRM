import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';

class StudentCounselling extends StatefulWidget {
  static const routeName = '/StudentCounsellings';

  const StudentCounselling({Key? key}) : super(key: key);

  @override
  _StudentCounsellingState createState() => _StudentCounsellingState();
}

class _StudentCounsellingState extends State<StudentCounselling> {
  var data6 = [];
  var heading = "Student Counselling";
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
        await ApiService.getMethod3("/getCounselling?user_id=" + data["id"]);
    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      data6 = d["data"];
    }
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
      body: SafeArea(
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
                headingRowColor: WidgetStateProperty.resolveWith(
                    (states) => Colors.grey.shade300),
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Topic')),
                  DataColumn(label: Text('Message')),
                  DataColumn(label: Text('Duration')),
                  DataColumn(label: Text('Proof')),
                  DataColumn(label: Text('Staff Reply')),
                  DataColumn(label: Text('Incharge')),
                  DataColumn(label: Text('Duration')),
                ],
                rows:
                    data6 // Loops through dataColumnText, each iteration assigning the value to element
                        .map(
                          ((element) => DataRow(
                                cells: <DataCell>[
                                  DataCell(Text(
                                      (data6.indexOf(element) + 1).toString())),
                                  DataCell(Text(element["date"])),
                                  DataCell(Text(element[
                                      "topic"])), //Extracting from Map element the value

                                  DataCell(Text(element["message"])),
                                  DataCell(Text(element["duration"])),

                                  DataCell(Image.network(
                                      "${ApiService.careerdefenceacademy2}includes/uploads/stu_counseling_proof/thimg/" +
                                          element["proof"],
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                      width: 100.0,
                                      height: 70.0,
                                      fit: BoxFit.fill)),
                                  DataCell(Text(element["staff_reply"])),
                                  DataCell(Text(element["incharge"])),

                                  DataCell(Text(element["duration"])),
                                ],
                              )),
                        )
                        .toList(),
              ))),
    );
  }
}
