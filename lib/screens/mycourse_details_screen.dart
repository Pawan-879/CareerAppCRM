import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:careerapp/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careerapp/models/category.dart';
import 'package:careerapp/widgets/quiz_options.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:careerapp/screens/pdf_viewer.dart';
import 'package:careerapp/screens/freerecordedplayer.dart';
import 'package:careerapp/screens/freerecordedplayer2.dart';
import 'package:careerapp/screens/freesolvedplayer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

//import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class MycourseDetailsScreen extends StatefulWidget {
  static const routeName = '/my-course-detail';

  const MycourseDetailsScreen({super.key});

  @override
  _MycourseDetailsScreenState createState() => _MycourseDetailsScreenState();
}

class _MycourseDetailsScreenState extends State<MycourseDetailsScreen>
    with SingleTickerProviderStateMixin {
  String course_title = "Loading...";
  String course_price = "0.0";
  String course_id = "", category_id = "";
  var user_id = "";
  var user_name = "";
  var user_email = "";
  var user_phone = "";
  var featured_image = "placeholder.png";
  var userData;
  var player_type;
  dynamic course;
  var data = [];
  var data2 = [];
  var data3 = [];
  var data4 = [];
  var data6 = [];
  var data7 = [];

  late TabController _tabController;

  var syllabus = "", notification = "", exampattern = "", seats = "", faq = "";
  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 7);

    _tabController.addListener(_handleTabSelection);

    Future.delayed(Duration.zero, () {
      course = ModalRoute.of(context)?.settings.arguments;
      print(course);
      course_title = course["course_title"];
      course_price = course["course_india_price"];
      featured_image = course["feature_image"];
      course_id = course["course_id"];
      category_id = course["category_id"];
      player_type = course["player_type"];
      getData(course["course_id"]);
    });
    setState(() {});
    getUserData();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          break;
        case 1:
          getData3(course_id);
          break;
        case 2:
          getData4(course_id, category_id);
          break;
        case 3:
          getData7(course_id, 'paid');
          break;
        case 4:
          getData2(course_id);
          break;
        case 5:
          getData6(course_id);
          break;
        case 6:
          getData5(category_id);
          break;
      }
    }
  }

  getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      userData = json.decode(prefs.getString('userData')!);
      user_id = userData["user_id"];
      user_name = userData["user_name"];
      user_email = userData["user_email"];
      user_phone = userData["user_phone"];
      setState(() {});
    }
  }

  getData7(id, type) async {
    var res = await ApiService.getMethod(
        "/getFreeSolvedVideos?course_id=$id&type=$type");

    data7 = jsonDecode(res.body);

    setState(() {});
  }

  getData(id) async {
    var res = await ApiService.getMethod("/getSingleCourse?course_id=$id");
    data = jsonDecode(res.body);
    setState(() {});
  }

  getData2(id) async {
    var res = await ApiService.getMethod("/getCourseMcq?courseId=$id");
    data2 = jsonDecode(res.body);

    setState(() {});
  }

  getData3(id) async {
    var res = await ApiService.getMethod("/getCourseShortnotes?courseId=$id");
    data3 = jsonDecode(res.body);

    setState(() {});
  }

  getData4(id, categoryId) async {
    var res = await ApiService.getMethod(
        "/getCourseSamplepapers?courseId=$id&category_id=$categoryId");
    data4 = jsonDecode(res.body);
    print(data);
    setState(() {});
  }

  getData5(id) async {
    var res =
        await ApiService.getMethod("/getSyllabusExamPattern?category_id=$id");
    dynamic data5 = jsonDecode(res.body);
    syllabus = data5["syllabus"];
    notification = data5["notification"];
    exampattern = data5["exampattern"];
    seats = data5["seats"];
    faq = data5["faq"];
    print(data5);
    setState(() {});
  }

  getData6(id) async {
    var res = await ApiService.getMethod(
        "/getCourseAssignments?course_id=$id&type=paid");
    data6 = jsonDecode(res.body);
    setState(() {});
  }

  openSolvedSamplePaper() {
    dynamic data66 = {'course_id': course_id, 'type': 'paid'};
    Navigator.of(context)
        .pushNamed(FreeSolvedScreen.routeName, arguments: data66);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              course_title,
              style: const TextStyle(fontSize: 18.0),
            ),
            bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50.0),
                child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    unselectedLabelColor: Colors.white.withOpacity(0.3),
                    indicatorColor: Colors.white,
                    tabs: const [
                      Tab(
                        child: Text('Recorded Videos',
                            style: TextStyle(fontSize: 18.0)),
                      ),
                      Tab(
                        child: Text('Short Notes',
                            style: TextStyle(fontSize: 18.0)),
                      ),
                      Tab(
                        child: Text('Sample Papers',
                            style: TextStyle(fontSize: 18.0)),
                      ),
                      Tab(
                        child: Text('Solved Sample Paper Videos',
                            style: TextStyle(fontSize: 18.0)),
                      ),

                      Tab(
                        child:
                            Text('MCQ Test', style: TextStyle(fontSize: 18.0)),
                      ),
                      // Tab(
                      //   child: Text('Short Trick Videos',
                      //       style: TextStyle(fontSize: 18.0)),
                      // ),
                      Tab(
                        child: Text('Assignments',
                            style: TextStyle(fontSize: 18.0)),
                      ),
                      Tab(
                        child: Text('Exam Details',
                            style: TextStyle(fontSize: 18.0)),
                      ),
                    ])),
            // actions: <Widget>[
            //   Padding(
            //     padding: const EdgeInsets.only(left: 16.0),
            //     child: Icon(Icons.add_alert),
            //   ),
            // ],
          ),
          body: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              _loadRecordVideos(context),
              _loadShortNotes(context),
              _loadSamplePapers(context),
              _loadSolvedSamplePaper(context),
              _loadMCQ(context),
              // _loadShortTrickVideos(context),
              _loadAssignment(context),
              _loadExamDetails(context)
            ],
          )),
    );
  }

  _loadSolvedSamplePaper(context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: data7.length,
        itemBuilder: (context, index) {
          return _courseCard7(index, (index + 1).toString(), data7[index]["id"],
              data7[index]["item_name"]);
        },
      ),
    );
  }

  _courseCard7(
    int index,
    String id,
    String sectionId,
    String title,
  ) {
    return GestureDetector(
      onTap: () {
        openSolvedSamplePaper();
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Container(
          color: Colors.green[50],
          child: ListTile(
            leading: Text(id,
                style: TextStyle(
                  fontSize: 32,
                  color: const Color(0xFF0D1333).withOpacity(0.15),
                  fontWeight: FontWeight.bold,
                )),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF0D1333),
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Container(
              height: 30,
              width: 30,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.blue),
              child: const Icon(Icons.movie, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  _loadRecordVideos(context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _courseCard((index + 1).toString(), data[index]["section_id"],
              data[index]["section_title"]);
        },
      ),
    );
  }

  _courseCard(
    String id,
    String sectionId,
    String title,
  ) {
    return GestureDetector(
      onTap: () {
        dynamic data88 = {'section_id': sectionId, 'type': 'paid'};
        print(player_type);
        if (int.parse(player_type) == 0) {
          Navigator.of(context)
              .pushNamed(FreeRecordedScreen.routeName, arguments: data88);
        } else {
          Navigator.of(context)
              .pushNamed(FreeRecordedScreen2.routeName, arguments: data88);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Container(
          color: Colors.green[50],
          child: ListTile(
            leading: Text(id,
                style: TextStyle(
                  fontSize: 32,
                  color: const Color(0xFF0D1333).withOpacity(0.15),
                  fontWeight: FontWeight.bold,
                )),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF0D1333),
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Container(
              height: 30,
              width: 30,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.blue),
              child: const Icon(Icons.movie, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  _loadAssignment(context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: data6.length,
        itemBuilder: (context, index) {
          return _courseCard3((index + 1).toString(), data6[index]["id"],
              data6[index]["item_name"], data6[index]);
        },
      ),
    );
  }

  _courseCard3(String id, String sectionId, String title, dynamic row) {
    return Column(children: [
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
            const SizedBox(height: 1),
            Expanded(
              flex: 6,
              child: GestureDetector(
                onTap: () {
                  dynamic data51 = {
                    'course_id': '',
                    'link': row["item_link"],
                    'path': "course-assignments",
                    'filename': row["item_name"],
                  };
                  //print(data51);
                  // Navigator.of(context)
                  //     .pushNamed(PDFViewer.routeName, arguments: data51);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset('assets/pdffile.png', width: 30, height: 30),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 250,
                            child: Text(
                              title,
                              style: const TextStyle(fontSize: 18),
                              maxLines: 2,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
                onTap: () async {
                  var path2 = "${ApiService.websiteUrl}course-assignments/" +
                      row["item_link"];
                  final status = await Permission.storage.request();

                  if (status.isGranted) {
                    final externalDir = await getExternalStorageDirectory();

                    // await FlutterDownloader.enqueue(
                    //   url: path2,
                    //   savedDir: externalDir!.path,
                    //   fileName: row["item_name"],
                    //   showNotification: true,
                    //   openFileFromNotification: true,
                    // );
                  } else {
                    print("Permission deined");
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    gradient: LinearGradient(
                      colors: <Color>[Colors.red[200]!, Colors.red],
                    ),
                  ),
                  child: const Icon(Icons.archive, color: Colors.white),
                ))
          ],
        ),
      ),
      const SizedBox(height: 1),
    ]);
  }

  _loadExamDetails(context) {
    return Container(
      child: Card(
        elevation: 4.0,
        margin: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 10.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.book,
                color: Colors.grey[800],
              ),
              title: const Text("Syllabus"),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                dynamic data5 = {
                  'course_id': '',
                  'link': syllabus,
                  'path': "syllabus",
                  'filename': "Syllabus",
                };
                // Navigator.of(context)
                //     .pushNamed(PDFViewer.routeName, arguments: data5);
              },
            ),
            _buildDivider(),
            ListTile(
              leading: Icon(
                FontAwesomeIcons.bell,
                color: Colors.grey[800],
              ),
              title: const Text("Notification"),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                dynamic data5 = {
                  'course_id': '',
                  'link': notification,
                  'path': "notifications",
                  'filename': "Notification",
                };
                // Navigator.of(context)
                //     .pushNamed(PDFViewer.routeName, arguments: data5);
              },
            ),
            _buildDivider(),
            ListTile(
              leading: Icon(
                Icons.help,
                color: Colors.grey[800],
              ),
              title: const Text("Exam Pattern"),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                dynamic data5 = {
                  'course_id': '',
                  'link': exampattern,
                  'path': "exampatterns",
                  'filename': "Exam Pattern",
                };
                // Navigator.of(context)
                //     .pushNamed(PDFViewer.routeName, arguments: data5);
              },
            ),
            _buildDivider(),
            ListTile(
              leading: Icon(
                Icons.table_rows,
                color: Colors.grey[800],
              ),
              title: const Text("State Wise Seats"),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                dynamic data61 = {
                  'course_id': '',
                  'link': seats,
                  'path': "seats",
                  'filename': "State Wise Seats",
                };
                // Navigator.of(context)
                //     .pushNamed(PDFViewer.routeName, arguments: data61);
              },
            ),
            _buildDivider(),
            ListTile(
              leading: Icon(
                Icons.format_quote,
                color: Colors.grey[800],
              ),
              title: const Text("FAQ's"),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                dynamic data71 = {
                  'course_id': '',
                  'link': faq,
                  'path': "faq",
                  'filename': "FAQ's",
                };
                // Navigator.of(context)
                //     .pushNamed(PDFViewer.routeName, arguments: data71);
              },
            ),
          ],
        ),
      ),
    );
  }

  Container _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      width: double.infinity,
      height: 1.0,
      color: Colors.grey.shade400,
    );
  }

  _loadMCQ(context) {
    return Container(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: data2.length,
        itemBuilder: (context, index) {
          return _listLoad(
              context,
              int.parse(data2[index]["title_id"]),
              data2[index]["title_name"],
              data2[index]["syllabus"],
              data2[index]["time_duration"],
              data2[index]["pass_mark"],
              data2[index]["random_ques_no"]);
        },
      ),
    );
  }

  _categoryPressed(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => BottomSheet(
        builder: (_) => QuizOptionsDialog(
          category: category,
        ),
        onClosing: () {},
      ),
    );
  }

  _listLoad(BuildContext context, int id, String title, String syllabus,
      String timeDuration, String passMark, String? randomQuesNo) {
    return GestureDetector(
      onTap: () {
        _categoryPressed(
            context, Category(id, title, icon: FontAwesomeIcons.earthAsia));
      },
      child: Column(children: [
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
          padding: const EdgeInsets.fromLTRB(18, 10, 10, 10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  offset: Offset(0.5, 0.5),
                  blurRadius: 2,
                ),
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 4.0),
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                height: 1,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    color: Colors.red,
                    width: 4,
                    height: 50,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          syllabus,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Passing Marks: $passMark%",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.filter_list),
                  const SizedBox(width: 5),
                  Text(
                    (randomQuesNo ?? '0'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.timer),
                  const SizedBox(width: 5),
                  Text(
                    timeDuration,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }

  _loadShortNotes(context) {
    return Container(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: data3.length,
        itemBuilder: (context, index) {
          return _listLoadShortNotes(context, int.parse(data3[index]["doc_id"]),
              data3[index]["doc_title"], data3[index]);
        },
      ),
    );
  }

  _listLoadShortNotes(BuildContext context, int id, String title, dynamic doc) {
    return Column(children: [
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
            const SizedBox(height: 1),
            Expanded(
              flex: 6,
              child: GestureDetector(
                onTap: () {
                  dynamic data5 = {
                    'course_id': doc["course_id"],
                    'link': doc['doc_link'],
                    'path': "course_docs",
                    'filename': doc['doc_title'],
                  };
                  // Navigator.of(context)
                  //     .pushNamed(PDFViewer.routeName, arguments: data5);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset('assets/pdffile.png', width: 30, height: 30),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 250,
                            child: Text(
                              title,
                              style: const TextStyle(fontSize: 18),
                              maxLines: 2,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
                onTap: () async {
                  var path2 = "${ApiService.websiteUrl}course_docs/" +
                      doc["course_id"] +
                      "/" +
                      doc['doc_link'];
                  final status = await Permission.storage.request();

                  if (status.isGranted) {
                    final externalDir = await getExternalStorageDirectory();

                    // await FlutterDownloader.enqueue(
                    //   url: path2,
                    //   savedDir: externalDir!.path,
                    //   fileName: doc['doc_title'],
                    //   showNotification: true,
                    //   openFileFromNotification: true,
                    // );
                  } else {
                    print("Permission deined");
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    gradient: LinearGradient(
                      colors: <Color>[Colors.red[200]!, Colors.red],
                    ),
                  ),
                  child: const Icon(Icons.archive, color: Colors.white),
                ))
          ],
        ),
      ),
      const SizedBox(height: 1),
    ]);
  }

  _loadSamplePapers(context) {
    return Container(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: data4.length,
        itemBuilder: (context, index) {
          return _listLoadSamplePapers(
              context,
              int.parse(data4[index]["audio_id"]),
              data4[index]["audio_title"],
              data4[index]);
        },
      ),
    );
  }

  _listLoadSamplePapers(
      BuildContext context, int id, String title, dynamic doc) {
    return Column(children: [
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
            const SizedBox(height: 1),
            Expanded(
              flex: 6,
              child: GestureDetector(
                onTap: () {
                  dynamic data5 = {
                    'course_id': doc["course_id"],
                    'path': "course_audios",
                    'link': doc['audio_link'],
                    'filename': doc['audio_title'],
                  };
                  // Navigator.of(context)
                  //     .pushNamed(PDFViewer.routeName, arguments: data5);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset('assets/pdffile.png', width: 30, height: 30),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 250,
                            child: Text(
                              title,
                              style: const TextStyle(fontSize: 18),
                              maxLines: 2,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
                onTap: () async {
                  var path2 = "${ApiService.websiteUrl}course_audios/" +
                      doc["course_id"] +
                      "/" +
                      doc['audio_link'];
                  final status = await Permission.storage.request();

                  if (status.isGranted) {
                    final externalDir = await getExternalStorageDirectory();

                    // await FlutterDownloader.enqueue(
                    //   url: path2,
                    //   savedDir: externalDir!.path,
                    //   fileName: doc['audio_title'],
                    //   showNotification: true,
                    //   openFileFromNotification: true,
                    // );
                  } else {
                    print("Permission deined");
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    gradient: LinearGradient(
                      colors: <Color>[Colors.red[200]!, Colors.red],
                    ),
                  ),
                  child: const Icon(Icons.archive, color: Colors.white),
                ))
          ],
        ),
      ),
      const SizedBox(height: 1),
    ]);
  }
}
