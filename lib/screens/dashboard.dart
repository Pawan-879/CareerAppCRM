import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:careerapp/screens/super50.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:careerapp/screens/mess_menu.dart';
import 'package:careerapp/screens/school_fee.dart';
import 'package:careerapp/screens/junior_wing.dart';
import 'package:careerapp/screens/cctv_cameras.dart';
import 'package:careerapp/screens/nda_training.dart';
import 'package:careerapp/screens/parents_faqs.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:careerapp/screens/openurl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:careerapp/screens/student_details.dart';
import 'package:careerapp/screens/student_results.dart';
import 'package:careerapp/screens/educational_trip.dart';
import 'package:careerapp/screens/mycourses_screen.dart';
import 'package:careerapp/screens/science_experiment.dart';
import 'package:careerapp/screens/student_references.dart';
import 'package:careerapp/screens/student_fees_detail.dart';
import 'package:careerapp/screens/student_fine_charges.dart';
import 'package:careerapp/screens/student_study_report.dart';
import 'package:careerapp/screens/certification_courses.dart';
import 'package:careerapp/screens/daily_sports_activity.dart';
import 'package:careerapp/screens/student_weekly_report.dart';
import 'package:careerapp/screens/student_calling_report.dart';
import 'package:careerapp/screens/student_canteen_report.dart';
import 'package:careerapp/screens/syllabus_update.dart';
import 'package:careerapp/screens/student_import_updates.dart';
import 'package:careerapp/screens/student_medical_report.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:careerapp/screens/uniques_features.dart';
import 'package:flutter/services.dart';

class Dashboard extends StatefulWidget {
  static const routeName = '/dashboard';

  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class DigitalStudentCard extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const DigitalStudentCard({
    Key? key,
    required this.studentData,
  }) : super(key: key);

  @override
  State<DigitalStudentCard> createState() => _DigitalStudentCardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  var data;
  var user = {};
  var full_name = "Loading...";
  var father_name = "";
  var class_name = "";
  var section = "";
  var location = "";
  var due_fee = "";
  var batch = "...";
  var dateofjoining = "";
  var balance = "0";
  var dob = "";
  var form1 = 0;
  var pocket_money = "0";
  var mobile = "";
  var student_type = "";
  var due_date = "-";
  var staff_name = '';
  var staff_mobile = '';
  var data7 = [];
  var due_fees = '0';
  var profile_pic = "";
  var email = "";
  var student_status = "";
  var created = "";
  bool _isAlertVisible = true;
  var flag_recorded_class = false;
  String feeTitle = "Due Fee";
  late DateTime nextSaturday;
  late DateTime nextSunday;
  String class_teacher_name = '';
  String class_teacher_mobile = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final bool _isDueFeesVisible = true;
  final List<String> _announcements = [
    "Welcome to Career Defence School Dashboard",
    "New session admissions open for 2026-27",
    "Special discount on early fee payment",
    "Join our Super 50 program for enhanced learning"
  ];

  // Define color scheme for the app
  static const Color primaryColor = Color(0xFF1565C0);
  static const Color secondaryColor = Color(0xFF42A5F5);
  static const Color accentColor = Color(0xFF64B5F6);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF2A2E48);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color errorColorDark =
      Color(0xFFD32F2F); // darker shade manually set
  static const Color successColorDark = Color(0xFF388E3C);
  static const Color warningColorDark = Color(0xFFF57C00);

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
    // Show reference pop-up after short delay
// Future.delayed(Duration(seconds: 2), () {
//   _showJoinReferenceDialog();
// });

    // Hide alert after 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      setState(() {
        _isAlertVisible = false;
      });
    });

    // Calculate next Saturday
    DateTime now = DateTime.now();
    int daysToSaturday = (DateTime.saturday - now.weekday) % 7;
    nextSaturday = now.add(Duration(days: daysToSaturday));

    // Load data when widget is initialized
    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)?.settings.arguments;
      final userId = data["id"];
      print("User ID: $userId");

      loadStudentData(userId);
      loadFreePaidForms(userId);
      getData(userId);

      setState(() {}); // Update UI after data loads if needed
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  loadStudentData(id) async {
    var res = await ApiService.getMethod3("/getStudentDetail?user_id=" + id);
    // print(res.body);

    dynamic d = jsonDecode(res.body);

    user = d["data"];
    if (user["class_for"] != null &&
        user["section"] != null &&
        user["school_id"] != null) {
      loadClassTeacher(
          user["class_for"], user["section"], user["school_id"].toString());
    }

    print(user);
    setState(() {
      full_name = user["first_name"];
      if (user["last_name"] != null) {
        full_name += " ${user["last_name"]}";
      }
      student_type = user["student_type"];
      student_status = user["student_status"];
      email = user["email"];
      father_name = user["father_name"].toString();
      if (user["class_for"] != null && user["class_for"] != '') {
        class_name = user["class_for"];
      }
      if (user["section"] != null && user["section"] != '') {
        section = user["section"];
      }

      if (class_name == "Class 3rd" ||
          class_name == "Class 4th" ||
          class_name == "Class 5th" ||
          class_name == "Class 6th" ||
          class_name == "Class 7th" ||
          class_name == "Class 8th" ||
          class_name == "Class 9th") {
        flag_recorded_class = true;
      }

      if (user["profile_pic"] != null) profile_pic = user["profile_pic"];
      if (user["city"] != null) location = user["city"];
      if (user["state"] != null) location += "(" + user["state"] + ")";
      if (user["balance"] != null) {
        balance = user["balance"];
      }
      if (user["mobile"] != null) {
        mobile = user["mobile"];
      }
      if (user["pocket_money"] != null) {
        pocket_money = user["pocket_money"];
      }
      if (user["created"] != null) {
        created = user["created"];

        DateTime joinDate = DateTime.tryParse(created) ?? DateTime.now();
        DateTime now = DateTime.now();

        Duration diff = now.difference(joinDate);

        int totalDays = diff.inDays;
        int years = (totalDays ~/ 365);
        int months = ((totalDays % 365) ~/ 30);
        int days = (totalDays % 30);

        if (years > 0) {
          created =
              "$years year${years > 1 ? 's' : ''} ${months > 0 ? '$months month${months > 1 ? 's' : ''}' : ''}";
        } else if (months > 0) {
          created =
              "$months month${months > 1 ? 's' : ''} ${days > 0 ? '$days day${days > 1 ? 's' : ''}' : ''}";
        } else {
          created = "$days day${days > 1 ? 's' : ''}";
        }
      }

      if (user["batch"] != null) {
        batch = "Batch: ${user["batch"]}";
      }

      if (user["doj"] != null) {
        dateofjoining =
            DateFormat('dd MMM yyyy').format(DateTime.parse(user["doj"]));
      }
      if (user["dob"] != null) {
        dob = DateFormat('dd MMM yyyy').format(DateTime.parse(user["dob"]));
      }
      if (user["due_date"] != null) {
        due_date =
            DateFormat('dd MMM yyyy').format(DateTime.parse(user["due_date"]));
      }
    });
  }

  getData(id) async {
    var res = await ApiService.getMethod3("/getFeeDetails?user_id=" + id);
    print(res.body);
    dynamic d = jsonDecode(res.body);
    data7 = d["data"];

    if (data7.isNotEmpty) {
      double totalFees =
          double.tryParse(data7[0]["total_fees"]?.toString() ?? "0") ?? 0;
      double dueFees =
          double.tryParse(data7[0]["balance"]?.toString() ?? "0") ?? 0;

      if (dueFees > 0) {
  due_fees = dueFees.toStringAsFixed(2);
  feeTitle = "Due Fee 2025-26";
} else {
  due_fees = "0.00"; // ✅ correct fix
  feeTitle = "No Due";
}

      if (dueFees == 0 || due_fees == "0.00") {
        feeTitle = "Next Session Fee 2026-27";
      } else {
        feeTitle = "Due Fee 2025-26";
      }

      due_date = data7[0]["due_date"] != null && data7[0]["due_date"] != ''
          ? DateFormat('dd MMM yyyy')
              .format(DateTime.parse(data7[0]["due_date"]))
          : '';

      setState(() {});

      if ((double.tryParse(due_fees) ?? 0) > 0) {
  Future.delayed(Duration.zero, () {
    _showDueFeesDialog();
  });
}
    }
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

  loadFreePaidForms(id) async {
    var res =
        await ApiService.getMethod3("/getUserFreePaidForms?user_id=" + id);
    print("/getUserFreePaidForms?user_id=" + id);

    dynamic d = jsonDecode(res.body);
    if (d["status"] == "200" || d["status"] == 200) {
      form1 = d["data"].length;
    }
    setState(() {});
  }

  // void _showDueFeesDialog() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false, // Prevents closing on outside tap
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20.0),
  //         ),
  //         elevation: 8,
  //         backgroundColor: Colors.transparent,
  //         child: Stack(
  //           clipBehavior: Clip.none, // Allows positioning outside the container
  //           children: [
  //             Container(
  //               padding: EdgeInsets.all(2.h),
  //               decoration: BoxDecoration(
  //                 gradient: LinearGradient(
  //                   begin: Alignment.topLeft,
  //                   end: Alignment.bottomRight,
  //                   colors: [Colors.white, Colors.blue.shade50],
  //                 ),
  //                 borderRadius: BorderRadius.circular(20.0),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.1),
  //                     blurRadius: 10,
  //                     spreadRadius: 1,
  //                   ),
  //                 ],
  //               ),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   // Header with icon
  //                   Row(
  //                     children: [
  //                       Container(
  //                         padding: EdgeInsets.all(10),
  //                         decoration: BoxDecoration(
  //                           color: primaryColor.withOpacity(0.1),
  //                           borderRadius: BorderRadius.circular(12),
  //                         ),
  //                         child: Icon(
  //                           Icons.receipt_long,
  //                           color: primaryColor,
  //                           size: 24,
  //                         ),
  //                       ),
  //                       SizedBox(width: 2.w),
  //                       Expanded(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Text(
  //                               feeTitle,
  //                               style: TextStyle(
  //                                 fontWeight: FontWeight.bold,
  //                                 color: primaryColor,
  //                                 fontSize: 16.sp,
  //                               ),
  //                             ),
  //                             Row(
  //                               children: [
  //                                 Icon(
  //                                   Icons.calendar_today,
  //                                   size: 12.sp,
  //                                   color: Colors.grey.shade700,
  //                                 ),
  //                                 SizedBox(width: 0.5.w),
  //                                 Text(
  //                                   'Due date: ${due_date?.isNotEmpty == true ? due_date : DateFormat('dd MMM yyyy').format(nextSaturday)}',
  //                                   style: TextStyle(
  //                                     fontWeight: FontWeight.w400,
  //                                     color: Colors.grey.shade700,
  //                                     fontSize: 12.sp,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   ),

  //                   SizedBox(height: 2.h),

  //                   // Amount due
  //                   GestureDetector(
  //                     onTap: () {
  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(builder: (context) => const Schoolfee()),
  //                       );
  //                     },
  //                     child: Container(
  //                       padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
  //                       decoration: BoxDecoration(
  //                         color: errorColor.withOpacity(0.1),
  //                         borderRadius: BorderRadius.circular(12),
  //                         border: Border.all(
  //                           color: errorColor.withOpacity(0.3),
  //                           width: 1,
  //                         ),
  //                       ),
  //                       child: Row(
  //                         children: [
  //                           Icon(
  //                             Icons.currency_rupee,
  //                             color: errorColor,
  //                             size: 20.sp,
  //                           ),
  //                           SizedBox(width: 1.w),
  //                           Text(
  //                             '$due_fees/-',
  //                             style: TextStyle(
  //                               fontWeight: FontWeight.bold,
  //                               color: errorColor,
  //                               fontSize: 20.sp,
  //                             ),
  //                           ),
  //                           Spacer(),
  //                           Container(
  //                             padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
  //                             decoration: BoxDecoration(
  //                               color: errorColor.withOpacity(0.2),
  //                               borderRadius: BorderRadius.circular(20),
  //                             ),
  //                             child: Row(
  //                               mainAxisSize: MainAxisSize.min,
  //                               children: [
  //                                 Icon(
  //                                   Icons.warning_amber_rounded,
  //                                   color: errorColor,                                    size: 12.sp,
  //                                 ),
  //                                 SizedBox(width: 0.5.w),
  //                                 Text(
  //                                   'Overdue',
  //                                   style: TextStyle(
  //                                     fontWeight: FontWeight.w500,
  //                                     color: errorColor,                                      fontSize: 8.sp,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),

  //                   SizedBox(height: 2.h),

  //                   // Offer Info
  //                   GestureDetector(
  //                     onTap: () {
  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(builder: (context) => const Schoolfee()),
  //                       );
  //                     },
  //                     child: Container(
  //                       padding: EdgeInsets.all(1.5.h),
  //                       decoration: BoxDecoration(
  //                         color: successColor.withOpacity(0.1),
  //                         borderRadius: BorderRadius.circular(12),
  //                         border: Border.all(
  //                           color: successColor.withOpacity(0.3),
  //                           width: 1,
  //                         ),
  //                       ),
  //                       child: Row(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Icon(
  //                             Icons.local_offer,
  //                             color: successColorDark,
  //                             size: 14.sp,
  //                           ),
  //                           SizedBox(width: 1.w),
  //                           Expanded(
  //                             child: Text(
  //                               '2 Years Offer Fees: Rs ${(class_name.contains("Class 9th") || class_name.contains("Class 10th") || class_name.contains("Class 11 Science") || class_name.contains("Class 11 Commerce") || class_name.contains("Class 12 Commerce") || class_name.contains("Class 12 Science")) ? "4,90,000" : "3,90,000"}/- \n Rs ${(class_name.contains("Class 9th") || class_name.contains("Class 10th") || class_name.contains("Class 11 Science") || class_name.contains("Class 11 Commerce") || class_name.contains("Class 12 Commerce") || class_name.contains("Class 12 Science")) ? "2,25,000" : "1,75,000"}/- Per Year \n(Offer Last Date: ${DateFormat('dd MMM yyyy').format(nextSaturday)})',
  //                               style: TextStyle(
  //                                 fontWeight: FontWeight.w500,
  //                                 color: successColorDark,
  //                                 fontSize: 10.sp,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),

  //                   SizedBox(height: 2.h),

  //                   // Warning message
  //                   Container(
  //                     padding: EdgeInsets.all(1.5.h),
  //                     decoration: BoxDecoration(
  //                       color: warningColor.withOpacity(0.1),
  //                       borderRadius: BorderRadius.circular(12),
  //                       border: Border.all(
  //                         color: warningColor.withOpacity(0.3),
  //                         width: 1,
  //                       ),
  //                     ),
  //                     child: Column(
  //                       children: [
  //                         Row(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Icon(
  //                               Icons.info_outline,
  //                               color: warningColorDark,
  //                               size: 14.sp,
  //                             ),
  //                             SizedBox(width: 1.w),
  //                             Expanded(
  //                               child: Text(
  //                                 'Submit your Fees before due date to avoid weekly penalty of Rs 5000/-',
  //                                 style: TextStyle(
  //                                   fontWeight: FontWeight.w500,
  //                                   color: warningColorDark,
  //                                   fontSize: 11.sp,
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                         SizedBox(height: 1.h),
  //                         Row(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Icon(
  //                               Icons.translate,
  //                               color: warningColorDark,
  //                               size: 14.sp,
  //                             ),
  //                             SizedBox(width: 1.w),
  //                             Expanded(
  //                               child: Text(
  //                                 '5000/- रुपये के साप्ताहिक जुर्माने से बचने के लिए देय तिथि से पहले अपना शुल्क जमा करें।',
  //                                 style: TextStyle(
  //                                   fontWeight: FontWeight.w500,
  //                                   color: warningColorDark,
  //                                   fontSize: 11.sp,
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   ),

  //                   SizedBox(height: 2.5.h),

  //                   // Action buttons
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: ElevatedButton.icon(
  //                           onPressed: () {
  //                             Navigator.push(
  //                               context,
  //                               MaterialPageRoute(builder: (context) => const Schoolfee()),
  //                             );
  //                           },
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: primaryColor,
  //                             foregroundColor: Colors.white,
  //                             padding: EdgeInsets.symmetric(vertical: 1.5.h),
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(12),
  //                             ),
  //                             elevation: 2,
  //                           ),
  //                           icon: Icon(Icons.receipt_outlined, size: 16.sp),
  //                           label: Text(
  //                             'View Invoices',
  //                             style: TextStyle(
  //                               fontWeight: FontWeight.w600,
  //                               fontSize: 12.sp,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       SizedBox(width: 2.w),
  //                       Expanded(
  //                         child: ElevatedButton.icon(
  //                           onPressed: () {
  //                             Navigator.push(
  //                               context,
  //                               MaterialPageRoute(builder: (context) => const Schoolfee()),
  //                             );
  //                           },
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: successColor,
  //                             foregroundColor: Colors.white,
  //                             padding: EdgeInsets.symmetric(vertical: 1.5.h),
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(12),
  //                             ),
  //                             elevation: 2,
  //                           ),
  //                           icon: Icon(Icons.payment_outlined, size: 16.sp),
  //                           label: Text(
  //                             'Pay Fees',
  //                             style: TextStyle(
  //                               fontWeight: FontWeight.w600,
  //                               fontSize: 12.sp,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),

  //             // Close button at top-right
  //             Positioned(
  //               top: -10,
  //               right: -10,
  //               child: GestureDetector(
  //                 onTap: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: Container(
  //                   padding: EdgeInsets.all(8),
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     shape: BoxShape.circle,
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.black.withOpacity(0.1),
  //                         blurRadius: 6,
  //                       ),
  //                     ],
  //                     border: Border.all(color: Colors.grey.shade300, width: 1.5),
  //                   ),
  //                   child: Icon(
  //                     Icons.close,
  //                     color: Colors.grey.shade700,
  //                     size: 20,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void _showDueFeesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main dialog container
              Container(
                margin: EdgeInsets.only(top: 10.h), // top margin
                constraints: BoxConstraints(
                  minHeight: 40.h,
                  maxHeight: 65.h,
                  maxWidth: 95.w,
                ),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.blue.shade50],
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.receipt_long,
                                color: primaryColor, size: 20.sp),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  feeTitle,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 10.sp,
                                        color: Colors.grey.shade700),
                                    SizedBox(width: 1.w),
                                    Text(
                                      'Due: ${due_date.isNotEmpty ? due_date : DateFormat('dd MMM yyyy').format(nextSaturday)}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 1.5.h),

                      /// Due Fee Container
                      _buildCompactFeeContainer(),

                      SizedBox(height: 1.5.h),

                      /// Offer Info
                      _buildCompactOfferInfo(),

                      SizedBox(height: 1.5.h),

                      /// Warning Message
                      _buildCompactWarningMessage(),

                      SizedBox(height: 2.h),

                      /// Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Schoolfee()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 1.2.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: Icon(Icons.receipt_outlined, size: 14.sp),
                              label: Text('View Invoice',
                                  style: TextStyle(fontSize: 12.sp)),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Schoolfee()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: successColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 1.2.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: Icon(Icons.payment_outlined, size: 14.sp),
                              label: Text('Pay Now',
                                  style: TextStyle(fontSize: 12.sp)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Close button
              Positioned(
                top: 8.h,
                right: 1.w,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                        ),
                      ],
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1.5),
                    ),
                    child: Icon(Icons.close,
                        color: Colors.grey.shade700, size: 18),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactFeeContainer() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Schoolfee()));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
        decoration: BoxDecoration(
          color: errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: errorColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.currency_rupee, color: errorColor, size: 18.sp),
            SizedBox(width: 1.w),
            Text(
              '$due_fees/-',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: errorColor,
                  fontSize: 20.sp),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: errorColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: errorColor, size: 12.sp),
                  SizedBox(width: 1.w),
                  Text('Overdue',
                      style: TextStyle(fontSize: 11.sp, color: errorColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactOfferInfo() {
    final isSeniorClass = class_name.contains("Class 9th") ||
        class_name.contains("Class 10th") ||
        class_name.contains("Class 11 Science") ||
        class_name.contains("Class 11 Commerce") ||
        class_name.contains("Class 12 Commerce") ||
        class_name.contains("Class 12 Science");

    final offerFee = isSeniorClass ? "4,50,000" : "4,50,000";
    final perYearFee = isSeniorClass ? "2,50,000" : "2,50,000";

    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Schoolfee()));
      },
      child: Container(
        padding: EdgeInsets.all(1.2.h),
        decoration: BoxDecoration(
          color: successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: successColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.local_offer, color: successColorDark, size: 14.sp),
            SizedBox(width: 1.w),
            Expanded(
             child: Text(
  '2 Years Offer: ₹$offerFee/-\nPer Year: ₹$perYearFee/-\n(Last Date: ${DateFormat('dd MMM yyyy').format(nextSaturday)})\nYearly 10% Increment Discounted Off',
  style: TextStyle(
    fontSize: 12.sp,
    color: successColorDark,
  ),
),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactWarningMessage() {
    return Container(
      padding: EdgeInsets.all(1.2.h),
      decoration: BoxDecoration(
        color: warningColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: warningColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: warningColorDark, size: 14.sp),
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  'Avoid weekly penalty of ₹5000/- by paying on time.',
                  style: TextStyle(fontSize: 11.sp, color: warningColorDark),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Icon(Icons.translate, color: warningColorDark, size: 14.sp),
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  '5000/- रुपये के साप्ताहिक जुर्माने से बचने के लिए समय पर शुल्क जमा करें।',
                  style: TextStyle(fontSize: 11.sp, color: warningColorDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showJoinReferenceDialog() {
    showDialog(
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
                    Icon(Icons.campaign, color: errorColor, size: 20.sp),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        "Join & Earn Reference Admissions Offer",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: errorColor,
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
                    Icon(Icons.timer_outlined, color: errorColor, size: 12.sp),
                    SizedBox(width: 1.w),
                    Text(
                      "Offer Last Date: ${DateFormat('dd MMM yyyy').format(nextSaturday)}",
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: errorColor,
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

  // Create a reusable menu item widget
  void _showDashboardIconMessage(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(title)),
    );
  }

  void _openDashboardWebPage(String title, String url) {
    Navigator.of(context).pushNamed(
      OpenUrl.routeName,
      arguments: {
        "school_name": title,
        "url": url,
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    String? imageAsset,
    double? imageWidth,
    double? imageHeight,
    bool circularImage = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 1.w),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageAsset != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(circularImage ? 100 : 6),
                child: Image.asset(
                  imageAsset,
                  width: imageWidth ?? 25.sp,
                  height: imageHeight ?? 25.sp,
                  fit: circularImage ? BoxFit.cover : BoxFit.contain,
                ),
              )
            else
              Icon(
                icon,
                color: iconColor ?? primaryColor,
                size: 18.sp,
              ),
            SizedBox(height: 0.8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
                height: 1.16,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 15, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // Show notifications
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.help_outline, color: Colors.white),
          //   onPressed: () {
          //     // Show help
          //   },
          // ),
        ],
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: primaryColor,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              // Announcements Carousel
              Container(
                margin: EdgeInsets.only(top: 1.h),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 5.h,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 5),
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                  ),
                  items: _announcements.map((announcement) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: deviceSize.width,
                          margin: EdgeInsets.symmetric(horizontal: 2.w),
                          padding: EdgeInsets.symmetric(horizontal: 3.w),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [primaryColor, secondaryColor],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.campaign,
                                  color: Colors.white, size: 16.sp),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(
                                  announcement,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),

              // Student Profile Card
              Container(
                padding: EdgeInsets.all(3.w),
                margin: EdgeInsets.all(3.w),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Profile Image
                        Container(
                          width: 70,
                          height: 90,
                          margin: EdgeInsets.only(right: 3.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: accentColor, width: 2),
                          ),
                          child: profile_pic == ''
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    "assets/65.png",
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    "${ApiService.careerdefenceacademy2}includes/uploads/students_documents/profile_pic/$profile_pic",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),

                        // Student Information
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                full_name,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18.sp,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.3.h),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$class_name $section',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13.5.sp,
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  Icon(Icons.cake_outlined,
                                      size: 15.sp, color: Colors.grey.shade600),
                                  SizedBox(width: 1.w),
                                  Expanded(
                                    child: Text(
                                      "DOB: $dob",
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13.sp,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.5.h),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      size: 15.sp, color: Colors.grey.shade600),
                                  SizedBox(width: 1.w),
                                  Expanded(
                                    child: Text(
                                      "DOJ: $dateofjoining",
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13.sp,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 0.5.h),
                              Row(
                                children: [
                                  Icon(Icons.verified_user_outlined,
                                      size: 15.sp, color: Colors.grey.shade600),
                                  SizedBox(width: 1.w),
                                  Expanded(
                                    child: Text(
                                      "Status: $student_status",
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13.sp,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              // if (class_teacher_name.isNotEmpty) SizedBox(height: 0.5.h),
                              // if (class_teacher_name.isNotEmpty)
                              // Row(
                              //   children: [
                              //     Icon(Icons.school_outlined, size: 12.sp, color: Colors.grey.shade600),
                              //     SizedBox(width: 1.w),
                              //     Expanded(
                              //       child: Text(
                              //         "Teacher: $class_teacher_name",
                              //         style: TextStyle(
                              //           color: Colors.grey.shade700,
                              //           fontSize: 10.sp,

                              //         ),
                              //         overflow: TextOverflow.ellipsis,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              if (location != '') SizedBox(height: 0.5.h),
                              if (location != '')
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        size: 15.sp,
                                        color: Colors.grey.shade600),
                                    SizedBox(width: 1.w),
                                    Expanded(
                                      child: Text(
                                        location,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13.sp,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              SizedBox(height: 0.5.h),
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      size: 15.sp,
                                      color: Colors.grey
                                          .shade600), // Better icon for duration/time
                                  SizedBox(width: 1.w),
                                  Expanded(
                                    child: Text(
                                      "Duration: $created",
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontSize: 13.sp,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.5.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.person_outline,
                                      size: 15.sp, color: Colors.grey.shade600),
                                  // SizedBox(width: 2.w),

                                  // Left Label
                                  Text(
                                    "Father/Email :",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13.sp,
                                      // fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  // SizedBox(width: 3.w),

                                  // Right Side Data Column
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          father_name ?? "N/A",
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          email ?? "N/A",
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 11.sp,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 2.h),

                    // Contact and Batch Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            launch("tel:$mobile");
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [primaryColor, secondaryColor],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.phone,
                                    color: Colors.white, size: 17.sp),
                                SizedBox(width: 1.w),
                                Text(
                                  mobile,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.groups_outlined,
                                  color: primaryColor, size: 17.sp),
                              SizedBox(width: 1.w),
                              Text(
                                batch,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.sp,
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
              if (user.isNotEmpty)
                // DigitalStudentCard(studentData: Map<String, dynamic>.from(user)),

                // Referral Alert
                Visibility(
                  visible: _isAlertVisible,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    margin:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: errorColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: errorColor.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: errorColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.campaign,
                                  color: errorColor, size: 16.sp),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                "Join & Earn Reference Admissions Offer 🚨",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: errorColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
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
                            ],
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        Row(
                          children: [
                            Icon(Icons.timer_outlined,
                                color: errorColor, size: 14.sp),
                            SizedBox(width: 1.w),
                            Text(
                              "Offer Last Date: ${DateFormat('dd MMM yyyy').format(nextSaturday)}",
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: errorColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              // Emergency Contact Card
              Container(
                padding: EdgeInsets.all(3.w),
                margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: warningColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.emergency_outlined,
                              color: warningColor, size: 18.sp),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "Emergency Contact",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 3.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildContactCard(
                          name: "Ms Nancy Garg",
                          role: "Chief Senior Counsellor",
                          phone: "7027333764",
                        ),
                        _buildContactCard(
                          name: "Ms Renu Chopra",
                          role: "Chief Academic Head",
                          phone: "9996600288",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Quick Action Buttons
              Container(
                margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.notifications_active_outlined,
                        label: "Important Updates",
                        color: primaryColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const StudentImportUpdates()),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 3.w),
                    // Expanded(
                    //   child: _buildActionButton(
                    //     icon: Icons.description_outlined,
                    //     label: "Form Details",
                    //     color: secondaryColor,
                    //     onTap: () {
                    //       if (form1 != 0) {
                    //         Navigator.of(context).pushNamed(
                    //           StudentFreePaidForms.routeName,
                    //           arguments: user,
                    //         );
                    //       }
                    //     },
                    //   ),
                    // ),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.payment_outlined,
                        label: "Pay Fees",
                        color: successColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Schoolfee()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Fee Payment Card
              Container(
                padding: EdgeInsets.all(3.w),
                margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.blue.shade50],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.receipt_long,
                                    color: primaryColor, size: 18.sp),
                              ),
                              SizedBox(width: 2.w),
                              Flexible(
                                child: Text(
                                  feeTitle,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                    fontSize: 15.sp,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 11.sp, color: errorColor),
                              SizedBox(width: 1.w),
                              Text(
                                'Due: $due_date',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: errorColor,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: errorColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(1.5.w),
                            decoration: BoxDecoration(
                              color: errorColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.currency_rupee,
                                color: errorColor, size: 20.sp),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              '₹$due_fees/-',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: errorColor,
                                fontSize: 22.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: warningColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: warningColor, size: 15.sp),
                              SizedBox(width: 1.w),
                              Expanded(
                                child: Text(
                                  'Submit your Fees before due date to avoid weekly penalty of Rs 5000/-',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              Icon(Icons.translate,
                                  color: warningColor, size: 15.sp),
                              SizedBox(width: 1.w),
                              Expanded(
                                child: Text(
                                  '5000/- रुपये के साप्ताहिक जुर्माने से बचने के लिए देय तिथि से पहले अपना शुल्क जमा करें।',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: textColor,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        // Expanded(
                        //   child: _buildActionButton(
                        //     icon: Icons.receipt_outlined,
                        //     label: "View Invoices",
                        //     color: primaryColor,
                        //     onTap: () {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(builder: (context) => const Schoolfee()),
                        //       );
                        //     },
                        //   ),
                        // ),
                        SizedBox(width: 3.w),
                        // Expanded(
                        //   child: _buildActionButton(
                        //     icon: Icons.payment_outlined,
                        //     label: "Pay Fees",
                        //     color: successColor,
                        //     onTap: () {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(builder: (context) => const Schoolfee()),
                        //       );
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),

              // Student Activity Report Section
              Container(
                margin: EdgeInsets.all(3.w),
                padding: EdgeInsets.all(3.w),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.dashboard_customize_outlined,
                              color: primaryColor, size: 16.sp),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "Student Activity Report",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    // Grid of menu items - First row
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 2.w,
                      crossAxisSpacing: 2.w,
                      childAspectRatio: 0.7,
                      children: [
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: "Student Details",
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              StudentDetails.routeName,
                              arguments: user,
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.medical_services_outlined,
                          title: "Medical Report",
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              StudentMedicalReport.routeName,
                              arguments: user,
                            );
                          },
                          iconColor: errorColor,
                        ),
                        _buildMenuItem(
                          icon: Icons.phone_in_talk_outlined,
                          title: "Emergency No.",
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              StudentWeeklyReport.routeName,
                              arguments: user,
                            );
                          },
                          iconColor: warningColor,
                        ),
                        _buildMenuItem(
                          icon: Icons.help_outline,
                          title: "Parents FAQ",
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              ParentsFaqs.routeName,
                            );
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    // Second row
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 2.w,
                      crossAxisSpacing: 2.w,
                      childAspectRatio: 0.7,
                      children: [
                        _buildMenuItem(
                          icon: Icons.star_outline,
                          title: "Super 50\n Ymngr",
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              Super50.routeName,
                            );
                          },
                          iconColor: warningColor,
                        ),
                        // _buildMenuItem(
                        //   icon: Icons.check_circle_outline,
                        //   title: "Weekly Copy Stamping",
                        //   onTap: () {
                        //     Navigator.of(context).pushNamed(
                        //       WeeklyCopyStampingMain.routeName,
                        //       arguments: user,
                        //     );
                        //   },
                        //   iconColor: successColor,
                        // ),
                        _buildMenuItem(
                          icon: FontAwesomeIcons.planeDeparture,
                          title: "CDS Stay\nShimla",
                          onTap: () async {
                            const url = 'https://cdsluxuryhomestay.com/';
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url),
                                  mode: LaunchMode.externalApplication);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          iconColor: Colors.blueAccent,
                        ),

                        _buildMenuItem(
                          icon: Icons.account_balance_wallet_outlined,
                          title: "Pocket Money",
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              StudentCanteenReport.routeName,
                              arguments: user,
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.receipt_long_outlined,
                          title: "Fee Details",
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              StudentFeesDetail.routeName,
                              arguments: user,
                            );
                          },
                          iconColor: errorColor,
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    // Third row
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 2.w,
                      crossAxisSpacing: 2.w,
                      childAspectRatio: 0.7,
                      children: [
                        // _buildMenuItem(
                        //   icon: Icons.calendar_view_week_outlined,
                        //   title: "Hobby Classes",
                        //   onTap: () {
                        //     Navigator.of(context).pushNamed(
                        //       StudentWeeklyActivity.routeName,
                        //       arguments: user,
                        //     );
                        //   },
                        // ),
                        _buildMenuItem(
                          icon: Icons.tour_outlined,
                          title: "Educational Trip",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const EducationalTrip()),
                            );
                          },
                          iconColor: primaryColor,
                        ),
                        _buildMenuItem(
                          icon: Icons.money_off_outlined,
                          title: "Fine Charges",
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              StudentFineCharges.routeName,
                              arguments: user,
                            );
                          },
                          iconColor: errorColor,
                        ),
                        _buildMenuItem(
                          icon: Icons.menu_book_outlined,
                          title: "Study Report",
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              StudentStudyReport.routeName,
                              arguments: user,
                            );
                          },
                          iconColor: successColor,
                        ),
                        _buildMenuItem(
                          icon: Icons.emoji_events_outlined,
                          title: "Our Results",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const StudentResults()),
                            );
                          },
                          iconColor: warningColor,
                        ),
//                         _buildMenuItem(
//   icon: Icons.dashboard_customize ,
//   title: "Our Functions",
//   onTap: () {
//     Navigator.of(context).pushNamed(
//       OurFunctions.routeName,
//       arguments: user,
//     );
//   },
//   iconColor: errorColor,
// ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    // Fourth row
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 2.w,
                      crossAxisSpacing: 2.w,
                      childAspectRatio: 0.7,
                      children: [
                        _buildMenuItem(
                          icon: Icons.support_agent_outlined,
                          title: "Complaint Resolution",
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              StudentCallingReport.routeName,
                              arguments: user,
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: FontAwesomeIcons.flask,
                          title: "Science/AI Experiments",
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              ScienceExperiment.routeName,
                              arguments: user,
                            );
                          },
                          iconColor: Colors.teal,
                        ),

                        // _buildMenuItem(
                        //   icon: FontAwesomeIcons.stethoscope,
                        //   title: "Medical TIPS",
                        //   onTap: () {
                        //     Navigator.of(context).pushNamed(
                        //       MedicalTipsPage.routeName,
                        //       arguments: user,
                        //     );
                        //   },
                        //   iconColor: Colors.teal,
                        // ),
                        _buildMenuItem(
                          icon: Icons.restaurant_menu_outlined,
                          title: "Daily Menu",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Messmenu()),
                            );
                          },
                          iconColor: errorColor,
                        ),
                        _buildMenuItem(
                          icon: FontAwesomeIcons.award,
                          title: "Certification Courses",
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              CertificationCourses.routeName,
                              arguments: user,
                            );
                          },
                          iconColor: warningColor,
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    // Fifth row
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 2.w,
                      crossAxisSpacing: 2.w,
                      childAspectRatio: 0.7,
                      children: [
                        _buildMenuItem(
                          icon: FontAwesomeIcons.star,
                          title: "Unique Features",
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              UniqueFeaturesPage.routeName,
                            );
                          },
                          iconColor: warningColor,
                        ),
                        _buildMenuItem(
                          icon: Icons.book_outlined,
                          title: "Syllabus Update",
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              SyllabusUpdate.routeName,
                              arguments: user,
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.sports_outlined,
                          title: "Sports Activities",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const DailySportsActivity()),
                            );
                          },
                          iconColor: primaryColor,
                        ),
                        _buildMenuItem(
                          icon: Icons.movie_outlined,
                          title: "Recorded Classes",
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              MyCourses.routeName,
                              arguments: user,
                            );
                          },
                          iconColor: errorColor,
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    // Sixth row
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 2.w,
                      crossAxisSpacing: 2.w,
                      childAspectRatio: 0.7,
                      children: [
                        _buildMenuItem(
                          icon: Icons.military_tech_outlined,
                          title: "NDA/NCC Training",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const NDATrainingScreen()),
                            );
                          },
                          iconColor: errorColor,
                        ),
                        _buildMenuItem(
                          icon: Icons.sports_cricket_outlined,
                          title: "Sub-Junior Wing",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Juniorwing()),
                            );
                          },
                          iconColor: secondaryColor,
                        ),
                        _buildMenuItem(
                          icon: Icons.people_outline,
                          title: "Reference",
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              StudentReferences.routeName,
                              arguments: user,
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.videocam_outlined,
                          title: "CCTV Cameras",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CCTVCamera()),
                            );
                          },
                          iconColor: primaryColor,
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    // Seventh row
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 2.w,
                      crossAxisSpacing: 2.w,
                      childAspectRatio: 0.7,
                      children: [
                        _buildMenuItem(
                          icon: Icons.hotel_outlined,
                          title: "Dr. Vivek Bindra",
                          onTap: () => _openDashboardWebPage(
                            "Dr. Vivek Bindra",
                            "https://www.careerdefenceschool.com/apphome.php",
                          ),
                          iconColor: primaryColor,
                          imageAsset: "assets/Vivek.jpeg",
                          imageWidth: 31.sp,
                          imageHeight: 31.sp,
                        ),
                        _buildMenuItem(
                          icon: Icons.sports_cricket_outlined,
                          title: "Vaibhav Arora",
                          onTap: () => _openDashboardWebPage(
                            "Vaibhav Arora",
                            "https://www.careerdefenceschool.com/appvaibhav.php",
                          ),
                          iconColor: secondaryColor,
                          imageAsset: "assets/Vaibhav.jpeg",
                          imageWidth: 31.sp,
                          imageHeight: 31.sp,
                        ),
                        _buildMenuItem(
                          icon: Icons.sports_outlined,
                          title: "Karan Ambala",
                          onTap: () => _openDashboardWebPage(
                            "Karan Ambala",
                            "https://www.careerdefenceschool.com/appkaran.php",
                          ),
                          iconColor: successColor,
                          imageAsset: "assets/karan ambala.jpeg",
                          imageWidth: 31.sp,
                          imageHeight: 31.sp,
                        ),
                        _buildMenuItem(
                          icon: Icons.school_outlined,
                          title: "Bansal Classes",
                          onTap: () => _openDashboardWebPage(
                            "Bansal Classes",
                            "https://www.careerdefenceschool.com/appbansal.php",
                          ),
                          iconColor: warningColor,
                          imageAsset: "assets/Bansal.jpeg",
                          imageWidth: 34.sp,
                          imageHeight: 25.sp,
                          circularImage: false,
                        ),
                        // if (flag_recorded_class)
                        //   _buildMenuItem(
                        //     icon: Icons.movie_outlined,
                        //     title: "Recorded Classes",
                        //     onTap: () {
                        //       Navigator.of(context).pushNamed(
                        //         MyCourses.routeName,
                        //         arguments: user,
                        //       );
                        //     },
                        //     iconColor: errorColor,
                        //   ),
                        //  if (flag_recorded_class)
//                          _buildMenuItem(
//   icon: Icons.language,
//   title: "Spoken English",
//   onTap: () {
//     Navigator.of(context).pushNamed(
//       SpokenEnglish.routeName,
//       arguments: user,
//     );
//   },
//   iconColor: errorColor,
// ),

                        // if (!flag_recorded_class)
                        //   _buildMenuItem(
                        //     icon: Icons.feedback_outlined,
                        //     title: "Student Feedback",
                        //     onTap: () {
                        //       Navigator.of(context).pushNamed(
                        //         StudentFeedback.routeName,
                        //         arguments: user,
                        //       );
                        //     },
                        //   ),
                      ],
                    ),
                  ],
                ),
              ),

              // Footer space
              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build contact card
  Widget _buildContactCard(
      {required String name, required String role, required String phone}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              role,
              style: TextStyle(
                fontSize: 10.5.sp,
                color: Colors.grey.shade700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1.h),
            GestureDetector(
              onTap: () {
                launch("tel://$phone");
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone, color: primaryColor, size: 11.5.sp),
                    SizedBox(width: 1.w),
                    Text(
                      phone,
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 10.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build action button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 2.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      icon: Icon(icon, size: 16.sp),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12.5.sp,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  // Helper method to build offer row
  Widget _buildOfferRow({
    required IconData icon,
    required String text,
    required String highlight,
  }) {
    return Row(
      children: [
        Icon(icon, color: errorColor, size: 14.sp),
        SizedBox(width: 2.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 11.sp,
                color: textColor,
              ),
              children: [
                TextSpan(text: "$text ("),
                TextSpan(
                  text: highlight,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: errorColor,
                  ),
                ),
                const TextSpan(text: ")"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DigitalStudentCardState extends State<DigitalStudentCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _frontRotation;
  late Animation<double> _backRotation;
  bool _showFrontCard = true;
  Timer? _cardSwitchTimer;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Set up front card rotation animation
    _frontRotation = Tween<double>(
      begin: 0,
      end: -0.5 * 3.14159, // -π/2 radians (90 degrees)
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Set up back card rotation animation
    _backRotation = Tween<double>(
      begin: 0.5 * 3.14159, // π/2 radians (90 degrees)
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start timer to switch cards every 5 seconds
    _startCardSwitchTimer();
  }

  void _startCardSwitchTimer() {
    _cardSwitchTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _toggleCard();
    });
  }

  void _toggleCard() {
    if (_showFrontCard) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    // Update state after animation completes
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        _showFrontCard = !_showFrontCard;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardSwitchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.h,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      child: Stack(
        children: [
          // Digital ID Card (Back)
          AnimatedBuilder(
            animation: _backRotation,
            builder: (context, child) {
              final showBackCard = !_showFrontCard;
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateY(_backRotation.value),
                alignment: Alignment.center,
                child: Visibility(
                  visible: showBackCard,
                  child: _buildDigitalIdCard(),
                ),
              );
            },
          ),

          // School ID Card (Front)
          AnimatedBuilder(
            animation: _frontRotation,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateY(_frontRotation.value),
                alignment: Alignment.center,
                child: Visibility(
                  visible: _showFrontCard,
                  child: _buildSchoolIdCard(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Digital ID Card Design
  Widget _buildDigitalIdCard() {
    const Color primaryColor = Color(0xFF1565C0);
    const Color accentColor = Color(0xFF64B5F6);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.indigo.shade800, Colors.indigo.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(
                painter: CardPatternPainter(),
              ),
            ),
          ),

          // Card content
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "DIGITAL ID CARD",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          "Career Defence School",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        "assets/65.png",
                        height: 5.h,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Student info
                Row(
                  children: [
                    // Profile image
                    Container(
                      width: 20.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: widget.studentData["profile_pic"] == null ||
                              widget.studentData["profile_pic"] == ''
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                "assets/65.png",
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                "https://careerdefenceacademy.com/includes/uploads/students_documents/profile_pic/${widget.studentData["profile_pic"]}",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                  "assets/65.png",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                    ),

                    SizedBox(width: 3.w),

                    // Student details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.studentData["first_name"] ?? "Student Name",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          _buildInfoRow(
                            Icons.school_outlined,
                            "${widget.studentData["class_for"] ?? "Class"} ${widget.studentData["section"] ?? ""}",
                          ),
                          SizedBox(height: 0.5.h),
                          _buildInfoRow(
                            Icons.badge_outlined,
                            "Roll No: ${widget.studentData["roll_no"] ?? "N/A"}",
                          ),
                          SizedBox(height: 0.5.h),
                          _buildInfoRow(
                            Icons.calendar_today_outlined,
                            "Batch: ${widget.studentData["batch"] ?? "N/A"}",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // QR Code and additional info
                Row(
                  children: [
                    // QR Code placeholder
                    Container(
                      width: 20.w,
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.qr_code,
                          size: 8.h,
                          color: primaryColor,
                        ),
                      ),
                    ),

                    SizedBox(width: 3.w),

                    // Additional details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            Icons.phone_outlined,
                            widget.studentData["mobile"] ?? "N/A",
                          ),
                          SizedBox(height: 0.5.h),
                          _buildInfoRow(
                            Icons.location_on_outlined,
                            widget.studentData["city"] ?? "N/A",
                          ),
                          SizedBox(height: 0.5.h),
                          _buildInfoRow(
                            Icons.verified_user_outlined,
                            "Status: ${widget.studentData["student_status"] ?? "Active"}",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Validity
                const Spacer(),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Valid till: March 31, 2025",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // School ID Card Design
  Widget _buildSchoolIdCard() {
    const Color primaryColor = Color(0xFF1565C0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/65.png",
                    height: 5.h,
                  ),
                ),
                SizedBox(width: 2.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CAREER DEFENCE SCHOOL",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                    Text(
                      "STUDENT IDENTITY CARD",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Divider(
              color: primaryColor.withOpacity(0.3),
              height: 3.h,
              thickness: 1,
            ),

            // Student info
            Row(
              children: [
                // Profile image
                Container(
                  width: 20.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: primaryColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: widget.studentData["profile_pic"] == null ||
                          widget.studentData["profile_pic"] == ''
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            "assets/65.png",
                            fit: BoxFit.cover,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            "https://careerdefenceacademy.com/includes/uploads/students_documents/profile_pic/${widget.studentData["profile_pic"]}",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              "assets/65.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                ),

                SizedBox(width: 3.w),

                // Student details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRowLight(
                        "Name:",
                        widget.studentData["first_name"] ?? "Student Name",
                      ),
                      SizedBox(height: 0.8.h),
                      _buildInfoRowLight(
                        "Class:",
                        "${widget.studentData["class_for"] ?? "Class"} ${widget.studentData["section"] ?? ""}",
                      ),
                      SizedBox(height: 0.8.h),
                      _buildInfoRowLight(
                        "Roll No:",
                        widget.studentData["roll_no"] ?? "N/A",
                      ),
                      SizedBox(height: 0.8.h),
                      _buildInfoRowLight(
                        "Father's Name:",
                        widget.studentData["father_name"] ?? "N/A",
                      ),
                      SizedBox(height: 0.8.h),
                      _buildInfoRowLight(
                        "DOB:",
                        widget.studentData["dob"] != null
                            ? widget.studentData["dob"]
                                .toString()
                                .substring(0, 10)
                            : "N/A",
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Contact info
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone, size: 12.sp, color: primaryColor),
                      SizedBox(width: 1.w),
                      Text(
                        widget.studentData["mobile"] ?? "N/A",
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                          fontSize: 10.sp,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.location_on, size: 12.sp, color: primaryColor),
                      SizedBox(width: 1.w),
                      Text(
                        widget.studentData["city"] ?? "N/A",
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Valid till: March 31, 2025",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 9.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      "ID: ${widget.studentData["id"] ?? "N/A"}",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      height: 3.h,
                      width: 20.w,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 1),
                        ),
                      ),
                    ),
                    Text(
                      "Principal",
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w500,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for dark card info rows
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 10.sp,
          color: Colors.white.withOpacity(0.8),
        ),
        SizedBox(width: 1.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 10.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Helper method for light card info rows
  Widget _buildInfoRowLight(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 25.w,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
              fontSize: 10.sp,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 10.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Custom painter for card background pattern
class CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw curved lines pattern
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final startY = -size.height * 0.2 + (i * size.height * 0.3);

      path.moveTo(0, startY);
      path.quadraticBezierTo(
          size.width * 0.5, startY + size.height * 0.2, size.width, startY);
      path.lineTo(size.width, startY + size.height * 0.1);
      path.quadraticBezierTo(size.width * 0.5, startY + size.height * 0.3, 0,
          startY + size.height * 0.1);
      path.close();

      canvas.drawPath(path, paint);
    }

    // Draw circles
    for (int i = 0; i < 10; i++) {
      final x = size.width * (i / 10);
      final y = size.height * 0.8;
      final radius = size.width * 0.03;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
