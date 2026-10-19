import 'package:flutter/material.dart';
import 'package:careerapp/widgets/webview_widget.dart';

class OpenUrl extends StatefulWidget {
  static const routeName = '/openurl';

  const OpenUrl({Key? key}) : super(key: key);

  @override
  _OpenUrlState createState() => _OpenUrlState();
}

class _OpenUrlState extends State<OpenUrl> {
  var data;
  var heading = "";

  var url = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic data3 = ModalRoute.of(context)!.settings.arguments;
    print(data3);
    heading = data3["school_name"];
    url = data3["url"];
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
      body: WebviewWidget(
        url: url,
      ),
    );
  }
}
