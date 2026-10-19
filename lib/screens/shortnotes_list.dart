import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:careerapp/screens/pdf_viewer.dart';

class ShortnotesList extends StatefulWidget {
  const ShortnotesList({Key? key}) : super(key: key);
  static const routeName = '/ShortnotesList';
  @override
  _ShortnotesListState createState() => _ShortnotesListState();
}

class _ShortnotesListState extends State<ShortnotesList> {
  var data = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      var id = ModalRoute.of(context)!.settings.arguments;
      print(id);
      getData(id);
    });
  }

  getData(id) async {
    var res = await ApiService.getMethod("/getCourseShortnotes?courseId=$id");
    data = jsonDecode(res.body);
    print(data);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Short Notes'),
          elevation: 0,
        ),
        body: Container(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: data.length,
            itemBuilder: (context, index) {
              return _listLoadShortNotes(
                  context,
                  int.parse(data[index]["doc_id"]),
                  data[index]["doc_title"],
                  data[index]);
            },
          ),
        ));
  }

  _listLoadShortNotes(BuildContext context, int id, String title, dynamic doc) {
    return GestureDetector(
      onTap: () {
        dynamic data5 = {
          'course_id': doc["course_id"],
          'link': doc['doc_link'],
          'path': "course_docs",
          'filename': doc['doc_title'],
        };
        // Navigator.of(context).pushNamed(PDFViewer.routeName, arguments: data5);
      },
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            color: Colors.white,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  offset: const Offset(0, 2),
                  blurRadius: 8.0),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(height: 10),
              Expanded(
                flex: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset('assets/pdffile.png', width: 60, height: 60),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 250,
                            child: Text(
                              title,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              maxLines: 2,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(FontAwesomeIcons.angleRight)
            ],
          ),
        ),
        const SizedBox(height: 10),
      ]),
    );
  }
}
