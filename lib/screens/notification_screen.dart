import 'dart:async';

import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

class NotificationScreen extends StatefulWidget {
  static const routeName = '/notification';

  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  var data;
  var heading = "loading";
  var HtmlCode = "<h1>Loading</h1>";
  var url = "";
  late final WebViewController _controller;
  // var HtmlCode = '<h1> h1 Heading Tag</h1>' +
  //                 '<h2> h2 Heading Tag </h2>' +
  //                    '<p> Sample Paragraph Tag </p>' +
  //                    '<img src="https://flutter-examples.com/wp-content/uploads/2019/04/install_thumb.png" alt="Image" width="250" height="150" border="3">' ;

  final String image = "http://careerinstitute.co/app/ads/cds.jpg";
  @override
  void initState() {
    super.initState();
    url = Uri.dataFromString("<h1>loading</h1>", mimeType: 'text/html')
        .toString();
    Future.delayed(Duration.zero, () {
      var id = ModalRoute.of(context)!.settings.arguments;
      getData(id);
    });
  }

  getData(id) async {
    print(id);
    var res = await ApiService.getMethod("/getNotification?id=$id");
    data = jsonDecode(res.body);
    heading = data["heading"];
    HtmlCode = data["content"];
    url = Uri.dataFromString(HtmlCode, mimeType: 'text/html').toString();
    late final PlatformWebViewControllerCreationParams params;

    params = const PlatformWebViewControllerCreationParams();

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(url));
    // #enddocregion platform_features

    _controller = controller;
    print(HtmlCode);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
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
      body: Container(
        height: deviceSize.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/background.png"), fit: BoxFit.cover),
        ),
        child: WebViewWidget(
          controller: _controller,
        ),
      ),
    );
  }
}
