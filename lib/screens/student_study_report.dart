import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:careerapp/screens/openurl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:careerapp/screens/student_study_weeklytest.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StudentStudyReport extends StatefulWidget {
  static const routeName = '/StudentStudyReport';

  const StudentStudyReport({Key? key}) : super(key: key);

  @override
  State<StudentStudyReport> createState() => _StudentStudyReportState();
}

class _StudentStudyReportState extends State<StudentStudyReport> with SingleTickerProviderStateMixin {
  var isSelected = List<bool>.generate(13, (index) => index == 0);
  var selectedButton = 0;
  var data6 = {};
  var data7 = [];
  var data8 = [];
  var data9 = [];
  var weeklytest_list = [];
  var entrance = {};
  var ptmdetails = [];
  var parentsFaq = [];
  List subJuniorPhotos = [];
  List juniorPhotos = [];
  List seniorPhotos = [];
  var academicphotos = [];
  dynamic data = {};
  var date = "";
  var userData;
  var user_id;
  var study_status = "";
  var review = "";
  var page = 1;
  var obtain_marks = 0;
  var total_marks2 = 0;
  double total_average = 0;
  var present_days = 0;
  var total_days = 0;
  var attendance = {};
  var class_rank = "-";
  var school_rank = "-";
  var class_teacher_name = '';
  var class_teacher_mobile = '';
  var my_school_id;
  var weekly_test_id = "";
  var weekly_test_date = "";
  List examCalendarData = [];
  List holidayHomeworkList = [];
  List examSyllabusList = [];
  bool isLoading = true;
  bool isHolidayHomeworkLoading = false;
  bool isHolidayHomeworkLoaded = false;
  bool isExamSyllabusLoading = false;
  bool isExamSyllabusLoaded = false;
  bool _hasValidRouteData = true;
  String _routeErrorMessage = '';
  late TabController _tabController;
  final ScrollController _tabBarScrollController = ScrollController();
  bool _hasShownTabScrollHint = false;
  List classMonitorList = [];

  // Selected academic session for the Report Card section only.
  String selectedReportSession = '2026-2027';
  final List<String> reportSessions = const [
    '2026-2027', '2025-2026', '2024-2025',
  ];

  List<Map<String, dynamic>> school1Students = [];
  List<Map<String, dynamic>> school2Students = [];
  List<Map<String, dynamic>> school3Students = [];

  // Color scheme
  static const Color primaryColor = Color(0xFF1565C0);
  static const Color secondaryColor = Color(0xFF42A5F5);
  static const Color accentColor = Color(0xFF64B5F6);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  final Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    // _tabController = TabController(length: 8, vsync: this);
    _tabController = TabController(length: 13, vsync: this);

    _tabController.addListener(() {
      setState(() {
        selectedButton = _tabController.index;
        for (int i = 0; i < isSelected.length; i++) {
          isSelected[i] = i == selectedButton;
        }
        setPage(selectedButton);
      });
    });
    
    Future.delayed(Duration.zero, () {
      final routeData = ModalRoute.of(context)?.settings.arguments;
      if (routeData == null || routeData is! Map<String, dynamic>) {
        _hasValidRouteData = false;
        _routeErrorMessage =
            'Student data missing. Open this report from a student profile or dashboard.';
        setState(() {
          isLoading = false;
        });
        return;
      }

      data = routeData;
      print("StudentStudyReport route data: ${data}");
      print("StudentStudyReport keys: ${data.keys}");
      print("StudentStudyReport class_name=${data["class_name"]} class_for=${data["class_for"]} school_id=${data["school_id"]}");
      my_school_id = data["school_id"];
      loadClassTeacher(data["class_for"], data["section"], data["school_id"]);
      getData0();
      loadWeeklyTestList(data["school_id"]);
      getStudentAttendance();
      getData();
      getData3();
      getData10();
      getData5();
      getData6();
      getSpokenEnglishData();
      getData9(data["school_id"]);
      getExamSyllabus();
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _tabBarScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _scheduleTabScrollHint() {
    if (_hasShownTabScrollHint) return;
    _hasShownTabScrollHint = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTabScrollHint();
    });
  }

  Future<void> _showTabScrollHint() async {
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted || !_tabBarScrollController.hasClients) return;

    const twoTabStepOffset = 166.0 * 2;

    while (mounted && _tabBarScrollController.hasClients) {
      final currentOffset = _tabBarScrollController.offset;
      final maxOffset = _tabBarScrollController.position.maxScrollExtent;
      if (currentOffset >= maxOffset || maxOffset <= 0) return;

      final nextOffset =
          (currentOffset + twoTabStepOffset).clamp(0.0, maxOffset).toDouble();

      await _tabBarScrollController.animateTo(
        nextOffset,
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeInOutCubic,
      );

      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Widget buildAcademicPhotoList(List photos) {
    if (photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "No photos available",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Check back later for updates",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            )
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: photos.length,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      itemBuilder: (context, index) {
        return listTile(photos[index]);
      },
    );
  }

  loadWeeklyTestList(schoolId) async {
    weeklytest_list = [];

    var res = await ApiService.getMethod3(
        "/getWeeklyTestList?school_id=" + schoolId);

    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      weeklytest_list = d["data"];
      if (weeklytest_list.isNotEmpty) {
        weekly_test_id = weeklytest_list[0]["id"];
      }
    }
    setState(() {});
  }

Future<void> getSpokenEnglishData() async {
  setState(() => isLoading = true);
  try {
    var res = await ApiService.getMethod3("/getSpokenEnglish");
    var d = jsonDecode(res.body);
    print(d);
    if (d["error"] == false) data6 = d["data"];
  } catch (e) {
    print("Error fetching spoken English data: $e");
  }
  setState(() => isLoading = false);
}


Future<void> getWeekStudents() async {
  setState(() => isLoading = true);

  try {
    final res = await ApiService.getMethod3("/getWeekStudents");
    final d = jsonDecode(res.body);
print("Week Students: $d");
    if (d["error"] == false) {
      List allStudents = d["data"];

      school1Students = allStudents
          .where((e) => e["school_id"]?.toString() == "1")
          .cast<Map<String, dynamic>>()
          .toList();

      school2Students = allStudents
          .where((e) => e["school_id"]?.toString() == "2")
          .cast<Map<String, dynamic>>()
          .toList();

      school3Students = allStudents
          .where((e) => e["school_id"]?.toString() == "3")
          .cast<Map<String, dynamic>>()
          .toList();
    }
  } catch (e) {
    print("Error fetching weekly students: $e");
  }

  setState(() => isLoading = false);
}

Future<void> getClassMonitorData() async {
  setState(() => isLoading = true);
  try {
    final res = await ApiService.getMethod3(
      "/getmyclassmonitor?class_for=${data["class_for"]}&section=${data["section"]}"
    );

    if (res.body.isEmpty) {
      print("Empty response for class monitor.");
      classMonitorList = [];
      return;
    }

    final d = jsonDecode(res.body);
    if (d["error"] == false && d["data"] is List) {
      classMonitorList = List<Map<String, dynamic>>.from(d["data"]);
    } else {
      classMonitorList = [];
    }
  } catch (e) {
    print("Error fetching class monitor data: $e");
    classMonitorList = [];
  } finally {
    if (mounted) {
      setState(() => isLoading = false);
    }
  }
}


  getData9(schoolId) async {
    data9 = [];

    var res =
        await ApiService.getMethod3("/getSchoolPTM?school_id=" + schoolId);

    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      data9 = d["data"];
      try {
        data9.sort((a, b) {
          final dateA = _parseDateValue(a);
          final dateB = _parseDateValue(b);
          return dateA.compareTo(dateB);
        });
      } catch (_) {
        // Keep original order if parsing fails.
      }
    }
    setState(() {});
  }

  loadClassTeacher(className, section, schoolId) async {
    var res = await ApiService.getMethod3("/getClassTeacherV2?class_name=" +
        className +
        "&section=" +
        section +
        '&school_id=' +
        schoolId);
    dynamic d = jsonDecode(res.body);
    if (d["status"] == "200" || d["status"] == 200) {
      class_teacher_name = d["data"]["name"];
      class_teacher_mobile = d["data"]["mobile"];
    }
    setState(() {});
  }

  /* tab 1 start */
  getData0() async {
    obtain_marks = 0;
    total_marks2 = 0;

    var res = await ApiService.getMethod3("${"${"/getWeeklyResultReport3?user_id=" +
        data["id"]}&page=$page&school_id=" +
        my_school_id}&weekly_test_id=$weekly_test_id");

    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      data8 = d["data"];
      for (var element in data8) {
        obtain_marks += int.parse(element["obtain_marks"]);
        total_marks2 += int.parse(element["total_marks"]);
      }

      total_average = (obtain_marks * 100) / total_marks2;

      if (total_average == 0) {
        study_status = "Not present";
      } else {
        if (total_average >= 70) {
          study_status = "Excellent";
        } else if (total_average >= 40 && total_average < 70) {
          study_status = "Good";
        } else {
          study_status = "Poor";
        }
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  getStudentAttendance() async {
    study_status = "";
    var res = await ApiService.getMethod3(
        "/getStudentAttendance?user_id=" + data["id"]);
    dynamic d = jsonDecode(res.body);
    if (d["error"] == false) {
      attendance = d["data"];
      present_days = int.parse(attendance["present_days"]);
      total_days = int.parse(attendance["total_days"]);
    }
    if (mounted) {
      setState(() {});
    }
  }

  getData() async {
    study_status = "";
    var res = await ApiService.getMethod3(
        "${"/getStudyReportV3?user_id=" + data["id"]}&page=$page");
    dynamic d = jsonDecode(res.body);
    if (d["error"] == false) {
      data6 = d["data"];
      date = data6["date"];
      review = "Positive: " + data6["remark"] + "\n\n";
      review += "Negative: " + data6["negative_remark"];
    }
    setState(() {});
  }

  /* tab 2 start */
  getData2() async {
    var res = await ApiService.getMethod3("${"/getWorkReportV3?class_for=" +
        data["class_for"] +
        "&section=" +
        data["section"]}&page=$page");

    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      data7 = d["data"];
      date = d["date"];
    } else {
      data7 = [];
      date = d["date"];
    }
    if (mounted) {
      setState(() {});
    }
  }

  /* tab 3 start */
  getData3() async {
    var res =
        await ApiService.getMethod3("/getPTMDetails?user_id=" + data["id"]!);

    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      ptmdetails = d["data"];
      try {
        ptmdetails.sort((a, b) {
          final dateA = _parseDateValue(a);
          final dateB = _parseDateValue(b);
          return dateA.compareTo(dateB);
        });
      } catch (_) {
        // Keep original order if parsing fails.
      }
    }

    setState(() {});
  }

  getData10() async {
    var res =
        await ApiService.getMethod3("/getParentsFaqs?user_id=" + data["id"]!);

    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      setState(() {
        parentsFaq = d["data"];
      });
    }
  }

  getData5() async {
    var res = await ApiService.getMethod3("/getAcademicPhotos?school_id=${data['school_id']}");
    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      academicphotos = d["data"];

      juniorPhotos = academicphotos.where((item) {
        String className = item["class_name"].toString().toLowerCase();
        return className.contains("Junior") || 
              className.contains("5") || 
              className.contains("6") || 
              className.contains("7") || 
              className.contains("8");
      }).toList();

      seniorPhotos = academicphotos.where((item) {
        String className = item["class_name"].toString().toLowerCase();
        return className.contains("senior") || 
              className.contains("9") || 
              className.contains("10") || 
              className.contains("11") || 
              className.contains("12");
      }).toList();
    }

    setState(() {});
  }

  /* tab 4 start */
  getData4() async {
    var res =
        await ApiService.getMethod3("/getEntranceTest?user_id=" + data["id"]);
    dynamic d = jsonDecode(res.body);
    setState(() {
      entrance = d["data"];
    });
  }

  getData6() async {
    var res = await ApiService.getMethod3("/getExamCalender");
    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      examCalendarData = d["data"];
    }

    setState(() {});
  }

  Future<void> getHolidayHomework() async {
    final className = (data["class_for"] ?? data["class_name"] ?? "").toString().trim();
    final schoolId = (data["school_id"] ?? "").toString().trim();

    print("Holiday homework request class_name='$className' school_id='$schoolId'");

    if (className.isEmpty || schoolId.isEmpty) {
      holidayHomeworkList = [];
      isHolidayHomeworkLoaded = true;
      if (mounted) {
        setState(() {});
      }
      return;
    }

    setState(() => isHolidayHomeworkLoading = true);

    try {
      final res = await ApiService.getMethod3(
        "/getHolidayHomework?class_name=${Uri.encodeComponent(className)}&school_id=${Uri.encodeComponent(schoolId)}",
      );
      final d = jsonDecode(res.body);
      print("Holiday Homework Response: $d");

      final responseData = d["data"];
      if (d["error"] == false && responseData is List) {
        holidayHomeworkList = responseData;
      } else {
        holidayHomeworkList = [];
      }
      isHolidayHomeworkLoaded = true;
    } catch (e) {
      print("Error fetching holiday homework: $e");
      holidayHomeworkList = [];
      isHolidayHomeworkLoaded = true;
    }

    if (mounted) {
      setState(() => isHolidayHomeworkLoading = false);
    }
  }

  setPage(p) {
    page = 1;
    if (p == 0) {
      // Already loaded in initState
    } else if (p == 1) {
      getData2();
    } else if (p == 2 &&
        !isHolidayHomeworkLoaded &&
        !isHolidayHomeworkLoading) {
      getHolidayHomework();
    } else if (p == 3 &&
        !isExamSyllabusLoaded &&
        !isExamSyllabusLoading) {
      getExamSyllabus();
    } else if (p == 4) {
      getData3();
    } else if (p == 5) {
      getData4();
    } else if (p == 7) {
      getData6();
    } else if (p == 8) {
      getSpokenEnglishData();
    } else if (p == 9) {
      getData10();
    } else if (p == 10) {
      getClassMonitorData();
    } else if (p == 11) {
      getWeekStudents();
    }


  }

  prePage() {
    setState(() {
      page++;
      if (page >= 1) {
        if (selectedButton == 0) {
          getData0();
        } else if (selectedButton == 1) {
          getData2();
        } else if (selectedButton == 3) {
          getData3();
        }
      }
    });
  }

  nextPage() {
    setState(() {
      page--;
      if (page >= 1) {
        if (selectedButton == 0) {
          getData0();
        } else if (selectedButton == 1) {
          getData2();
        }
      }
    });
  }

  getAttendancePer() {
    var str = "";
    double val = 0;
    var status = "";
    if (total_days != 0) {
      val = (present_days / total_days) * 100;
    }
    if (val >= 91 && val <= 100) {
      status = "Excellent";
    } else if (val >= 81 && val <= 90) {
      status = "Very Good";
    } else if (val >= 71 && val <= 80) {
      status = "Good";
    } else {
      status = "Poor";
    }
    str = "${val.toStringAsFixed(0)}% $status";
    return str;
  }

  Color getAttendanceColor() {
    double val = 0;
    if (total_days != 0) {
      val = (present_days / total_days) * 100;
    }
    
    if (val >= 91) return Colors.green.shade700;
    if (val >= 81) return Colors.green.shade500;
    if (val >= 71) return Colors.orange.shade500;
    return Colors.red.shade500;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Student Study Report",
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (selectedButton == 7)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                final row = {
                  "school_name": "Exam Calendar",
                  "url": "https://careerdefenceacademy.com/HomeController/exam_calendar"
                };
                Navigator.of(context).pushNamed(OpenUrl.routeName, arguments: row);
              },
            ),
        ],
      ),
      body: isLoading
          ? _buildLoadingScreen()
          : (!_hasValidRouteData
              ? _buildRouteErrorScreen()
              : Column(
                  children: [
                    _buildTabBar(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildWeeklyResultTab(),
                          _buildSyllabusUpdateTab(),
                          _buildHolidayHomeworkTab(),
                          _buildExamSyllabusTab(),
                          _buildPTMDetailsTab(),
                          _buildReportCardTab(),
                          _buildAcademicClassTab(),
                          _buildExamCalendarTab(),
                          _buildSpokenEnglishTab(),
                          _buildParentsFAQTab(),
                          _buildClassMonitorTab(),
                          _buildWeeklyStudentsTab(),
                          _buildSundayMarathonTab(),
                        ],
                      ),
                    ),
                  ],
                )),

    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: primaryColor,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: const Text(
              "Loading student data...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 72, color: Colors.red.shade700),
            const SizedBox(height: 16),
            Text(
              _routeErrorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    _scheduleTabScrollHint();

    return Container(
      height: 76,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      decoration: BoxDecoration(
        color: primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: ListView(
              controller: _tabBarScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: [
                _buildTab(0, FontAwesomeIcons.chartLine, "Weekly Result"),
                _buildTab(1, FontAwesomeIcons.book, "Syllabus Update"),
                _buildTab(2, FontAwesomeIcons.bookOpen, "Holiday Homework"),
                _buildTab(3, FontAwesomeIcons.school, "Exam Syllabus"),
                _buildTab(4, FontAwesomeIcons.userGroup, "PTM Details"),
                _buildTab(5, FontAwesomeIcons.fileLines, "Report Card"),
                _buildTab(6, FontAwesomeIcons.graduationCap, "Academic Class"),
                _buildTab(7, FontAwesomeIcons.calendar, "Exam Calendar"),
                _buildTab(8, FontAwesomeIcons.microphone, "Spoken English"),
                _buildTab(9, FontAwesomeIcons.circleQuestion, "Parents FAQ"),
                _buildTab(10, FontAwesomeIcons.userTie, "Class Monitor"),
                _buildTab(11, FontAwesomeIcons.users, "Weak Students"),
                _buildTab(12, FontAwesomeIcons.users, "Sunday Marathon"),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                width: 42,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      primaryColor.withOpacity(0),
                      primaryColor.withOpacity(0.92),
                    ],
                  ),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.9),
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final isActive = selectedButton == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (_tabController.index != index) {
            _tabController.index = index;
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 158,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.14),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? primaryColor : Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    color: isActive
                        ? primaryColor
                        : Colors.white.withOpacity(0.88),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyResultTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAttendanceCard(),
          const SizedBox(height: 6),
          if (class_teacher_name.isNotEmpty) _buildTeacherInfoCard(),
          const SizedBox(height: 6),
          _buildStudyStatusCard(),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                StudentStudyWeeklyTest.routeName,
                arguments: data
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.history, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Text(
                    "View previous weekly test results",
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue.shade700),
                ],
              ),
            ),
          ),
          // SizedBox(height: 16),
          // _buildWeeklyTestDropdown(),
          // SizedBox(height: 16),
          // _buildWeeklyTestResults(),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard() {
    double attendancePercentage = total_days > 0 ? present_days / total_days : 0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_today, color: primaryColor),
                SizedBox(width: 4),
                Text(
                  "Attendance (85% Compulsory)",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                ),
              ],
            ),
            // SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: CircularPercentIndicator(
                    radius: 40.0,
                    lineWidth: 8.0,
                    animation: true,
                    percent: attendancePercentage,
                    center: Text(
                      "${(attendancePercentage * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: getAttendanceColor(),
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Present: $present_days days",
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Total: $total_days days",
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        getAttendancePer(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: getAttendanceColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildTeacherInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person, color: primaryColor),
                SizedBox(width: 8),
                Text(
                  "Class Teacher Information",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Name:",
                        style: TextStyle(
                          fontSize: 14,
                          color: textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        class_teacher_name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Expanded(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         "Contact:",
                //         style: TextStyle(
                //           fontSize: 14,
                //           color: textSecondaryColor,
                //         ),
                //       ),
                //       SizedBox(height: 4),
                //       GestureDetector(
                //         onTap: () {
                //           launch("tel://" + class_teacher_mobile);
                //         },
                //         child: Row(
                //           children: [
                //             Icon(Icons.phone, size: 16, color: Colors.blue),
                //             SizedBox(width: 4),
                //             Text(
                //               class_teacher_mobile,
                //               style: TextStyle(
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.w500,
                //                 color: Colors.blue,
                //                 decoration: TextDecoration.underline,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStudyStatusCard() {
    Color statusColor;
    IconData statusIcon;
    
    if (study_status == "Excellent") {
      statusColor = Colors.green.shade700;
      statusIcon = Icons.emoji_events;
    } else if (study_status == "Good") {
      statusColor = Colors.orange.shade600;
      statusIcon = Icons.thumb_up;
    } else if (study_status == "Poor") {
      statusColor = Colors.red.shade600;
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.grey.shade600;
      statusIcon = Icons.help_outline;
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(statusIcon, color: Colors.white, size: 20),
                const SizedBox(width: 2),
                Text(
                  "Study Status: $study_status",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.thumb_up, size: 12),
                        label: const Text("Positive"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            review = "Positive: " + data6["remark"];
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.thumb_down, size: 12),
                        label: const Text("Negative"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            review = "Negative: " + data6["negative_remark"];
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    review,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  // Widget _buildWeeklyTestDropdown() {
  //   return Card(
  //     elevation: 2,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Padding(
  //       padding: EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             "Select Weekly Test",
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.bold,
  //               color: textPrimaryColor,
  //             ),
  //           ),
  //           SizedBox(height: 12),
  //           Container(
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(8),
  //               border: Border.all(color: Colors.grey.shade300),
  //             ),
  //             child: DropdownButtonFormField(
  //               decoration: InputDecoration(
  //                 contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //                 border: InputBorder.none,
  //                 hintText: "Select Weekly Test",
  //               ),
  //               value: weekly_test_id.isEmpty ? null : weekly_test_id,
  //               isExpanded: true,
  //               icon: Icon(Icons.arrow_drop_down, color: primaryColor),
  //               style: TextStyle(color: textPrimaryColor, fontSize: 15),
  //               items: weeklytest_list
  //                   .map<DropdownMenuItem<String>>((value) =>
  //                       DropdownMenuItem<String>(
  //                         value: value["id"].toString(),
  //                         child: Text(value["weeklytest_name"]),
  //                       ))
  //                   .toList(),
  //               onChanged: (val) {
  //                 setState(() {
  //                   weekly_test_id = val.toString();
  //                   getData0();
  //                 });
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   ).animate().fadeIn(duration: 500.ms, delay: 600.ms).slideY(begin: 0.2, end: 0);
  // }

  Widget _buildWeeklyTestResults() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Subject Results",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "Total: $obtain_marks/$total_marks2 (${total_average.toStringAsFixed(1)}%)",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            data8.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            "No test results available",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data8.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = data8[index];
                      final obtainMarks = int.parse(item["obtain_marks"]);
                      final totalMarks = int.parse(item["total_marks"]);
                      final percentage = totalMarks > 0 ? (obtainMarks / totalMarks) * 100 : 0;
                      
                      return _buildSubjectResultItem(
                        subject: item["subject"],
                        obtainMarks: obtainMarks,
                        totalMarks: totalMarks,
                        percentage: percentage.toDouble(),
                      );
                    },
                  ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 800.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSubjectResultItem({
    required String subject,
    required int obtainMarks,
    required int totalMarks,
    required double percentage,
  }) {
    Color progressColor;
    if (percentage >= 75) {
      progressColor = Colors.green.shade600;
    } else if (percentage >= 50) {
      progressColor = Colors.orange.shade600;
    } else {
      progressColor = Colors.red.shade600;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject.toUpperCase(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "$obtainMarks/$totalMarks",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 8.0,
            percent: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            progressColor: progressColor,
            barRadius: const Radius.circular(4),
            animation: true,
            animationDuration: 1000,
          ),
        ],
      ),
    );
  }

  Widget _buildSyllabusUpdateTab() {
    return data7.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  "No syllabus updates available",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : Column(
            children: [
              if (date.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: Colors.grey.shade100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 16),
                        onPressed: prePage,
                      ),
                      Text(
                        DateFormat('dd MMM yyyy').format(DateTime.parse(date)),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        onPressed: nextPage,
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data7.length,
                  itemBuilder: (context, index) {
                    return _buildSyllabusItem(data7[index]);
                  },
                ),
              ),
            ],
          );
  }

  Widget _buildSyllabusItem(Map<String, dynamic> item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item["subject"].toString().toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow("Teacher", item["name"]),
            _buildInfoRow("Chapter No.", item["chapter_no"]),
            _buildInfoRow("Chapter", item["chapter"] ?? "---"),
            _buildInfoRow("Topic", item["topic"] ?? "---"),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms * (data7.indexOf(item) % 10)).slideY(begin: 0.1, end: 0);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPTMDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Upcoming PTM & Holidays",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          data9.isEmpty
              ? _buildEmptyState(
                  icon: Icons.event_busy,
                  message: "No upcoming PTM or holidays scheduled",
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data9.length,
                  itemBuilder: (context, index) {
                    return _buildPTMCard(data9[index], index);
                  },
                ),
          const SizedBox(height: 24),
          const Text(
            "Student PTM History",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ptmdetails.isEmpty
              ? _buildEmptyState(
                  icon: Icons.history,
                  message: "No PTM history available",
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ptmdetails.length,
                  itemBuilder: (context, index) {
                    return _buildPTMHistoryCard(ptmdetails[index], index);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildPTMCard(Map<String, dynamic> item, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item["ptm_notice"].toString().toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              if (item["time"] == "09:00:00")
                const Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.white70),
                    SizedBox(width: 8),
                    Text(
                      "Time: 09:00 AM - 01:00 PM",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms * index).slideX(begin: 0.1, end: 0);
  }

  Widget _buildPTMHistoryCard(Map<String, dynamic> item, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item["type"].toString().toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item["status"] == "Present" ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item["status"],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: item["status"] == "Present" ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow("Date", DateFormat('dd MMM yyyy').format(DateTime.parse(item["date"]))),
            _buildInfoRow("Relation", item["relation"]),
            _buildInfoRow("Remark", item["remark"]),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms * index).slideX(begin: -0.1, end: 0);
  }

  Widget _buildReportCardTab() {
    final schoolId = Uri.encodeQueryComponent(data['school_id'].toString());
    final studentId = Uri.encodeQueryComponent(data['id'].toString());

    String reportUrl(String endpoint, String session, String type,
        {bool includeSession = true}) {
      final sessionQuery = includeSession
          ? '&session=${Uri.encodeQueryComponent(session)}'
          : '';
      return 'https://careerdefenceacademy.com/HomeController/$endpoint'
          '?school_id=$schoolId&student_id=$studentId'
          '$sessionQuery&type=$type';
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, color: Colors.blue.shade700, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Report Card',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'View your academic performance',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            // Session tabs: change only the cards shown below.
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: reportSessions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final session = reportSessions[index];
                  final selected = selectedReportSession == session;
                  return ChoiceChip(
                    label: Text(session),
                    selected: selected,
                    selectedColor: primaryColor,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    side: BorderSide(color: primaryColor.withOpacity(0.25)),
                    onSelected: (_) {
                      setState(() => selectedReportSession = session);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            if (selectedReportSession == '2026-2027') ...[
              _buildReportCardItem(
                title: 'Unit 1 (2026-2027)',
                icon: Icons.assignment,
                color: Colors.teal.shade700,
                url: reportUrl('digital_pt1_2026', '2026-2027', 'unit1', includeSession: false),
              ),
              _buildReportCardItem(
                title: 'Unit 2 (2026-2027)',
                icon: Icons.assignment,
                color: Colors.teal.shade700,
                url: reportUrl('digital_reportcard_unit2', '2026-2027', 'unit2', includeSession: false),
              ),
              _buildReportCardItem(
                title: 'Half Yearly (2026-2027)',
                icon: Icons.assignment,
                color: Colors.teal.shade700,
                url: reportUrl('halfyearly', '2026-2027', 'half_yearly', includeSession: false),
              ),
            ] else if (selectedReportSession == '2025-2026') ...[
              _buildReportCardItem(
                title: 'Unit Test 1 (2025-2026)',
                icon: Icons.assignment,
                color: Colors.blue.shade600,
                url: reportUrl('digital_reportcard', '2025-2026', 'unit1'),
              ),
              _buildReportCardItem(
                title: 'Unit Test 2 (2025-2026)',
                icon: Icons.assignment_turned_in,
                color: Colors.blue.shade700,
                url: reportUrl('digital_reportcard_unit2', '2025-2026', 'unit2'),
              ),
              _buildReportCardItem(
                title: 'Unit Test 3 (2025-2026)',
                icon: Icons.assignment_late,
                color: Colors.blue.shade800,
                url: reportUrl('digital_reportcard_unit3', '2025-2026', 'unit3'),
              ),
              _buildReportCardItem(
                title: 'Half Yearly (2025-2026)',
                icon: Icons.calendar_today,
                color: Colors.indigo.shade800,
                url: reportUrl('digital_reportcard_half_yearly', '2025-2026', 'half_yearly'),
              ),
              _buildReportCardItem(
                title: 'Final Result Report Card (2025-2026)',
                icon: Icons.description,
                color: Colors.purple.shade700,
                url: reportUrl('report_card_print1', '2025-2026', 'final'),
              ),
            ] else if (selectedReportSession == '2024-2025') ...[
              _buildReportCardItem(
                title: 'Final Result Digital Card (2024-2025)',
                icon: Icons.card_membership,
                color: Colors.deepPurple.shade600,
                url: reportUrl('report_card_print', '2024-2025', 'final'),
              ),
              _buildReportCardItem(
                title: 'Final Result Report Card (2024-2025)',
                icon: Icons.summarize,
                color: Colors.deepPurple.shade800,
                url: reportUrl('report_card_print21', '2024-2025', 'final'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportCardItem({
    required String title,
    required IconData icon,
    required Color color,
    required String url,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            dynamic row = {
              "school_name": "Report Card",
              "url": url,
            };
            Navigator.of(context).pushNamed(OpenUrl.routeName, arguments: row);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildAcademicClassTab() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          "Academic Class",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey.shade700,
                    tabs: const [
                      Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            "Junior Wing\n(Class 5th-8th)",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      Tab(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            "Senior Wing\n(Class 9th-12th)",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    children: [
                      buildAcademicPhotoList(juniorPhotos),
                      buildAcademicPhotoList(seniorPhotos),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExamCalendarTab() {
    return Column(
      children: [
        // Container(
        //   padding: EdgeInsets.all(16),
        //   color: primaryColor,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     // children: [
        //     //   Text(
        //     //     "Exam Calendar",
        //     //     style: TextStyle(
        //     //       fontSize: 18,
        //     //       fontWeight: FontWeight.bold,
        //     //       color: Colors.white,
        //     //     ),
        //     //   ),
        //     //   IconButton(
        //     //     icon: Icon(Icons.add, color: Colors.white),
        //     //     onPressed: () {
        //     //       final row = {
        //     //         "school_name": "Exam Calendar",
        //     //         "url": "https://careerdefenceacademy.com/HomeController/exam_calendar"
        //     //       };
        //     //       Navigator.of(context).pushNamed(OpenUrl.routeName, arguments: row);
        //     //     },
        //     //   ),
        //     // ],
        //   ),
        // ),
        Expanded(
          child: examCalendarData.isEmpty
              ? _buildEmptyState(
                  icon: Icons.event_busy,
                  message: "No exam calendar data available",
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: examCalendarData.length,
                  itemBuilder: (context, index) {
                    return _buildExamCalendarItem(examCalendarData[index], index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildExamCalendarItem(Map<String, dynamic> item, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.event_note,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item["title"].toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Start Date",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item["start_date"],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "End Date",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item["end_date"],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms * index).slideY(begin: 0.1, end: 0);
  }

  Widget _buildParentsFAQTab() {
    return parentsFaq.isEmpty
        ? _buildEmptyState(
            icon: Icons.question_answer,
            message: "No FAQs available",
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: parentsFaq.length,
            itemBuilder: (context, index) {
              return _buildFAQItem(parentsFaq[index], index);
            },
          );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq, int index) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isExpanded = false;
        VideoPlayerController? videoController;
        bool isPlaying = false;

        String? proofFile = faq['proof_file'];
        if (proofFile != null) {
          proofFile = "https://careerdefenceacademy.com/$proofFile";
        }

        if (proofFile?.endsWith(".mp4") == true) {
          videoController = VideoPlayerController.network(proofFile!)
            ..initialize().then((_) {
              videoController!.setLooping(true);
            });
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.question_mark,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          faq['question'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.question_answer,
                                color: Colors.blue.shade700,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Answer:",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          faq['answer'],
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (proofFile != null) ...[
                    const SizedBox(height: 16),
                    if (proofFile.endsWith(".jpg"))
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          proofFile,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (proofFile.endsWith(".mp4") && videoController != null)
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AspectRatio(
                              aspectRatio: videoController.value.aspectRatio,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  VideoPlayer(videoController),
                                  IconButton(
                                    icon: Icon(
                                      isPlaying ? Icons.pause : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isPlaying = !isPlaying;
                                        if (isPlaying) {
                                          videoController?.play();
                                        } else {
                                          videoController?.pause();
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Video Evidence",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    if (proofFile.endsWith(".mp3"))
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPlaying = !isPlaying;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Audio Recording",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 100.ms * index).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Check back later for updates",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget listTile(item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/classActivity/" +
                  item['img']);
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      "${ApiService.careerdefenceacademy2}includes/uploads/classActivity/" +
                          item['img'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade400,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd MMM yyyy').format(DateTime.parse(item["created_at"])),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Column(
                    children: [
                      Icon(
                        Icons.visibility,
                        color: primaryColor,
                        size: 20,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'View',
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
Widget _buildSpokenEnglishTab() {
  return isLoading
      ? const Center(child: CircularProgressIndicator())
      : data6.isEmpty
          ? _buildEmptyState(
              icon: Icons.mic_off, 
              message: "No spoken English content available.")
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: data6.length,
              itemBuilder: (context, index) {
                final item = data6[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.record_voice_over, color: primaryColor),
                    title: Text(
                      item['title'] ?? 'Untitled',
                      style: const TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(
                      item['description'] ?? '',
                      style: const TextStyle(fontSize: 10),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      // Handle tap if needed
                    },
                  ),
                );
              },
            );
}
Widget _buildClassMonitorTab() {
  if (isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (classMonitorList.isEmpty) {
    return _buildEmptyState(
      icon: Icons.person_off,
      message: "No class monitors assigned.",
    );
  }

  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: classMonitorList.length,
        itemBuilder: (context, index) {
          final item = classMonitorList[index];

          final fullName = "${item["first_name"] ?? ''} ${item["last_name"] ?? ''}".trim();
          final fatherName = item["father_name"] ?? '--';
          final classFor = item["class_for"] ?? '--';
          final section = item["section"] ?? '--';
          final assignedAt = item["assigned_at"] ?? '--';

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMonitorDetailRow("Father's Name", fatherName),
                  _buildMonitorDetailRow("Class", "$classFor, Section: $section"),
                  _buildMonitorDetailRow("Assigned At", assignedAt),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

Widget _buildMonitorDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4.0),
    child: RichText(
      text: TextSpan(
        text: "$label: ",
        style: const TextStyle(
          fontSize: 14,
          color: textSecondaryColor,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: textPrimaryColor,
            ),
          ),
        ],
      ),
    ),
  );
}


Widget _buildWeeklyStudentsTab() {
  return DefaultTabController(
    length: 3,
    child: Column(
      children: [
        const TabBar(
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: "Yamunanagar"),
            Tab(text: "Ambala"),
            Tab(text: "Patiala"),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              _buildStudentList(school2Students),
              _buildStudentList(school1Students),
              _buildStudentList(school3Students),
            ],
          ),
        )
      ],
    ),
  );
}

Widget _buildStudentList(List<Map<String, dynamic>> students) {
  if (students.isEmpty) {
    return _buildEmptyState(
      icon: Icons.people,
      message: "No weak students available.",
    );
  }

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: students.length,
    itemBuilder: (context, index) {
      final student = students[index];
      return Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${student['first_name']} ${student['last_name'] ?? ''}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textPrimaryColor,
                ),
              ),
              const SizedBox(height: 6),
              Text("Father: ${student['father_name'] ?? '--'}"),
              Text("Class: ${student['class_for']}, Section: ${student['section']}"),
              Text("School ID: ${student['school_id']}"),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildSundayMarathonTab() {
  return _buildEmptyState(
    icon: Icons.directions_run,
    message: "No Sunday marathon data available.",
  );
}

Widget _buildHolidayHomeworkTab() {
  if (isHolidayHomeworkLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (holidayHomeworkList.isEmpty) {
    return _buildEmptyState(
      icon: Icons.menu_book_outlined,
      message: "No holiday homework available.",
    );
  }

  return RefreshIndicator(
    color: primaryColor,
    onRefresh: () async {
      isHolidayHomeworkLoaded = false;
      await getHolidayHomework();
    },
    child: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: holidayHomeworkList.length,
      itemBuilder: (context, index) {
        final item = Map<String, dynamic>.from(holidayHomeworkList[index] as Map);
        return _buildHolidayHomeworkCard(item, index);
      },
    ),
  );
}

Widget _buildExamSyllabusTab() {
  if (!isExamSyllabusLoaded && !isExamSyllabusLoading) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !isExamSyllabusLoaded && !isExamSyllabusLoading) {
        getExamSyllabus();
      }
    });
  }

  if (isExamSyllabusLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (examSyllabusList.isEmpty) {
    return _buildEmptyState(
      icon: Icons.school_outlined,
      message: "No exam syllabus available.",
    );
  }

  return RefreshIndicator(
    color: primaryColor,
    onRefresh: () async {
      isExamSyllabusLoaded = false;
      await getExamSyllabus();
    },
    child: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: examSyllabusList.length,
      itemBuilder: (context, index) {
        final item = Map<String, dynamic>.from(examSyllabusList[index] as Map);
        return _buildExamSyllabusCard(item, index);
      },
    ),
  );
}

Widget _buildExamSyllabusCard(Map<String, dynamic> item, int index) {
  final title = _firstValue(item, ["Exam_Type", "exam_type", "title", "subject"], "Exam Syllabus");
  final subject = _firstValue(item, ["subject", "subject_name"], "--");
  final className = _firstValue(item, ["class_name", "class_for"], data["class_for"] ?? "--");
  final section = _firstValue(item, ["section_name", "section"], data["section"] ?? "--");
  final description = _firstValue(item, ["Exam_Description", "exam_description", "description", "details", "syllabus", "remark"], "");
  final createdAt = _firstValue(item, ["created_at", "date", "exam_date"], "");
  final attachmentUrl = _firstValue(item, ["attachment_url", "pdf_url", "attachment", "pdf_file"], "");
  final attachmentUrls = _holidayHomeworkAttachmentUrls(item);
  final openAttachmentUrl = attachmentUrl.isNotEmpty
      ? attachmentUrl
      : (attachmentUrls.isNotEmpty ? attachmentUrls.first : "");

  return Card(
    elevation: 3,
    margin: const EdgeInsets.only(bottom: 12),
    shadowColor: primaryColor.withOpacity(0.12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school, color: primaryColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (subject != "--") _buildInfoRow("Subject", subject),
          _buildInfoRow(
            "Class",
            section == "--" ? className : "$className, Section: $section",
          ),
          if (createdAt.isNotEmpty) _buildInfoRow("Date", _formatDisplayDate(createdAt)),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
          if (openAttachmentUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.attachment),
                label: const Text("Open Attachment"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  launch(_normalizeExamSyllabusFileUrl(openAttachmentUrl));
                },
              ),
            ),
          ],
        ],
      ),
    ),
  ).animate().fadeIn(duration: 300.ms, delay: 100.ms * index).slideY(begin: 0.1, end: 0);
}

Future<void> getExamSyllabus() async {
  final className = (data["class_for"] ?? data["class_name"] ?? "").toString().trim();
  final schoolId = (data["school_id"] ?? "").toString().trim();

  print("Exam syllabus request class_name='$className' school_id='$schoolId'");
  if (className.isEmpty || schoolId.isEmpty) {
    print("getExamSyllabus skipped because className or schoolId is empty. className='$className' schoolId='$schoolId'");
    examSyllabusList = [];
    isExamSyllabusLoaded = true;
    if (mounted) setState(() {});
    return;
  }

  setState(() => isExamSyllabusLoading = true);

  try {
    print("Fetching exam syllabus for class=$className school=$schoolId");
    final res = await ApiService.getMethod3(
     "/getHolidayExam?class_name=${Uri.encodeComponent(className)}&school_id=${Uri.encodeComponent(schoolId)}"
    );
    final d = jsonDecode(res.body);
    print("Exam Syllabus Response: $d");

    final responseData = d["data"];
    final status = d["status"];
    final error = d["error"];
    final count = responseData is List ? responseData.length : 0;
    print("Exam Syllabus parsed status=$status error=$error count=$count");

    if ((error == false || error == "false") && responseData is List) {
      examSyllabusList = responseData;
    } else {
      examSyllabusList = [];
    }
    isExamSyllabusLoaded = true;
  } catch (e) {
    print("Error fetching exam syllabus: $e");
    examSyllabusList = [];
    isExamSyllabusLoaded = true;
  }

  if (mounted) {
    setState(() => isExamSyllabusLoading = false);
  }
}

String _normalizeExamSyllabusFileUrl(String value) {
  if (value.startsWith("http")) {
    return value;
  }
  return "${ApiService.careerdefenceacademy2}uploads/$value";
}

Widget _buildHolidayHomeworkCard(Map<String, dynamic> item, int index) {
  final title = _firstValue(
      item, ["title", "homework_title", "subject"], "Holiday Homework");
  final subject = _firstValue(item, ["subject", "subject_name"], "--");
  final className =
      _firstValue(item, ["class_name", "class_for"], data["class_for"] ?? "--");
  final section = _firstValue(item, ["section"], data["section"] ?? "--");
  final description =
      _firstValue(item, ["description", "details", "homework", "remark"], "");
  final createdAt =
      _firstValue(item, ["created_at", "date", "homework_date"], "");
  final attachmentUrl = _firstValue(
      item, ["attachment_url", "pdf_url", "attachment", "pdf_file"], "");
  final attachmentUrls = _holidayHomeworkAttachmentUrls(item);

  return Card(
    elevation: 3,
    margin: const EdgeInsets.only(bottom: 12),
    shadowColor: primaryColor.withOpacity(0.12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.menu_book, color: primaryColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (subject != "--") _buildInfoRow("Subject", subject),
          _buildInfoRow(
            "Class",
            section == "--" ? className : "$className, Section: $section",
          ),
          if (createdAt.isNotEmpty) _buildInfoRow("Date", _formatDisplayDate(createdAt)),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
          if (attachmentUrl.isNotEmpty || attachmentUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            if (attachmentUrl.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.attachment),
                  label: const Text("Open Attachment"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    launch(_normalizeHolidayHomeworkFileUrl(attachmentUrl));
                  },
                ),
              ),
            ...attachmentUrls.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.attach_file),
                    label: Text("Open Attachment ${entry.key + 1}"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      launch(_normalizeHolidayHomeworkFileUrl(entry.value));
                    },
                  ),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    ),
  ).animate().fadeIn(duration: 300.ms, delay: 100.ms * index).slideY(begin: 0.1, end: 0);
}

String _firstValue(Map<String, dynamic> item, List<String> keys, String fallback) {
  for (final key in keys) {
    final value = item[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return fallback;
}

List<String> _holidayHomeworkAttachmentUrls(Map<String, dynamic> item) {
  final urls = item["attachments_urls"];
  if (urls is List) {
    return urls
        .where((url) => url != null && url.toString().trim().isNotEmpty)
        .map((url) => url.toString())
        .toList();
  }
  return [];
}

String _normalizeHolidayHomeworkFileUrl(String value) {
  if (value.startsWith("http")) {
    return value;
  }
  return "${ApiService.careerdefenceacademy2}uploads/holiday_homework/$value";
}

DateTime _parseDateValue(Map<String, dynamic> item) {
  final fields = [
    "date",
    "event_date",
    "holiday_date",
    "start_date",
    "end_date",
    "created_at",
    "updated_at",
  ];

  for (final field in fields) {
    final value = item[field];
    if (value != null && value.toString().trim().isNotEmpty) {
      final parsed = _tryParseDate(value.toString().trim());
      if (parsed != null) {
        return parsed;
      }
    }
  }

  return DateTime(1970);
}

DateTime? _tryParseDate(String value) {
  final normalized = value.replaceAll('/', '-').trim();

  final formats = [
    'yyyy-MM-dd',
    'dd-MM-yyyy',
    'MM-dd-yyyy',
    'yyyy-MM-dd HH:mm:ss',
    'dd-MM-yyyy HH:mm:ss',
    'MM-dd-yyyy HH:mm:ss',
    'dd MMM yyyy',
    'dd MMMM yyyy',
    'yyyy/MM/dd',
    'dd/MM/yyyy',
    'MM/dd/yyyy',
  ];

  for (final format in formats) {
    try {
      return DateFormat(format).parseStrict(normalized);
    } catch (_) {
      continue;
    }
  }

  return DateTime.tryParse(value);
}

String _formatDisplayDate(String value) {
  try {
    return DateFormat('dd MMM yyyy').format(DateTime.parse(value));
  } catch (_) {
    return value;
  }
}


}
