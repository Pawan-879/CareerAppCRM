import 'dart:io';
import 'package:flutter/material.dart';
import 'package:careerapp/models/category.dart';
import 'package:careerapp/models/question.dart';
import 'package:careerapp/screens/error.dart';
import 'package:careerapp/screens/quiz_page2.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class QuizOptionsDialog2 extends StatefulWidget {
  final Category? category;

  const QuizOptionsDialog2({Key? key, this.category}) : super(key: key);

  @override
  _QuizOptionsDialog2State createState() => _QuizOptionsDialog2State();
}

class _QuizOptionsDialog2State extends State<QuizOptionsDialog2> {
  late int _noOfQuestions;
  late String _difficulty;
  late bool processing;
  var time;
  final String baseUrl = "${ApiService.weeklytest}/getMcqs";
  Future<List<Question>> getQuestions(
      Category category, int total, String? difficulty) async {
    String url = "$baseUrl?amount=$total&exam_id=${category.id}";
    if (difficulty != null) {
      url = "$url&difficulty=$difficulty";
    }
    http.Response res = await http.get(Uri.parse(url));
    List<Map<String, dynamic>> questions =
        List<Map<String, dynamic>>.from(json.decode(res.body)["results"]);
    time = json.decode(res.body)["duration"];

    return Question.fromData(questions);
  }

  @override
  void initState() {
    super.initState();
    _noOfQuestions = 10;
    _difficulty = "easy";
    processing = false;
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade200,
            child: Text(
              removeAllHtmlTags(widget.category!.name),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(),
            ),
          ),
          const SizedBox(height: 10.0),
          processing
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _startQuiz,
                  child: const Text("Start Quiz"),
                ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  void _startQuiz() async {
    setState(() {
      processing = true;
    });
    try {
      List<Question> questions =
          await getQuestions(widget.category!, _noOfQuestions, _difficulty);
      Navigator.pop(context);
      if (questions.isEmpty) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const ErrorPage(
                  message:
                      "There are not enough questions in the category, with the options you selected.",
                )));
        return;
      }
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => QuizPage2(
                  questions: questions,
                  category: widget.category,
                  time: time)));
    } on SocketException catch (_) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const ErrorPage(
                    message:
                        "Can't reach the servers, \n Please check your internet connection.",
                  )));
    } catch (e) {
      print(e);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const ErrorPage(
                    message: "Unexpected error trying to connect to the API",
                  )));
    }
    setState(() {
      processing = false;
    });
  }
}
