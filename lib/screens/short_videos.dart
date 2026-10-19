import 'package:flutter/material.dart';
import 'package:careerapp/screens/live.dart';
import 'dart:convert';
import 'package:careerapp/services/api_services.dart';

class ShortVideo extends StatefulWidget {
  const ShortVideo({Key? key}) : super(key: key);

  @override
  _ShortVideoState createState() => _ShortVideoState();
}

class _ShortVideoState extends State<ShortVideo> {
  var data = [];
  final List<String> images = [];
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    var res = await ApiService.getMethod("/getShortVideos");
    data = jsonDecode(res.body);

    for (var element in data) {
      images.add("${ApiService.websiteUrl2}includes/upload/short_videos/" +
          element["image"]);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xffF8F8FA),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            images.isEmpty
                ? const Center(child: Text("Loading..."))
                : Container(
                    height: deviceSize.height - 100,
                    width: 300,
                    padding: const EdgeInsets.all(10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return _courseCard(data[index]);
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  _courseCard(dynamic data) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(LiveScreen.routeName, arguments: data["code"]);
      },
      child: Padding(
        padding:
            const EdgeInsets.only(left: 10.0, bottom: 10.0, right: 10, top: 10),
        child: Container(
          width: 230.0,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            color: Colors.blue[800],
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  offset: const Offset(0, 2),
                  blurRadius: 8.0),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15)),
                child: Image.network(
                    "${ApiService.websiteUrl2}includes/upload/short_videos/" +
                        data["image"],
                    width: double.infinity,
                    fit: BoxFit.fill),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                child: Text(
                  data["title"],
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }
}
