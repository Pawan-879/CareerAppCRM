
import 'package:flutter/material.dart';

import '../widgets/webview_widget.dart';

class Feedbackform extends StatefulWidget {
  static const routeName = '/Feedbackform';

  const Feedbackform({Key? key}) : super(key: key);

  @override
  _FeedbackformState createState() => _FeedbackformState();
}

class _FeedbackformState extends State<Feedbackform> {
  var data;
  var heading = "Feedback Form";

  var url = "https://www.careerdefenceschool.com/feedback/";

  @override
  void initState() {
    super.initState();
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
          icon: const Icon(Icons.arrow_back_ios, size: 15 , color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: WebviewWidget(
        url: url,
      ),
    );
  }
}
