import 'package:flutter/material.dart';

import '../widgets/webview_widget.dart';

class FillformScreen extends StatefulWidget {
  static const routeName = '/fillform';

  const FillformScreen({Key? key}) : super(key: key);

  @override
  _FillformScreenState createState() => _FillformScreenState();
}

class _FillformScreenState extends State<FillformScreen> {
  var data;
  var heading = "Fill Online Form";

  var url = "https://www.careerdefenceschool.com/form/home/appview";

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
      ),
      body: WebviewWidget(
        url: url,
      ),
    );
  }
}
