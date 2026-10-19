import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:careerapp/screens/mcq_list.dart';
import 'package:careerapp/screens/results.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Weeklytest extends StatefulWidget {
  static const routeName = '/weeklytest';

  const Weeklytest({Key? key}) : super(key: key);

  @override
  _WeeklytestState createState() => _WeeklytestState();
}

class _WeeklytestState extends State<Weeklytest> {
  var data6 = [];
  var heading = "Weekly Test";
  var userData;
  var user_id;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    var res = await ApiService.getMethod2("/getWeeklyTest");
    data6 = jsonDecode(res.body);
    print(data6);
    setState(() {});
  }

  results() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      userData = json.decode(prefs.getString('userData')!);
      user_id = userData["user_id"];
      Navigator.of(context).pushNamed(Results.routeName, arguments: user_id);
      setState(() {});
    }
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
        actions: [
          Container(
              margin: const EdgeInsets.only(right: 10),
              child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: [
                      SizedBox(
                          height: 35,
                          child: IconButton(
                            icon: const Icon(Icons.wysiwyg_outlined),
                            onPressed: results,
                          )),
                      const Text(
                        "Results",
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  )))
        ],
      ),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          color: Colors.white,
          child: const Text("* Weekly Exciting Prices For Top Performers *",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.w600)),
        ),
        Container(
          color: Colors.white,
          child: const Padding(
            padding: EdgeInsets.only(bottom: 0),
            child: ListTile(
                leading: Text("#",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    )),
                title: Text("Course Name",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
                trailing: Text("Exam Date",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey))),
          ),
        ),
        Expanded(
            child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: data6.length,
          itemBuilder: (context, index) {
            return _courseCard3(
                (index + 1).toString(),
                data6[index]["course_id"],
                data6[index]["course_title"],
                data6[index]);
          },
        )),
        const Text("Notice: Results only saved for loggedin users.",
            style: TextStyle(color: Colors.red)),
      ]),
    );
  }

  _courseCard3(String id, String courseId, String title, dynamic row) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.blue[100]!.withOpacity(0.2),
        margin: const EdgeInsets.only(bottom: 2),
        child: ListTile(
          leading: Text(id,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              )),
          title: Html(data: removeAllHtmlTags(title), style: {
            "html": Style(
                color: Colors.black,
                fontSize: FontSize.large,
                fontWeight: FontWeight.bold),
          }),
          trailing: row["app_date"] != null
              ? SizedBox(
                  width: 88,
                  child: Text(row["app_date"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red)))
              : TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.teal[400],
                    textStyle:
                        const TextStyle(fontSize: 14, color: Colors.white),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(McqList.routeName, arguments: courseId);
                  },
                  child: const Text(
                    'Start',
                  ),
                ),
        ),
      ),
    );
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }
}
