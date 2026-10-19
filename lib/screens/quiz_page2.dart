import 'package:flutter/material.dart';
import 'package:careerapp/models/category.dart';
import 'package:careerapp/models/question.dart';
import 'package:careerapp/screens/quiz_finished2.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:async';
import 'package:careerapp/services/api_services.dart';

class QuizPage2 extends StatefulWidget {
  final List<Question> questions;
  final Category? category;
  final dynamic time;
  const QuizPage2({Key? key, required this.questions, this.category, this.time})
      : super(key: key);

  @override
  _QuizPage2State createState() => _QuizPage2State();
}

class _QuizPage2State extends State<QuizPage2> {
  late Timer _timer;
  int _start = 60;
  int minutes = 0;

  int _currentIndex = 0;
  final Map<int, dynamic> _answers = {};
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            finalsubmit();
          });
        } else {
          setState(() {
            double t = _start / 60;
            minutes = t.round();
            _start--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      _start = widget.time;
      startTimer();
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  @override
  Widget build(BuildContext context) {
    Question question = widget.questions[_currentIndex];
    final List<dynamic> options = question.incorrectAnswers!;
    if (!options.contains(question.correctAnswer)) {
      options.add(question.correctAnswer);
      options.shuffle();
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text(removeAllHtmlTags(widget.category!.name)),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Text("Q. ${_currentIndex + 1} / Time Left: $minutes Minutes",
                    style: const TextStyle(color: Colors.black, fontSize: 20)),
                const SizedBox(height: 10.0),
                Html(data: widget.questions[_currentIndex].question, style: {
                  "html": Style(
                    color: Colors.black,
                    //              color: Colors.white,
                  ),
                }),
                widget.questions[_currentIndex].mediaLink != null
                    ? Image.network(
                        "${ApiService.weeklytest2}question-media/${widget.questions[_currentIndex].mediaLink!}",
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      }, width: 300.0, fit: BoxFit.fill)
                    : const Text(" "),
                widget.questions[_currentIndex].optionType == "Image"
                    ? Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ...options.map((option) => RadioListTile<dynamic>(
                                  title: Image.network(
                                      "${ApiService.weeklytest2}answer-media/" +
                                          option,
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
                                      height: 100.0,
                                      fit: BoxFit.contain),
                                  groupValue: _answers[_currentIndex],
                                  value: option,
                                  onChanged: (value) {
                                    setState(() {
                                      _answers[_currentIndex] = option;
                                    });
                                  },
                                )),
                          ],
                        ),
                      )
                    : Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ...options.map((option) => RadioListTile<dynamic>(
                                  title: Html(data: "$option", style: {
                                    "html": Style(
                                      color: Colors.black,
                                      //              color: Colors.white,
                                    ),
                                  }),
                                  groupValue: _answers[_currentIndex],
                                  value: option,
                                  onChanged: (value) {
                                    setState(() {
                                      _answers[_currentIndex] = option;
                                    });
                                  },
                                )),
                          ],
                        ),
                      ),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: MediaQuery.of(context).size.width > 800
                          ? const TextStyle(fontSize: 30.0)
                          : null,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: MediaQuery.of(context).size.width > 800
                          ? const EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 64.0)
                          : null,
                    ),
                    onPressed: _nextSubmit,
                    child: Text(
                      _currentIndex == (widget.questions.length - 1)
                          ? "Submit"
                          : "Next",
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _nextSubmit() {
    // if (_answers[_currentIndex] == null) {
    //   _key.currentState.showSnackBar(SnackBar(
    //     content: Text("You must select an answer to continue."),
    //   ));
    //   return;
    // }
    if (_currentIndex < (widget.questions.length - 1)) {
      setState(() {
        _currentIndex++;
      });
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => QuizFinishedPage2(
              questions: widget.questions, answers: _answers)));
    }
  }

  void finalsubmit() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) =>
            QuizFinishedPage2(questions: widget.questions, answers: _answers)));
  }

  Future<bool> _onWillPop() async {
    showAlert(context);
    return Future.value(true);
  }

  showAlert(Context) {
    showDialog<bool>(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: const Text(
                "Are you sure you want to quit the quiz? All your progress will be lost."),
            title: const Text("Warning!"),
            actions: <Widget>[
              TextButton(
                child: const Text("Yes"),
                onPressed: () {
                  Navigator.pop(context, true);
                  Navigator.pop(context, true);
                },
              ),
              TextButton(
                child: const Text("No"),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
            ],
          );
        });
  }
}
