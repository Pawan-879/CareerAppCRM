import 'package:flutter/material.dart';

import '../widgets/webview_widget.dart';

class Canteen extends StatefulWidget {
  static const routeName = '/canteen';

  const Canteen({Key? key}) : super(key: key);

  @override
  _CanteenState createState() => _CanteenState();
}

class _CanteenState extends State<Canteen> {
  var heading = "Canteen";

  var url = "https://www.careerinstitute.co/canteen/";

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
      ),
      body: WebviewWidget(
        url: url,
      ),
    );
  }
}
