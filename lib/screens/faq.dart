import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
// import 'package:careerapp/screens/pdf_viewer.dart';

class FAQPage extends StatefulWidget {
  static const routeName = '/FAQPage';

  const FAQPage({Key? key}) : super(key: key);

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  var userData;
  String url = "";
  String topicname = "Important Exam FAQ’s";
  var data = [];
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      // dynamic filter = ModalRoute.of(context).settings.arguments;

      getDownloadss();
      setState(() {});
    });
  }

  getDownloadss() async {
    try {
      var res = await ApiService.getMethod("/getFAQPage");
      data = json.decode(res.body);

      print(data);
    } catch (err) {
      print(err);
    }

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
        body: Container(
            child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: data.length,
          itemBuilder: (context, index) {
            return VideoTile((index + 1).toString(), data[index]["topic_name"],
                data[index], 1, data[index]);
          },
        )));
  }

  Widget VideoTile(number, title, detail, flag, doc) {
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
                        dynamic data5 = {
                          'course_id': '',
                          'link': doc['download_url'],
                          'path': "faq",
                          'filename': doc['topic_name'],
                        };
                        // Navigator.of(context)
                        //     .pushNamed(PDFViewer.routeName, arguments: data5);
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
                        child: const Icon(Icons.picture_as_pdf,
                            color: Colors.white),
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
