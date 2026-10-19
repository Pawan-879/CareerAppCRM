
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Schoolfee extends StatefulWidget {
  static const routeName = '/weeklytest';

  const Schoolfee({Key? key}) : super(key: key);

  @override
  _SchoolfeeState createState() => _SchoolfeeState();
}

class _SchoolfeeState extends State<Schoolfee> {
  late final WebViewController _controller;
  var data;
  var heading = "Pay School/Other Fee";

  var url = "https://www.careerdefenceschool.com/schoolfees.php";

  @override
  void initState() {
    super.initState(); // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    params = const PlatformWebViewControllerCreationParams();

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    // #enddocregion platform_featuresfinal WebViewController controller
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(url));
    _controller = controller;
  }

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
          ),
        ),
        body: WebViewWidget(controller: _controller));
  }
}
