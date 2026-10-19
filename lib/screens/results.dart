import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';

class Results extends StatefulWidget {
  static const routeName = '/Results';

  const Results({Key? key}) : super(key: key);

  @override
  _ResultsState createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  var data6 = [];
  var heading = "Results";

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      var id = ModalRoute.of(context)!.settings.arguments;
      getData(id);
    });
  }

  getData(id) async {
    var res = await ApiService.getMethod2("/getResults?user_id=" + id);
    data6 = jsonDecode(res.body);
    print(data6);
    setState(() {});
  }

  results() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            heading,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500),
          ),
           backgroundColor: Colors.blue[500], 
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 15, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Column(children: [
        Container(
          color: Colors.white,
          child: const Padding(
            padding: EdgeInsets.only(bottom: 0),
            child: ListTile(
                leading: Text("#",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    )),
                title: Text("Exam Title",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green)),
                trailing: Text("Correct/Total Ques",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green))),
          ),
        ),
        Expanded(
            child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: data6.length,
          itemBuilder: (context, index) {
            return _courseCard3((index + 1).toString(),
                data6[index]["title_name"], data6[index]);
          },
        )),
      ]),
    );
  }

  _courseCard3(String id, String titleName, dynamic row) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        child: ListTile(
            leading: Text(id,
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                )),
            title: Html(data: "Sub: ${removeAllHtmlTags(titleName)}", style: {
              "html": Style(
                  color: Colors.black,
                  fontSize: FontSize.large,
                  fontWeight: FontWeight.bold),
            }),
            subtitle:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("  Course: ${removeAllHtmlTags(row["course_title"])}"),
              Text("  Date: ${removeAllHtmlTags(row["date"])}"),
              Text("  Score: ${removeAllHtmlTags(row["score"])}%")
            ]),
            trailing:
                Text(row["correct_answers"] + "/" + row["total_questions"])),
      ),
    );
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }
}
