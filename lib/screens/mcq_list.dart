import 'package:flutter/material.dart';
import 'package:careerapp/models/category.dart';
import 'package:careerapp/widgets/quiz_options2.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class McqList extends StatefulWidget {
  const McqList({Key? key}) : super(key: key);
  static const routeName = '/McqList';
  @override
  _McqListState createState() => _McqListState();
}

class _McqListState extends State<McqList> {
  var data = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      var id = ModalRoute.of(context)!.settings.arguments;
      print(id);
      getData(id);
    });
  }

  getData(id) async {
    var res = await ApiService.getMethod2("/getCourseMcq?courseId=$id");
    data = jsonDecode(res.body);
    print(data);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('MCQ Test'),
          elevation: 0,
        ),
        body: Container(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: data.length,
            itemBuilder: (context, index) {
              return _listLoad(
                  context,
                  int.parse(data[index]["title_id"]),
                  data[index]["title_name"],
                  data[index]["syllabus"],
                  data[index]["time_duration"],
                  data[index]["pass_mark"],
                  data[index]["random_ques_no"]);
            },
          ),
        ));
  }

  _categoryPressed(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => BottomSheet(
        builder: (_) => QuizOptionsDialog2(
          category: category,
        ),
        onClosing: () {},
      ),
    );
  }

  _listLoad(BuildContext context, int id, String title, String syllabus,
      String timeDuration, String passMark, String? randomQuesNo) {
    return GestureDetector(
      onTap: () {
        _categoryPressed(
            context, Category(id, title, icon: FontAwesomeIcons.earthAsia));
      },
      child: Column(children: [
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
          padding: const EdgeInsets.fromLTRB(18, 10, 10, 10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  offset: Offset(0.5, 0.5),
                  blurRadius: 2,
                ),
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 4.0),
                child: Text(
                  removeAllHtmlTags(title),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                height: 1,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    color: Colors.red,
                    width: 4,
                    height: 50,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          removeAllHtmlTags(syllabus),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Passing Marks: $passMark%",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 5),
                  Text(
                    (randomQuesNo ?? '0'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.timer),
                  const SizedBox(width: 5),
                  Text(
                    timeDuration,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }
}
