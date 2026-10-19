import 'package:flutter/material.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careerapp/screens/category.dart';
import 'dart:convert';

class MyCourses extends StatefulWidget {
  static const routeName = '/mycourses';

  const MyCourses({Key? key}) : super(key: key);

  @override
  _MyCoursesState createState() => _MyCoursesState();
}

class _MyCoursesState extends State<MyCourses> {
  var data2 = [];
  var data;
  var user_name = "";
  var user_id = "";
  var userData;
  var message = "Loading...";
  var class_for = "";

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)?.settings.arguments;
      getClassWiseCourse(data["class_for"]);
      class_for = data["class_for"];
    });
    // getUserData();
  }

  getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      userData = json.decode(prefs.getString('userData')!);
      user_name = userData["user_name"];
      user_id = userData["user_id"];
      class_for = userData["class_for"];
      getData();
      setState(() {});
    } else {
      setState(() {
        message = "No Course Found";
      });
    }
  }

  getData() async {
    var res2 =
        await ApiService.getMethod("/getPurchasedCourses?user_id=$user_id");
    data2 = jsonDecode(res2.body);

    setState(() {
      if (data2.isEmpty) message = "No Course Found";
    });
  }

  getClassWiseCourse(className) async {
    var res2 =
        await ApiService.getMethod("/getClassWiseCourse?class=$className");
    data2 = jsonDecode(res2.body);
    print(data2);
    setState(() {
      if (data2.isEmpty) message = "No Course Found";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8FA),
      appBar: AppBar(
        title: const Text("Recorded Classes"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: data2.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.all(2),
                      itemCount: data2.length,
                      itemBuilder: (BuildContext context, int i) {
                        return _courseCard(data2[i]);
                      },
                    )
                  : Center(
                      child: Text(
                        message,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _courseCard(dynamic param) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(Category.routeName, arguments: param);
      },
      child: Padding(
        padding:
            const EdgeInsets.only(left: 10.0, bottom: 10.0, right: 10, top: 10),
        child: Container(
          width: 230.0,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            color: Colors.blue,
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
                  child: Image.asset("assets/recorded-classes.jpeg")),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                child: Text(
                  "Class: $class_for",
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8, right: 8, top: 4),
                child: Text(
                  "Recorded Classes",
                  maxLines: 2,
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );

    // return GestureDetector(
    //   onTap: () {
    //     Navigator.of(context)
    //         .pushNamed(MycourseDetailsScreen.routeName, arguments: param);
    //   },
    //   child: Padding(
    //     padding: const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0),
    //     child: Container(
    //       decoration: BoxDecoration(
    //         borderRadius: const BorderRadius.all(Radius.circular(15.0)),
    //         color: Color(0xff2874a6),
    //         boxShadow: <BoxShadow>[
    //           BoxShadow(
    //               color: Colors.grey.withOpacity(0.5),
    //               offset: const Offset(0, 2),
    //               blurRadius: 8.0),
    //         ],
    //       ),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           ClipRRect(
    //           borderRadius: BorderRadius.only(topRight:  Radius.circular(15),topLeft:  Radius.circular(15)),
    //           child: Image.network(
    //               ApiService.websiteUrl +
    //                   "course-images/" +
    //                   param["feature_image"],

    //               fit: BoxFit.fill),
    //           ),
    //           Padding(
    //             padding: const EdgeInsets.only(left: 8, right: 8, top: 10),
    //             child: Text(
    //               param["course_title"],
    //               overflow: TextOverflow.ellipsis,
    //               maxLines: 3,
    //               style: TextStyle(
    //                   fontSize: 14,
    //                   color: Colors.white,
    //                   fontWeight: FontWeight.bold),
    //             ),
    //           ),
    //           SizedBox(height: 5),
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               Padding(
    //                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
    //                 child: Text("Author: Career Institute",
    //                     style: TextStyle(color: Colors.white)),
    //               ),

    //             ],
    //           ),
    //           SizedBox(height: 10),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
