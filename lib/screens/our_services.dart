import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:careerapp/screens/mcq_list.dart';
import 'package:careerapp/screens/openurl.dart';

class OurServices extends StatefulWidget {
  static const routeName = '/OurServices';

  const OurServices({Key? key}) : super(key: key);

  @override
  _OurServicesState createState() => _OurServicesState();
}

class _OurServicesState extends State<OurServices> {
  var data6 = [];
  var heading = "Our Services";
  var userData;
  var user_id;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    var res = await ApiService.getMethod("/getServices");
    data6 = jsonDecode(res.body);
    print(data6);
    setState(() {});
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
          icon: const Icon(Icons.arrow_back_ios, size: 15, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: const [],
      ),
      body: Column(children: [
        Expanded(
            child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: data6.length,
          itemBuilder: (context, index) {
            return _courseCard3((index + 1).toString(), data6[index]["id"],
                data6[index]["school_name"], data6[index]);
          },
        )),
      ]),
    );
  }

  _courseCard3(String id, String courseId, String title, dynamic row) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(OpenUrl.routeName, arguments: row);
      },
      child: Container(
        color: Colors.blue[100]!.withOpacity(0.2),
        margin: const EdgeInsets.only(bottom: 2),
        child: ListTile(
          leading: Text(id,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              )),
          title: Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          trailing: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 14, color: Colors.black),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
            ),
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(McqList.routeName, arguments: courseId);
            },
            child: const Icon(FontAwesomeIcons.angleRight,
                size: 20, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
