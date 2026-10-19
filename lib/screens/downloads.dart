import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class Downloads extends StatefulWidget {
  static const routeName = '/Downloads';

  const Downloads({Key? key}) : super(key: key);

  @override
  _DownloadsState createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  var userData;
  String url = "";
  String topicname = "Downloads";
  List<dynamic> data = [];
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      // dynamic filter = ModalRoute.of(context).settings.arguments;

      getDownloadss();
    });
  }

  getDownloadss() async {
    try {
      var res = await ApiService.getMethod("/getDownloads");
      final decoded = json.decode(res.body);
      data = decoded is List ? decoded : [];

      debugPrint(data.toString());
    } catch (err) {
      debugPrint(err.toString());
    }

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            topicname,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500),
          ),
         backgroundColor: Colors.blue[500],

          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 15, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index] is Map ? data[index] : <String, dynamic>{};
            return VideoTile((index + 1).toString(),
                item["topic_name"]?.toString() ?? "Download", item, 1, "downloads");
          },
        ));
  }

  Widget VideoTile(number, title, detail, flag, folderName) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.all(5.0),
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(number + ".", style: const TextStyle(fontSize: 20)),
              SizedBox(
                width: 230.0,
                child: Text(title,
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color(0xFF0D1333).withOpacity(1),
                      fontWeight: FontWeight.bold,
                    )),
              ),

              /* <----------- Counter ------------> */
              Row(
                children: [
                  GestureDetector(
                      onTap: () async {
                        final downloadUrl = detail["download_url"]?.toString() ?? '';
                        if (downloadUrl.isEmpty) return;
                        var path2 = "${ApiService.websiteUrl}downloads/$downloadUrl";

                        final uri = Uri.tryParse(path2);
                        if (uri != null) {
                          launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                        // final status = await Permission.storage.request();

                        // if (status.isGranted) {
                        //   final externalDir =
                        //       await getExternalStorageDirectory();

                        //   await FlutterDownloader.enqueue(
                        //     url: path2,
                        //     savedDir: externalDir!.path,
                        //     fileName: detail["download_url"],
                        //     showNotification: true,
                        //     openFileFromNotification: true,
                        //   );
                        // } else {
                        //   debugPrint("Permission deined");
                        // }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20.0)),
                          gradient: LinearGradient(
                            colors: <Color>[Colors.blue[200]!, Colors.blue],
                          ),
                        ),
                        child: const Icon(Icons.archive, color: Colors.white),
                      )),
                  const SizedBox(width: 10)
                ],
              ),
              /* <----------- End of Counter ------------> */
            ],
          ),
        ));
  }
}
