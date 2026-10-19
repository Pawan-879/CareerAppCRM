// 🏁 MAIN ENTRY
import 'dart:convert';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:careerapp/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'package:careerapp/services/api_services.dart';
import 'package:http/http.dart' as http;

import 'package:audioplayers/audioplayers.dart';
// import 'package:careerapp/screens/seat_availability_screen.dart';

import 'dart:ui';
// import 'package:careerapp/screens/App.dart';
import 'package:careerapp/services/common_service.dart';
import 'package:careerapp/config/firebase_options.dart';
import 'package:careerapp/screens/certification_courses.dart';
import 'package:careerapp/screens/lead_references.dart';
import 'package:careerapp/screens/leads.dart';
import 'package:careerapp/screens/medical_counselling_report.dart';
import 'package:careerapp/screens/mycourses_screen.dart';
// import 'package:careerapp/screens/pdf_viewer2.dart';
import 'package:careerapp/screens/science_experiment.dart';
import 'package:careerapp/screens/staff_salary.dart';
import 'package:careerapp/screens/student_report_card.dart';
import 'package:careerapp/screens/student_study_weeklytest.dart';
import 'package:careerapp/screens/weekly_copy_stamping.dart';
import 'package:careerapp/screens/weekly_copy_stamping_main.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sizer/sizer.dart';
import 'package:careerapp/screens/App.dart';
import 'package:careerapp/screens/consultant_leads.dart';
import 'package:careerapp/screens/dashboard.dart';
import 'package:careerapp/screens/training.dart';
import 'package:careerapp/screens/login.dart';
import 'package:careerapp/screens/student_activity_report.dart';
import 'package:careerapp/screens/student_attendance_report.dart';
import 'package:careerapp/screens/student_calling_report.dart';
import 'package:careerapp/screens/student_canteen_report.dart';
import 'package:careerapp/screens/student_counselling.dart';
import 'package:careerapp/screens/student_details.dart';
import 'package:careerapp/screens/student_fee_paid_forms.dart';
import 'package:careerapp/screens/student_feedback.dart';
import 'package:careerapp/screens/student_fees_detail.dart';
import 'package:careerapp/screens/student_fine_charges.dart';
import 'package:careerapp/screens/student_hostel_hygiene.dart';
import 'package:careerapp/screens/student_medical_report.dart';
import 'package:careerapp/screens/student_references.dart';
import 'package:careerapp/screens/student_requirements.dart';
import 'package:careerapp/screens/student_search.dart';
import 'package:careerapp/screens/student_study_report.dart';
import 'package:careerapp/screens/student_weekly_activity.dart';
import 'package:careerapp/screens/parents_faqs.dart';
import 'package:careerapp/screens/student_weekly_report.dart';
import 'package:careerapp/screens/super50.dart';
import 'package:careerapp/size_config.dart';
import 'package:careerapp/screens/course_details_screen.dart';
import 'package:careerapp/screens/spoken_english.dart';
import 'package:careerapp/screens/gaterequest.dart';
import 'package:careerapp/screens/our_functions.dart';
import 'package:careerapp/screens/mycourse_details_screen.dart';
import 'package:careerapp/screens/allcourses.dart';
import 'package:careerapp/screens/searchcourses.dart';
import 'package:careerapp/screens/player.dart';
import 'package:careerapp/screens/freeplayer.dart';
import 'package:careerapp/screens/freerecordedplayer.dart';
import 'package:careerapp/screens/freerecordedplayer2.dart';
import 'package:careerapp/screens/freeshortplayer.dart';
import 'package:careerapp/screens/freeplayer2.dart';
import 'package:careerapp/screens/freeplayer3.dart';
import 'package:careerapp/screens/freesolvedplayer.dart';
import 'package:careerapp/screens/mcq_list.dart';
import 'package:careerapp/screens/allusers.dart';
import 'package:careerapp/screens/shortnotes_list.dart';
import 'package:careerapp/screens/samplepapers_list.dart';
// import 'package:careerapp/screens/pdf_viewer.dart';
import 'package:careerapp/screens/live.dart';
import 'package:careerapp/screens/category.dart';
import 'package:careerapp/screens/freecategory.dart';
import 'package:careerapp/screens/paidcategory.dart';
import 'package:careerapp/screens/notification_screen.dart';
import 'package:careerapp/screens/youtube_player.dart';
import 'package:careerapp/screens/weeklytest.dart';
import 'package:careerapp/screens/results.dart';
import 'package:careerapp/screens/product_detail.dart';
import 'package:careerapp/screens/otp.dart';
import 'package:careerapp/screens/openurl.dart';
import 'package:careerapp/screens/dailyvideos_player.dart';
import 'package:careerapp/screens/organic_farming.dart';
import 'package:careerapp/screens/uniques_features.dart';
import 'package:careerapp/screens/upgrade_screen.dart';

import 'package:careerapp/screens/syllabus_update.dart';
import 'package:careerapp/screens/medical_tips.dart';
import 'package:careerapp/screens/apply_tc.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Initialize Notification Service
  await NotificationService.initialize();

  runApp(
    const OverlaySupport.global(
      child: MyApp(),
    ),
  );
}

class AppModel {
  final dynamic id; // Allow both int and String
  final String description;
  final String? image;
  final String? url;
  final String? createdAt;

  AppModel({
    required this.id,
    required this.description,
    this.image,
    this.url,
    this.createdAt,
  });

  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(
      id: json['id'], // Now it can accept both string and int
      description: json['description'],
      image: json['image'],
      url: json['url'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Keep the id as is, whether it’s String or int
      'description': description,
      'image': image,
      'url': url,
      'created_at': createdAt,
    };
  }
}

List<AppModel> appModelList = [];

Future<List<AppModel>> fetchAppModelData() async {
  const String url = "https://www.careerdefenceacademy.com/Api/getAppModels";

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> res = json.decode(response.body);
      print("Decoded Response: $res");

      if (res['status'] == 200 && res['data'] != null) {
        List<dynamic> rawList = res['data'];
        List<AppModel> appModels =
            rawList.map((item) => AppModel.fromJson(item)).toList();

        for (var model in appModels) {
          print(
              "✅ AppModel: ID=${model.id}, Desc=${model.description}, Image=${model.image}, CreatedAt=${model.createdAt}");
        }

        return appModels;
      } else {
        print("⚠️ No data or invalid status in response.");
        return [];
      }
    } else {
      print("❌ HTTP Error: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    print("❌ Exception while fetching app models: $e");
    return [];
  }
}

Future<void> showSequentialPopups(
    BuildContext context, List<AppModel> appModelList) async {
  int currentIndex = 0;

  if (appModelList.isEmpty) return;
  final dialogContext = navigatorKey.currentContext ?? context;

  // Show the first popup immediately
  await showAppModelPopup(dialogContext, appModelList[currentIndex]);

  Timer.periodic(const Duration(minutes: 3), (timer) async {
    currentIndex++;

    if (currentIndex < appModelList.length) {
      // Important: Use navigatorKey here if context becomes invalid
      BuildContext currentContext =
          navigatorKey.currentContext ?? dialogContext;

      await showAppModelPopup(currentContext, appModelList[currentIndex]);
    } else {
      timer.cancel(); // Stop the timer when all popups are shown
    }
  });
}

List<AppModel> getPopupsForTime(List<AppModel> appModelList) {
  final DateTime now = DateTime.now();
  List<AppModel> filteredList = [];

  // Assuming you want to filter based on `createdAt` field
  for (var model in appModelList) {
    final description = model.description.trim().toLowerCase();
    final image = model.image?.trim() ?? '';
    final url = model.url?.trim() ?? '';
    if (description == 'test' && image.isEmpty && url.isEmpty) {
      continue;
    }

    DateTime createdAt = DateTime.parse(model.createdAt ?? '');
    if (createdAt.isBefore(now)) {
      filteredList.add(model);
    }
  }

  return filteredList;
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final bool _isDialogVisible = false;
  int popupIndex = 0;
  late Timer popupTimer;
  bool _isLoggedIn = false;
  var user_name = "Guest\n";
  var user_email = "guest@gmail.com ";
  var user_phone = "----------";
  var class_name = "Guest";
  var user_id = '0';
  var userData;
// Theme.of(context).colorScheme.error

  var flag = false;
  final bool _showEnglishPopup = true;
  bool _isJoinReferenceDialogShown = false;
  List<AppModel> appModelList = [];
  int currentModelIndex = 0;

  final Color errorColor = Colors.redAccent;

  var students = [];

  List<Map<String, dynamic>> getMergedSeatData() {
    List<Map<String, dynamic>> mergedData = [];

    for (int i = 0; i < popupDataList.length; i++) {
      final category = popupCategories[i];
      final map = popupDataList[i];

      map.forEach((className, seats) {
        mergedData.add({
          'category': category,
          'className': className,
          'Ambala': seats['Ambala'] ?? '0',
          'Yamunanagar': seats['Yamunanagar'] ?? '0',
          'Patiala': seats['Patiala'] ?? '0',
        });
      });
    }

    return mergedData;
  }

  Future<void> maybeShowJoinOfferPopup() async {
    if (flag && !_isJoinReferenceDialogShown) {
      _isJoinReferenceDialogShown = true;
      // await _showJoinReferenceDialog(navigatorKey.currentContext!);
      await showJoinOfferPopup(navigatorKey.currentContext!);
    }
  }

  @override
  @override
  void initState() {
    super.initState();

    _initSetup();
  }

  void _playPopupSound() {
    final player = AudioPlayer();
    player.play(AssetSource('assets/noti.mp3')); // Add your sound
  }

  Future<void> _initSetup() async {
    subscribeTopic();
    _requestPermission();
    await getUserData();
    await checkAndUpdateSeatCounts();

    bool isLoggedIn = await CommonService.isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });

    /// ✅ DIRECT API CALL AND POPUP
    final models = await fetchAppModelData();

    if (models.isNotEmpty && mounted) {
      setState(() {
        appModelList = models;
      });

      // Filter data to show only relevant popups
      final filteredModels = getPopupsForTime(appModelList);

      // Call the function to show the popups every 3 minutes
      if (filteredModels.isNotEmpty) {
        showSequentialPopups(context, filteredModels);
      } else {
        print("No data to display for popups.");
      }
    }
  }

// ✅ Move this OUTSIDE of _initSetup()
  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUserData = prefs.getString('userData');
    if (rawUserData == null || rawUserData.trim().isEmpty) return;

    try {
      final decoded = json.decode(rawUserData);
      if (decoded is! Map<String, dynamic>) {
        await prefs.remove('userData');
        return;
      }
      userData = decoded;
      user_name = userData["user_name"]?.toString().toUpperCase() ?? '';
      user_email = userData["user_email"];
      user_id = userData["user_id"];
      user_phone = userData["user_phone"];
      class_name = userData["studyingin"];
      flag = true;
    } on FormatException {
      await prefs.remove('userData');
      flag = false;
    }
  }

  @override
  void dispose() {
    if (popupTimer.isActive) popupTimer.cancel();
    super.dispose();
  }

  void subscribeTopic() async {
    const topic = 'app_promotion';
    await messaging.subscribeToTopic(topic);
  }

  void _requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');
      try {
        var token = await messaging.getToken();
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('fcm_token', token.toString());
      } catch (e) {
        print('Unable to fetch FCM token after permission: $e');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('⚠️ User granted provisional permission');
    } else {
      print('❌ User declined permission');
    }
  }

  // 🔁 Decrease seats logic
  Future<void> checkAndUpdateSeatCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastCheckString = prefs.getString('last_seat_update');
    DateTime lastCheck = lastCheckString != null
        ? DateTime.tryParse(lastCheckString) ?? now
        : now;

    int saturdaysPassed = 0;
    for (DateTime d = lastCheck.add(const Duration(days: 1));
        d.isBefore(now);
        d = d.add(const Duration(days: 1))) {
      if (d.weekday == DateTime.saturday) saturdaysPassed++;
    }

    if (saturdaysPassed > 0) {
      for (var table in popupDataList) {
        for (var row in table.values) {
          row.updateAll((key, value) {
            int val =
                value.toLowerCase() == "full" ? 0 : int.tryParse(value) ?? 0;
            val = (val - saturdaysPassed).clamp(0, 999);
            return val == 0 ? "Full" : val.toString();
          });
        }
      }
      await prefs.setString('last_seat_update', now.toIso8601String());
    }
  }

  @override
  //   Widget build(BuildContext context) {
  //   return Sizer(
  //     builder: (context, orientation, deviceType) {
  //       return LayoutBuilder(
  //         builder: (context, constraints) {
  //           return OrientationBuilder(
  //             builder: (context, orientation) {
  //               return MaterialApp(
  //                 navigatorKey: navigatorKey,
  //                 debugShowCheckedModeBanner: false,
  //                 title: 'Career Defence School',
  //                 home: FutureBuilder(
  //                   future: CommonService.isLoggedIn(),
  //                   builder: (ctx, dataSnapshot) => const App(),
  //                 ),

  //               );
  //             },
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return OrientationBuilder(
            builder: (context, orientation) {
              SizeConfig().init(constraints, orientation);
              return MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                title: 'Career Defence School',
                builder: (context, child) {
                  final mediaQuery = MediaQuery.of(context);
                  return MediaQuery(
                    data: mediaQuery.copyWith(textScaler: TextScaler.noScaling),
                    child: child ?? const SizedBox.shrink(),
                  );
                },
                home: FutureBuilder(
                  future: CommonService.isLoggedIn(),
                  builder: (ctx, dataSnapshot) => const App(),
                  // builder: (ctx, dataSnapshot) =>
                  // (dataSnapshot.data == true) ? App() : LoginScreen(),
                ),
                routes: {
                  LiveScreen.routeName: (context) => const LiveScreen(),
                  CourseDetailsScreen.routeName: (context) =>
                      const CourseDetailsScreen(),
                  MycourseDetailsScreen.routeName: (context) =>
                      const MycourseDetailsScreen(),
                  MyCourses.routeName: (context) => const MyCourses(),
                  Allcourses.routeName: (context) => const Allcourses(),
                  Searchcourses.routeName: (context) => const Searchcourses(),
                  PlayerScreen.routeName: (context) => const PlayerScreen(),
                  FreePlayerScreen.routeName: (context) =>
                      const FreePlayerScreen(),
                  FreeRecordedScreen.routeName: (context) =>
                      const FreeRecordedScreen(),
                  FreeRecordedScreen2.routeName: (context) =>
                      const FreeRecordedScreen2(),
                  FreeShortScreen.routeName: (context) =>
                      const FreeShortScreen(),
                  FreeSolvedScreen.routeName: (context) =>
                      const FreeSolvedScreen(),
                  LoginScreen.routeName: (context) => const LoginScreen(),
                  McqList.routeName: (context) => const McqList(),
                  ShortnotesList.routeName: (context) => const ShortnotesList(),
                  SamplepapersList.routeName: (context) =>
                      const SamplepapersList(),
                  // PDFViewer.routeName: (context) => const PDFViewer(),
                  // PDFViewer2.routeName: (context) => const PDFViewer2(),
                  Category.routeName: (context) => const Category(),
                  Paidcategory.routeName: (context) => const Paidcategory(),
                  Freecategory.routeName: (context) => const Freecategory(),
                  NotificationScreen.routeName: (context) =>
                      const NotificationScreen(),
                  App.routeName: (context) => const App(),
                  Youtubevideo.routeName: (context) => const Youtubevideo(),
                  Weeklytest.routeName: (context) => const Weeklytest(),
                  ParentsFaqs.routeName: (context) => const ParentsFaqs(),
                  OrganicFarming.routeName: (context) => const OrganicFarming(),
                  Super50.routeName: (context) => const Super50(),
                  Productdetail.routeName: (context) => const Productdetail(),
                  Results.routeName: (context) => const Results(),
                  OTPPage.routeName: (context) => const OTPPage(),
                  FreePlayerScreen2.routeName: (context) =>
                      const FreePlayerScreen2(),
                  FreePlayerScreen3.routeName: (context) =>
                      const FreePlayerScreen3(),
                  OpenUrl.routeName: (context) => const OpenUrl(),
                  DailyVideosPlayer.routeName: (context) =>
                      const DailyVideosPlayer(),
                  Dashboard.routeName: (context) => const Dashboard(),
                  StudentDetails.routeName: (context) => const StudentDetails(),
                  StudentWeeklyReport.routeName: (context) =>
                      const StudentWeeklyReport(),
                  UniqueFeaturesPage.routeName: (context) =>
                      const UniqueFeaturesPage(),
                  MedicalTipsPage.routeName: (context) =>
                      const MedicalTipsPage(),
                  UpgradeFeatures.routeName: (context) =>
                      const UpgradeFeatures(),

                  TransferCertificateScreen.routeName: (context) =>
                      const TransferCertificateScreen(),
                  AllUsersScreen.routeName: (context) => const AllUsersScreen(),
                  AdminGatePassScreen.routeName: (context) =>
                      const AdminGatePassScreen(),
                  StudentMedicalReport.routeName: (context) =>
                      const StudentMedicalReport(),
                  StaffTraining.routeName: (context) => const StaffTraining(),
                  StudentCanteenReport.routeName: (context) =>
                      const StudentCanteenReport(),
                  SpokenEnglish.routeName: (context) => const SpokenEnglish(),
                  OurFunctions.routeName: (context) => const OurFunctions(),
                  StudentFeedback.routeName: (context) =>
                      const StudentFeedback(),
                  StudentCounselling.routeName: (context) =>
                      const StudentCounselling(),
                  StudentStudyReport.routeName: (context) =>
                      const StudentStudyReport(),
                  StudentFineCharges.routeName: (context) =>
                      const StudentFineCharges(),
                  StudentFeesDetail.routeName: (context) =>
                      const StudentFeesDetail(),
                  StudentActivityReport.routeName: (context) =>
                      const StudentActivityReport(),
                  StudentWeeklyActivity.routeName: (context) =>
                      const StudentWeeklyActivity(),
                  StudentCallingReport.routeName: (context) =>
                      const StudentCallingReport(),
                  StudentReferences.routeName: (context) =>
                      const StudentReferences(),
                  StudentFreePaidForms.routeName: (context) =>
                      const StudentFreePaidForms(),
                  StudentRequirements.routeName: (context) =>
                      const StudentRequirements(),
                  StudentSearch.routeName: (context) => const StudentSearch(),
                  StudentAttendanceReport.routeName: (context) =>
                      const StudentAttendanceReport(),
                  StudentHostelHygiene.routeName: (context) =>
                      const StudentHostelHygiene(),
                  ConsultantLeads.routeName: (context) =>
                      const ConsultantLeads(),
                  StudentReportCard.routeName: (context) =>
                      const StudentReportCard(),
                  StudentStudyWeeklyTest.routeName: (context) =>
                      const StudentStudyWeeklyTest(),
                  WeeklyCopyStampingMain.routeName: (context) =>
                      const WeeklyCopyStampingMain(),
                  WeeklyCopyStamping.routeName: (context) =>
                      const WeeklyCopyStamping(),
                  Leads.routeName: (context) => const Leads(),
                  LeadReferences.routeName: (context) => const LeadReferences(),
                  CertificationCourses.routeName: (context) =>
                      const CertificationCourses(),
                  SyllabusUpdate.routeName: (context) => const SyllabusUpdate(),
                  ScienceExperiment.routeName: (context) =>
                      const ScienceExperiment(),
                  StaffSalary.routeName: (context) => const StaffSalary(),
                  MedicalCounsellingReport.routeName: (context) =>
                      const MedicalCounsellingReport(),
                },
              );
            },
          );
        },
      );
    });
  }
}

// 🧮 DYNAMIC SEAT DATA
List<Map<String, Map<String, String>>> popupDataList = [
  {
    "Nursery": {"Ambala": "Full", "Yamunanagar": "6", "Patiala": "5"},
    "LKG": {"Ambala": "Full", "Yamunanagar": "4", "Patiala": "5"},
    "1st": {"Ambala": "Full", "Yamunanagar": "6", "Patiala": "8"},
    "2nd": {"Ambala": "Full", "Yamunanagar": "5", "Patiala": "6"},
    "3rd": {"Ambala": "Full", "Yamunanagar": "4", "Patiala": "4"},
    "4th": {"Ambala": "Full", "Yamunanagar": "5", "Patiala": "6"},
  },
  {
    "5th": {"Ambala": "Full", "Yamunanagar": "5", "Patiala": "6"},
    "6th": {"Ambala": "Full", "Yamunanagar": "2", "Patiala": "3"},
    "7th": {"Ambala": "Full", "Yamunanagar": "3", "Patiala": "4"},
    "8th": {"Ambala": "Full", "Yamunanagar": "3", "Patiala": "5"},
  },
  {
    "9th": {"Ambala": "Full", "Yamunanagar": "5", "Patiala": "3"},
    "10th": {"Ambala": "Full", "Yamunanagar": "3", "Patiala": "4"},
    "11th": {"Ambala": "Full", "Yamunanagar": "3", "Patiala": "3"},
    "12th": {"Ambala": "Full", "Yamunanagar": "3", "Patiala": "4"},
  },
];

List<String> popupCategories = ["", "", ""];

List<Widget> get popupTables {
  return List.generate(popupDataList.length, (i) {
    return buildEnhancedSeatPopup(popupCategories[i], popupDataList[i]);
  });
}

// 🪧 Seat Popup

Widget buildEnhancedSeatPopup(
    String category, Map<String, Map<String, String>> data) {
  final DateTime now = DateTime.now();
  final int daysToSaturday = (6 - now.weekday + 7) % 7;
  final nextSaturday = now.add(Duration(days: daysToSaturday));
  final formattedDate = DateFormat('dd MMM, yyyy').format(nextSaturday);

  return Container(
    constraints: const BoxConstraints(maxHeight: 500),
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3366FF), Color(0xFF00CCFF)],
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 25,
          offset: const Offset(0, 10),
          spreadRadius: 5,
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with shimmer effect
//         ShimmerHeader(
//   category: category,
//   formattedDate: formattedDate,
// ),

        // Content
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Table header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  // decoration: BoxDecoration(
                  //   color: Colors.white.withOpacity(0.2),
                  //   borderRadius: BorderRadius.only(
                  //     topLeft: Radius.circular(12),
                  //     topRight: Radius.circular(12)
                  //   ),
                  // ),
                  child: Row(
                    children: [
                      _buildHeaderCell("Class", 2),
                      _buildHeaderCell("Ambala", 1),
                      _buildHeaderCell("Yamunanagar", 1),
                      _buildHeaderCell("Patiala", 1),
                    ],
                  ),
                ),

                // Table rows with staggered animation
                ...data.entries.map((entry) {
                  final className = entry.key;
                  final seats = entry.value;
                  final index = data.keys.toList().indexOf(className);

                  return AnimatedTableRow(
                    index: index,
                    child: Container(
                      decoration: BoxDecoration(
                        color: index.isEven
                            ? Colors.white.withOpacity(0.1)
                            : Colors.white.withOpacity(0.15),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildCell(className, 2, isClass: true),
                          _buildAnimatedSeatCell(seats["Ambala"] ?? "Full", 1),
                          _buildAnimatedSeatCell(
                              seats["Yamunanagar"] ?? "0", 1),
                          _buildAnimatedSeatCell(seats["Patiala"] ?? "0", 1),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 16),

                // "Seats filling fast" alert
                // FlashingText(
                //   text: "Hurry Up! Limited Seats! Call Now ☎",
                //   style: TextStyle(
                //     color: Colors.yellow,
                //     fontWeight: FontWeight.bold,
                //     fontSize: 14,
                //     shadows: [
                //       Shadow(
                //         color: Colors.black26,
                //         blurRadius: 5,
                //         offset: Offset(0, 2),
                //       ),
                //     ],
                //   ),
                // ),

                const SizedBox(height: 10),

                // Last date info
//                 Container(
//                   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.calendar_today, color: Colors.white, size: 18),
//                       SizedBox(width: 8),
//                      Text(
//   "Last Date: $formattedDate",
//   style: TextStyle(
//     color: Colors.white.withOpacity(0.85),
//     fontWeight: FontWeight.w500,
//     fontSize: 11, // Smaller font
//     fontStyle: FontStyle.italic,
//   ),
// ),

//                     ],
//                   ),
//                 ),

                const SizedBox(height: 6),

                // Auto-close countdown
                // CountdownTimer(seconds: 20),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// Shimmer effect for header
class ShimmerHeader extends StatefulWidget {
  final String category;
  final String formattedDate; // <-- add this

  const ShimmerHeader({
    Key? key,
    required this.category,
    required this.formattedDate, // <-- add this
  }) : super(key: key);

  @override
  _ShimmerHeaderState createState() => _ShimmerHeaderState();
}

class _ShimmerHeaderState extends State<ShimmerHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📬 Foreground message received: ${message.notification?.title}");
      // You can show an overlay or dialog here
      showSimpleNotification(
        Text(message.notification?.title ?? "No Title"),
        subtitle: Text(message.notification?.body ?? "No Body"),
        background: Colors.green,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(1.0 + _animation.value, 0.0),
              end: Alignment(-1.0 + _animation.value, 0.0),
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: child,
        );
      },
      // child: Row(
      //   children: [
      //     Container(
      //       padding: EdgeInsets.all(10),
      //       decoration: BoxDecoration(
      //         color: Colors.white.withOpacity(0.2),
      //         shape: BoxShape.circle,
      //       ),
      //       child: Icon(Icons.event_seat_rounded, color: Colors.white, size: 28),
      //     ),
      //     SizedBox(width: 16),
      //     Expanded(
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           // Text(
      //           //   "${widget.category} Seats Availability",
      //           //   style: TextStyle(
      //           //     color: Colors.white,
      //           //     fontWeight: FontWeight.bold,
      //           //     fontSize: 16,
      //           //     letterSpacing: 0.5,
      //           //   ),
      //           // ),
      //           //  Text(
      //           //         "Last Date: $formattedDate",
      //           //         style: TextStyle(
      //           //           color: Colors.white,
      //           //           fontWeight: FontWeight.bold,
      //           //           fontSize: 14,
      //           //         ),
      //           //       ),
      //           SizedBox(height: 4),
      //           // Text(
      //           //   "Real-time seat status across locations",
      //           //   style: TextStyle(
      //           //     color: Colors.white.withOpacity(0.8),
      //           //     fontSize: 12,
      //           //   ),
      //           // ),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}

// Animated table row with staggered entrance
class AnimatedTableRow extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedTableRow({Key? key, required this.child, required this.index})
      : super(key: key);

  @override
  _AnimatedTableRowState createState() => _AnimatedTableRowState();
}

class _AnimatedTableRowState extends State<AnimatedTableRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuart,
      ),
    );

    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _animation.value)),
          child: Opacity(
            opacity: _animation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// Flashing text animation
class FlashingText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const FlashingText({Key? key, required this.text, required this.style})
      : super(key: key);

  @override
  _FlashingTextState createState() => _FlashingTextState();
}

class _FlashingTextState extends State<FlashingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Opacity(
            opacity: _animation.value,
            child: Text(
              widget.text,
              style: widget.style,
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}

// Countdown timer with animation
class CountdownTimer extends StatefulWidget {
  final int seconds;

  const CountdownTimer({Key? key, required this.seconds}) : super(key: key);

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late int _remainingSeconds;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.seconds;

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          _controller.reset();
          _controller.forward();
        } else {
          _timer.cancel();
        }
      });
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          const Text(
            "Auto-closing in ",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Circular progress indicator
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      value: _animation.value,
                      strokeWidth: 2,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _remainingSeconds <= 3 ? Colors.red : Colors.white,
                      ),
                    ),
                  ),
                  // Seconds text
                  Text(
                    "$_remainingSeconds",
                    style: TextStyle(
                      color: _remainingSeconds <= 3 ? Colors.red : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget _buildHeaderCell(String text, int flex) => Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );

Widget _buildCell(String text, int flex, {bool isClass = false}) => Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isClass ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
          textAlign: isClass ? TextAlign.left : TextAlign.center,
        ),
      ),
    );

Widget _buildAnimatedSeatCell(String text, int flex) {
  bool isFull = text.toLowerCase() == "full";
  int seatCount = isFull ? 0 : int.tryParse(text) ?? 0;

  Color statusColor = isFull
      ? Colors.red.withOpacity(0.8)
      : seatCount <= 3
          ? Colors.orange.withOpacity(0.8)
          : Colors.green.withOpacity(0.8);

  // Add pulsing animation for low availability
  bool isLowAvailability = !isFull && seatCount <= 3 && seatCount > 0;

  return Expanded(
    flex: flex,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: isLowAvailability
          ? PulsatingContainer(
              color: statusColor,
              child: _buildSeatContent(text),
            )
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildSeatContent(text),
            ),
    ),
  );
}

Widget _buildSeatContent(String text) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        text.toLowerCase() == "full"
            ? Icons.do_not_disturb
            : int.tryParse(text) == 0
                ? Icons.cancel_outlined
                : int.tryParse(text)! <= 3
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
        color: Colors.white,
        size: 12,
      ),
      const SizedBox(width: 4),
      Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    ],
  );
}

// Pulsating container for low availability seats
class PulsatingContainer extends StatefulWidget {
  final Widget child;
  final Color color;

  const PulsatingContainer({Key? key, required this.child, required this.color})
      : super(key: key);

  @override
  _PulsatingContainerState createState() => _PulsatingContainerState();
}

class _PulsatingContainerState extends State<PulsatingContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.5 * _animation.value),
                blurRadius: 8 * _animation.value,
                spreadRadius: 2 * (_animation.value - 0.8),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// Enhanced popup show function with animations
Future<void> showSeatAvailabilityPopup(BuildContext context) async {
  final overlayContext = context;
  bool dialogStillOpen = true;

  showGeneralDialog(
    context: overlayContext,
    barrierDismissible: true,
    barrierLabel: "Seat Availability",
    barrierColor: Colors.black.withOpacity(0.8),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) => Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.95,
            ),
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              },
                            ),
                          ],
                        ),
                        _buildEnhancedHeader(context, "Seat Availability"),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildWarningBanner(),
                              _buildEnhancedHeaderRow(),
                              const SizedBox(height: 8),
                              ...popupDataList
                                  .expand((data) => data.entries)
                                  .map((entry) => _buildEnhancedSeatRow(
                                      entry.key, entry.value))
                                  .toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    transitionBuilder: (_, anim, __, child) {
      return AnimatedBuilder(
        animation: anim,
        builder: (_, child) {
          return Transform.scale(
            scale: Curves.easeOutBack.transform(anim.value),
            child: Opacity(
              opacity: anim.value,
              child: child,
            ),
          );
        },
        child: child,
      );
    },
  );

  // Safe auto-close after 20 seconds only if dialog is still open
  // await Future.delayed(Duration(seconds: 20));
  // if (dialogStillOpen && Navigator.of(overlayContext, rootNavigator: true).canPop()) {
  //   Navigator.of(overlayContext, rootNavigator: true).pop();
  // }
}

Widget _buildEnhancedHeader(BuildContext context, String title) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          offset: Offset(0, 4),
          blurRadius: 8,
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.event_seat_rounded,
          color: Colors.white,
          size: 18,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    ),
  );
}

Widget _buildEnhancedHeaderRow() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        _enhancedHeaderCell('Class', 2, isFirst: true),
        _enhancedHeaderCell('Ambala', 1),
        _enhancedHeaderCell('Yamunanagar', 1),
        _enhancedHeaderCell('Patiala', 1, isLast: true),
      ],
    ),
  );
}

Widget _enhancedHeaderCell(String text, int flex,
    {bool isFirst = false, bool isLast = false}) {
  return Expanded(
    flex: flex,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          right: !isLast
              ? const BorderSide(color: Colors.white30, width: 1)
              : BorderSide.none,
          left: isFirst ? BorderSide.none : BorderSide.none,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
        textAlign: flex == 2 ? TextAlign.left : TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}

Widget _buildEnhancedSeatRow(String className, Map<String, String> seats) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {}, // Optional tap action
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  className,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              _enhancedSeatCell(seats["Ambala"]),
              _enhancedSeatCell(seats["Yamunanagar"]),
              _enhancedSeatCell(seats["Patiala"]),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _enhancedSeatCell(String? value) {
  bool isFull = value == "Full";
  Color cellColor = isFull
      ? const Color(0xFFFF5252).withOpacity(0.9)
      : const Color(0xFF66BB6A).withOpacity(0.9);

  return Expanded(
    flex: 1,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: cellColor.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isFull)
            const Icon(Icons.do_not_disturb, color: Colors.white, size: 10)
          else
            const Icon(Icons.check_circle, color: Colors.white, size: 10),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value ?? "-",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildWarningBanner() {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.7, end: 1.0),
    duration: const Duration(milliseconds: 800),
    curve: Curves.easeInOut,
    builder: (context, value, child) {
      return Transform.scale(
        scale: value,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  "Hurry Up! Limited Seats! Call Now ☎",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildEnhancedCountdownTimer(int seconds) {
  return StatefulBuilder(
    builder: (context, setState) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.timer,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 10),
            const Text(
              "Closing in:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$seconds seconds",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Widget _buildActionButton(BuildContext context) {
//   return Container(
//     width: double.infinity,
//     child: ElevatedButton(
//       onPressed: () {
//         Navigator.of(context).pop();
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Color(0xFF4CAF50),
//         foregroundColor: Colors.white,
//         padding: EdgeInsets.symmetric(vertical: 16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         elevation: 4,
//       ),
//       child: Text(
//         "Register Now",
//         style: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           letterSpacing: 1.0,
//         ),
//       ),
//     ),
//   );
// }

// Example usage
// void main() {
//   runApp(MaterialApp(
//     home: Scaffold(
//       appBar: AppBar(title: Text('Seat Availability Demo')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             final Map<String, Map<String, String>> sampleData = {
//               "Premium": {
//                 "Ambala": "2",
//                 "Yamunanagar": "5",
//                 "Patiala": "Full",
//               },
//               "Standard": {
//                 "Ambala": "Full",
//                 "Yamunanagar": "3",
//                 "Patiala": "7",
//               },
//               "Economy": {
//                 "Ambala": "8",
//                 "Yamunanagar": "Full",
//                 "Patiala": "1",
//               },
//             };

//             final popupTables = [
//               buildEnhancedSeatPopup("VIP", sampleData),
//             ];

//             showSeatAvailabilityPopup(
//               navigatorKey.currentContext!,
//               0
//             );
//           },
//           child: Text('Show Seat Availability'),
//         ),
//       ),
//     ),
//     navigatorKey: navigatorKey,
//   ));
// }

Future<void> showCombinedSeatPopup(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3366FF), Color(0xFF00CCFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 80, left: 16, right: 16, bottom: 20),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildWarningBanner(),
                    const SizedBox(height: 8),
                    _buildSingleLastDateBanner(),
                    const SizedBox(height: 16),

                    // ⬇️ One Combined Table Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 8),
                      child: Column(
                        children: [
                          _buildEnhancedHeaderRow(),
                          const SizedBox(height: 8),
                          ...popupDataList
                              .expand((data) => data.entries)
                              .map((entry) {
                            return _buildEnhancedSeatRow(
                                entry.key, entry.value);
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ❌ Close button
              Positioned(
                right: 10,
                top: 10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 22),
                  ),
                ),
              ),

              // 🪑 Title
              const Positioned(
                left: 20,
                top: 20,
                child: Row(
                  children: [
                    Icon(Icons.event_seat, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Seat Availability Update',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  // await maybeShowJoinOfferPopup();
  await showJoinOfferPopup(navigatorKey.currentContext!);
}

Widget _buildSingleLastDateBanner() {
  final DateTime now = DateTime.now();
  final int daysToSaturday = (6 - now.weekday + 7) % 7;
  final nextSaturday = now.add(Duration(days: daysToSaturday));
  final formattedDate = DateFormat('dd MMM, yyyy').format(nextSaturday);

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.calendar_today, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(
          "Last Date: $formattedDate",
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontWeight: FontWeight.w500,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    ),
  );
}

Future<void> showGeneralNoticePopup(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF283E51), Color(0xFF485563)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications_active, color: Colors.white),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "GENERAL NOTICE FOR PARENTS",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(color: Colors.white54),
                const SizedBox(height: 10),
                Text(
                  '''
📌 Important Dates & Instructions
Career Defence School – Parent Notice

Dear Parents,

Please take note of the following important academic dates and updates:

🗓 Parent-Teacher Meeting (PTM):
	•	23 Aug 2025 — Classes Nursery to 6th
	•	23 Aug 2025 — Classes 7th to 12th
	•	For parents unable to attend on these dates, an online PTM will be held on 23 Aug 2025.

📝 Unit Test 2:
	•	21 July to 28 July 2025

🌞 Summer Holidays:
	•	25 May to 11 July 2025

⚠ Important Notes:
	•	Holidays are optional; the school will remain open.
	•	Zoom classes will continue daily from 9:00 AM to 2:00 PM during holidays.
	•	Attendance during online sessions is mandatory.
	•	Students admitted in May will not have holidays or PTM.
	•	These students will attend sessions focused on pending old syllabus and competitive exam sample papers for thorough revision and syllabus completion during the holidays.
	•	For other students, participation in holidays and PTM is optional.
	•	PT 1 Results will be provided later online. Parents are requested not to rush for the result leaflet during PTM.
	•	Online classes for Classes 3 to 9 will focus on competitive coaching and not regular curriculum. Only Board classes will have Maths and Science books/notebooks permitted.
	•	Study materials will be provided through class teacher broadcasts or the school portal.
	•	Administration welcomes any doubt clearance mails or feedback from parents.
	•	Self-prepared study projects and reports by students will be highly appreciated.

For any queries or support, please contact:
Ms Nancy Garg
Senior Counsellor
Career Group
Phone: +91 70273 33764

We kindly request all parents to support us by ensuring your child’s regular attendance and active participation throughout the summer academic schedule.

Thank you for your cooperation.

— Management
Career Defence School
                  ''',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> showHindiNoticePopup(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF283E51), Color(0xFF485563)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications_active, color: Colors.white),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "महत्वपूर्ण सूचना सभी अभिभावकों के लिए",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(color: Colors.white54),
                const SizedBox(height: 10),
                Text(
                  '''
       📌 महत्वपूर्ण तिथियाँ और निर्देश
करियर डिफेंस स्कूल – अभिभावक सूचना

प्रिय अभिभावकों,

कृपया निम्नलिखित महत्वपूर्ण शैक्षणिक तिथियाँ और सूचनाएँ ध्यान दें:

🗓 अभिभावक-शिक्षक बैठक (PTM):
	•	24 मई 2025 — नर्सरी से 6वीं कक्षा तक
	•	25 मई 2025 — 7वीं से 12वीं कक्षा तक
	•	जो अभिभावक इन तिथियों पर उपस्थित नहीं हो सकेंगे, उनके लिए 26 मई 2025 (सोमवार) को ऑनलाइन PTM आयोजित किया जाएगा।

📝 यूनिट टेस्ट 1:
	•	17 मई से 23 मई 2025 तक

🌞 ग्रीष्मकालीन छुट्टियाँ:
	•	25 मई से 11 जुलाई 2025 तक

⚠ महत्वपूर्ण नोट्स:
	•	छुट्टियाँ वैकल्पिक हैं; स्कूल खुला रहेगा।
	•	छुट्टियों के दौरान रोजाना सुबह 9:00 बजे से दोपहर 2:00 बजे तक ज़ूम क्लासेस चलती रहेंगी।
	•	ऑनलाइन कक्षाओं में उपस्थिति अनिवार्य है।
	•	मई में जिन बच्चों का एडमिशन हुआ है, उनके लिए छुट्टियाँ और PTM लागू नहीं होंगे।
	•	इन बच्चों को छुट्टियों में पुराना पेंडिंग सिलेबस और प्रतियोगी परीक्षा के सैंपल पेपर्स के माध्यम से अच्छी रिवीजन और सिलेबस पूरा करने का अवसर दिया जाएगा।
	•	अन्य बच्चों के लिए छुट्टियाँ और PTM वैकल्पिक हैं।
	•	PT 1 के परिणाम बाद में ऑनलाइन उपलब्ध कराए जाएंगे। अभिभावकों से अनुरोध है कि वे PTM के दौरान परिणाम की पर्ची के लिए जल्दबाजी न करें।
	•	कक्षा 3 से 9 तक की ऑनलाइन कक्षाएं प्रतियोगी कोचिंग पर आधारित होंगी, न कि सामान्य पाठ्यक्रम पर। केवल बोर्ड कक्षाओं के लिए गणित और विज्ञान की किताबें/कॉपी की अनुमति होगी।
	•	अध्ययन सामग्री कक्षा शिक्षक के प्रसारण या स्कूल पोर्टल के माध्यम से प्रदान की जाएगी।
	•	प्रशासन किसी भी प्रश्न या फीडबैक के लिए ईमेल के माध्यम से संपर्क करने का स्वागत करता है।
	•	छात्रों द्वारा स्वयं तैयार किए गए अध्ययन प्रोजेक्ट और रिपोर्ट को विशेष सराहना दी जाएगी।

किसी भी प्रश्न या सहायता के लिए संपर्क करें:
सुश्री नैन्सी गर्ग
सीनियर काउंसलर
करियर ग्रुप
फोन: +91 70273 33764

हम सभी अभिभावकों से अनुरोध करते हैं कि वे अपने बच्चों की नियमित उपस्थिति और सक्रिय भागीदारी सुनिश्चित करें।

आपके सहयोग के लिए धन्यवाद।

— प्रबंधन
करियर डिफेंस स्कूल
                          ''',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> showImportantSchedulePopupEnglish(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF314755), Color(0xFF26a0da)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.white),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Important Academic Schedule",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(color: Colors.white54),
                const SizedBox(height: 10),
                Text(
                  '''
📌 Parent-Teacher Meetings (PTM)
- Every 2 months (compulsory attendance)
- Junior Wing (Nursery to 7th): 24 May
- Senior Wing (8th to 12th): 25 May

📌 Summer Vacations:
- 26 May to 11 June

📌 Dropping Date after Vacations:
- Junior Wing: 12 July
- Senior Wing: 13 July

📌 School Schedule:
- Open 365 days. Holidays optional, based on parents’ decision.

📌 Online Classes:
- Compulsory from 9:00 AM to 2:00 PM daily.
                  ''',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> showAppModelPopup(BuildContext context, AppModel model) async {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: model.image != null
                ? Image.network(
                    model.image ?? "", // Ensure this URL is correct
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  model.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Date: ${model.createdAt}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (model.url != null &&
                        await canLaunchUrl(Uri.parse(model.url!))) {
                      await launchUrl(Uri.parse(model.url!));
                    }
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text("Open Link"),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> showJoinOfferPopup(BuildContext context) async {
  final DateTime now = DateTime.now();
  final int daysToSaturday = (6 - now.weekday + 7) % 7;
  final nextSaturday = now.add(Duration(days: daysToSaturday));
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(2.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.campaign, color: Colors.black, size: 20.sp),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      "Join & Earn Reference Admissions Offer",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              _buildOfferRow(
                icon: Icons.people_alt_outlined,
                text: "For 5 Admissions in Session",
                highlight: "Fees Half",
              ),
              Divider(height: 2.h),
              _buildOfferRow(
                icon: Icons.star_border_rounded,
                text: "For 10 Admissions in Session",
                highlight: "Fees Free",
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Icon(Icons.timer_outlined, color: Colors.black, size: 12.sp),
                  SizedBox(width: 1.w),
                  Text(
                    "Offer Last Date: ${DateFormat('dd MMM yyyy').format(nextSaturday)}",
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildOfferRow(
    {required IconData icon, required String text, required String highlight}) {
  return Row(
    children: [
      Icon(icon, color: Colors.black, size: 18),
      const SizedBox(width: 10),
      Expanded(
        child: RichText(
          text: TextSpan(
            text: '$text ',
            style: const TextStyle(color: Colors.black87, fontSize: 13),
            children: [
              TextSpan(
                text: highlight,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
