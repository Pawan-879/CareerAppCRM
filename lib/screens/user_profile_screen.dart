import 'package:careerapp/screens/cctv_cameras.dart';
import 'package:careerapp/screens/educational_trip.dart';
import 'package:careerapp/screens/junior_wing.dart';
import 'package:careerapp/screens/mess_menu.dart';
import 'package:careerapp/screens/nda_training.dart';
import 'package:careerapp/screens/student_emergency_contact.dart';
import 'package:careerapp/screens/student_medical_report.dart';

import 'package:careerapp/screens/daily_sports_activity.dart';
import 'package:careerapp/screens/student_results.dart';
import 'package:careerapp/screens/student_canteen_report.dart';
import 'package:careerapp/screens/certification_courses.dart';
import 'package:careerapp/screens/student_study_report.dart';
import 'package:careerapp/screens/student_fine_charges.dart';
import 'package:careerapp/screens/student_fees_detail.dart';
import 'package:careerapp/screens/uniques_features.dart';
import 'package:careerapp/screens/student_weekly_activity.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:careerapp/screens/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careerapp/screens/login.dart';
import 'package:careerapp/screens/student_search.dart';
import 'dart:convert';
import 'package:careerapp/services/api_services.dart';
import 'package:careerapp/screens/editprofile.dart';
import 'package:careerapp/screens/editmobile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:careerapp/screens/super50.dart';
import '../services/common_service.dart';
import 'dashboard2.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  var user_name = "Guest\n";
  var user_email = "guest@gmail.com ";
  var user_phone = "----------";
  var class_name = "Guest";
  var user_id = '0';
  var userData;
  var flag = false;
  var students = [];
  late TextEditingController _controller;
  late String valueText;
  List recentStudents = [];

  // Define colors for the app theme
  final Color primaryColor = const Color(0xFF1E3A8A); // Deep blue
  final Color accentColor = const Color(0xFF3B82F6); // Bright blue
  final Color cardColor = Colors.white;
  final Color backgroundColor = const Color(0xFFF3F4F6);
  final Color textColor = const Color(0xFF1F2937);
  final Color secondaryTextColor = const Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    getUserData();
  }

  getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      userData = json.decode(prefs.getString('userData')!);

      user_name = userData["user_name"].toString().toUpperCase();
      user_email = userData["user_email"];
      user_id = userData["user_id"];
      user_phone = userData["user_phone"];
      class_name = userData["studyingin"];

      flag = true;
      loadRecentStudents(); 
      loadData();
      setState(() {});
    }
  }

  submit() async {
    // Show loader dialog with improved styling
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: accentColor),
                const SizedBox(height: 16),
                Text(
                  "Searching...",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      var val = valueText;
      var res = await ApiService.getMethod3("/checkStudentExit?q=$val");

      // Close loader dialog
      Navigator.of(context).pop();

      dynamic data = jsonDecode(res.body);

      if (data["error"] == false) {
        if (data["data"] == null || data["data"].isEmpty) {
          _showToast("No student found");
          return;
        }

        // If found, close search dialog and navigate
        Navigator.of(context).pop(); // Close AlertDialog
        if (data["data"] is List && data["data"].isNotEmpty) {
          saveRecentStudent(data["data"][0]); // Save the first student in the list
        }

        Navigator.of(context).pushNamed(
          StudentSearch.routeName,
          arguments: data["data"],
        );
      } else {
        _showToast("No student found");
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loader if error occurs
      _showToast("Something went wrong. Please try again.");
    }
  }

  _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  saveRecentStudent(studentData) async {
    final prefs = await SharedPreferences.getInstance();

    if (studentData is! Map<String, dynamic>) return;

    // Normalize studentData
    Map<String, dynamic> normalizedStudent = {
      ...studentData,
      "user_id": studentData["user_id"] ?? studentData["id"] ?? "0"
    };

    // Avoid duplicates
    recentStudents.removeWhere((item) => item["user_id"] == normalizedStudent["user_id"]);
    recentStudents.insert(0, normalizedStudent);

    await prefs.setString('recentStudents', json.encode(recentStudents));
    setState(() {});
  }

  loadRecentStudents() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('recentStudents')) {
      final decodedList = json.decode(prefs.getString('recentStudents')!);
      if (decodedList is List) {
        recentStudents = decodedList.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
      }
    }
    setState(() {});
  }

  deleteAccount() async {
    var res = await ApiService.getMethod("/deleteAccount?user_id=$user_id");
    dynamic data = jsonDecode(res.body);
    if (data["error"] == false) {
      CommonService.logout();
      Navigator.of(context)
          .pushNamedAndRemoveUntil(LoginScreen.routeName, (r) => false);
    }
    setState(() {});
  }

loadData() async {
  print("User Data: $userData");

  try {
    var res = await ApiService.getMethod3(
      '/getStudentByNumber?mobile=${userData["user_phone"]}'
    );

    print("Students API Response: ${res.body}");

    final jsonResponse = jsonDecode(res.body);

    if (jsonResponse is Map<String, dynamic> &&
        jsonResponse['status'] == 200 &&
        jsonResponse['data'] != null) {

      final List<dynamic> jsonList = jsonResponse['data'];

      // Convert to List<Map<String, dynamic>> safely
      final List<Map<String, dynamic>> parsedStudents = jsonList
          .whereType<Map<String, dynamic>>()
          .map((s) => Map<String, dynamic>.from(s))
          .toList();

      // Deduplicate using a Map based on `user_id`
      final Map<String, Map<String, dynamic>> uniqueStudentsMap = {};
      for (var student in parsedStudents) {
        final userId = student['user_id']?.toString() ?? '';
        if (userId.isNotEmpty) {
          uniqueStudentsMap[userId] = student;
        }
      }

      // Convert map back to list
      students = uniqueStudentsMap.values.toList();

      print("✅ Total unique students loaded: ${students.length}");
      print("✅ Final Students List: $students");
    } else {
      print("⚠️ No data found or invalid response structure");
      students = [];
    }
  } catch (e, st) {
    print("❌ Failed to parse student data: $e");
    print(st);
    students = [];
  }

  setState(() {});
}




  // Custom widget for feature tiles
  Widget _buildFeatureTile({
    required String title,
    required Widget icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? accentColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: icon,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section header widget
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 10,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            // Profile Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, accentColor],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
              child: Column(
                children: [
                  // Profile Image
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        "${ApiService.websiteUrl}ads/profileimg.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 1),
                  
                  // User Name
                  Text(
                    user_name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Class Name
                  if (class_name != "Guest")
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        class_name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  
                  // Login Button for Guest
                  if (user_name == 'Guest')
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            LoginScreen.routeName,
                            (r) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // User Information Card
            if (flag)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "User Information",
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              getUserData();
                            },
                            icon: Icon(Icons.refresh, color: accentColor),
                            tooltip: "Refresh",
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    
                    // User Details
                    _buildInfoTile(
                      icon: Icons.school,
                      title: "Studying In",
                      subtitle: class_name,
                    ),
                    _buildInfoTile(
                      icon: Icons.email,
                      title: "Email",
                      subtitle: user_email,
                    ),
                    _buildInfoTile(
                      icon: Icons.phone,
                      title: "Phone",
                      subtitle: user_phone,
                      trailing: const Icon(Icons.edit, size: 15),
                      onTap: () {
                        if (flag) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const Editmobile())
                          );
                        }
                      },
                    ),
                    
                    // Edit Profile Button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const Editprofile())
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text("Edit Profile"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // CDS Activities Dashboard
             if (!flag) ...[
  // _sectionHeader("CDS Activities Dashboard"),
  
  // Grid of feature tiles - modified to show 4 in a row
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: GridView.count(
      crossAxisCount: 4, // Changed from 3 to 4
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12, // Reduced spacing
      crossAxisSpacing: 12, // Reduced spacing
      childAspectRatio: 0.9, // Adjusted for better proportions with 4 columns
      children: [
        // _buildFeatureTile(
        //   title: "Student Details",
        //   icon: Image.asset(
        //     "assets/icon/student.png",
        //     height: 10, // Reduced icon size from 24 to 20
        //     color: Colors.blue[700],
        //   ),
        //   onTap: () {
        //     Navigator.of(context).pushNamed(StudentDetails.routeName);
        //   },
        //   iconColor: Colors.blue[700],
        // ),
        _buildFeatureTile(
          title: "Fee Details",
          icon: Image.asset(
            "assets/icon/fee.png",
            height: 10, // Reduced icon size
            color: Colors.green[700],
          ),
          onTap: () {
            Navigator.of(context).pushNamed(StudentFeesDetail.routeName);
          },
          iconColor: Colors.green[700],
        ),
       _buildFeatureTile(
  icon: Image.asset(
    "assets/icon/fee.png",
    height: 10, // Adjust size as needed
  ),
  title: "Medical Report",
  onTap: () {
    Navigator.of(context).pushNamed(
      StudentMedicalReport.routeName,
      // arguments: user,
    );
  },
  // iconColor: errorColor, // Optional: may not apply to Image.asset
),

        // Continue with other tiles...
        _buildFeatureTile(
          title: "Pocket Money",
          icon: Image.asset(
            "assets/icon/pm_wallet.png",
            height: 10, // Reduced icon size
            color: Colors.orange[700],
          ),
          onTap: () {
            Navigator.of(context).pushNamed(StudentCanteenReport.routeName);
          },
          iconColor: Colors.orange[700],
        ),
        // _buildFeatureTile(
        //   title: "Cleaning Report",
        //   icon: Image.asset(
        //     "assets/icon/cleaning.png",
        //     height: 10, // Reduced icon size
        //     color: Colors.purple[700],
        //   ),
        //   onTap: () {
        //     Navigator.of(context).pushNamed(StudentFeedback.routeName, arguments: []);
        //   },
        //   iconColor: Colors.purple[700],
        // ),
        _buildFeatureTile(
          title: "Emergency No.",
          icon: Image.asset(
            "assets/icon/medical.png",
            height: 10, // Reduced icon size
            color: Colors.red[700],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StudentEmergencyContact())
            );
          },
          iconColor: Colors.red[700],
        ),
        _buildFeatureTile(
          title: "Super 50 Yamunanagar",
          icon: Image.asset(
            "assets/icon/super_50.png",
            height: 10, // Reduced icon size
            color: Colors.amber[700],
          ),
          onTap: () {
            Navigator.of(context).pushNamed(Super50.routeName);
          },
          iconColor: Colors.amber[700],
        ),
        // _buildFeatureTile(
        //   title: "Complaint Resolution",
        //   icon: Image.asset(
        //     "assets/icon/phone.png",
        //     height: 10, // Reduced icon size
        //     color: Colors.teal[700],
        //   ),
        //   onTap: () {
        //     Navigator.of(context).pushNamed(StudentCallingReport.routeName);
        //   },
        //   iconColor: Colors.teal[700],
        // ),
        _buildFeatureTile(
          title: "Fine Charges",
          icon: Image.asset(
            "assets/icon/fine_icon.png",
            height: 10, // Reduced icon size
            color: Colors.red[700],
          ),
          onTap: () {
            Navigator.of(context).pushNamed(StudentFineCharges.routeName);
          },
          iconColor: Colors.red[700],
        ),
        _buildFeatureTile(
          title: "Study Report",
          icon: Image.asset(
            "assets/icon/study.png",
            height: 10, // Reduced icon size
            color: Colors.indigo[700],
          ),
          onTap: () {
            Navigator.of(context).pushNamed(
              StudentStudyReport.routeName,
              arguments: userData,
            );
          },
          iconColor: Colors.indigo[700],
        ),
         _buildFeatureTile(
          title: "Our Results",
          icon: const Icon(Icons.rocket, color: Colors.blue, size: 15), // Reduced icon size
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StudentResults())
            );
          },
          iconColor: Colors.blue,
        ),
        _buildFeatureTile(
          title: "Weekly Activity",
          icon: Image.asset(
            "assets/icon/class.png",
            height: 10, // Reduced icon size
            color: Colors.green[700],
          ),
          onTap: () {
            Navigator.of(context).pushNamed(StudentWeeklyActivity.routeName, arguments: []);
          },
          iconColor: Colors.green[700],
        ),

        _buildFeatureTile(
          title: "Parents FAQ",
          icon: Image.asset(
            "assets/tax-form.png",
            height: 10, // Reduced icon size
            color: Colors.purple[700],
          ),
          onTap: () {
            launch("https://www.careerdefenceschool.com/pdf/FAQ%20PDF.pdf");
          },
          iconColor: Colors.purple[700],
        ),
        // _buildFeatureTile(
        //   title: "Medical TIPS",
        //   icon: Icon(FontAwesomeIcons.stethoscope, color: Colors.teal[700], size: 15), // Reduced icon size
        //   onTap: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => MedicalTipsPage())
        //     );
        //   },
        //   iconColor: Colors.teal[700],
        // ),
        _buildFeatureTile(
          title: "Unique Features",
          icon: Icon(FontAwesomeIcons.star, color: Colors.red[700], size: 15), // Reduced icon size
          onTap: () {
            Navigator.of(context).pushNamed(UniqueFeaturesPage.routeName);
          },
          iconColor: Colors.red[700],
        ),
        _buildFeatureTile(
          title: "Certification Courses",
          icon: Icon(FontAwesomeIcons.award, color: Colors.amber[700], size: 15), // Reduced icon size
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CertificationCourses())
            );
          },
          iconColor: Colors.amber[700],
        ),
        //  _buildFeatureTile(
        //   title: "Leadership Training",
        //   icon: const Icon(Icons.play_arrow, color: Colors.red, size: 15), // Reduced icon size
        //   onTap: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => const LeadershipTrainingScreen())
        //     );
        //   },
        //   iconColor: Colors.red,
        // ),
        _buildFeatureTile(
          title: "NDA/NCC Training",
          icon: const Icon(Icons.play_arrow, color: Colors.red, size: 15), // Reduced icon size
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NDATrainingScreen())
            );
          },
          iconColor: Colors.red,
        ),
        // _buildFeatureTile(
        //   title: "Organic Farming",
        //   icon: Image.asset(
        //     "assets/icon/organic.jpg",
        //     height: 10, // Reduced icon size
        //     color: Colors.green[700],
        //   ),
        //   onTap: () {
        //     Navigator.of(context).pushNamed(OrganicFarming.routeName);
        //   },
        //   iconColor: Colors.green[700],
        // ),
        _buildFeatureTile(
          title: "Daily Menu",
          icon: Icon(Icons.food_bank, color: Colors.orange[700], size: 15), // Reduced icon size
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Messmenu())
            );
          },
          iconColor: Colors.orange[700],
        ),
        _buildFeatureTile(
          title: "Sub-Junior Wing",
          icon: const Icon(Icons.sports_cricket, color: Colors.blue, size: 15), // Reduced icon size
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Juniorwing())
            );
          },
          iconColor: Colors.blue,
        ),
        _buildFeatureTile(
          title: "Educational Trip",
          icon: const Icon(Icons.tour, color: Colors.blue, size: 15), // Reduced icon size
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EducationalTrip())
            );
          },
          iconColor: Colors.blue,
        ),
        // _buildFeatureTile(
        //   title: "Weekly Copy Stamping",
        //   icon: Icon(Icons.check_circle, color: Colors.green[700], size: 15), // Reduced icon size
        //   onTap: () {
        //     Navigator.of(context).pushNamed(WeeklyCopyStampingMain.routeName);
        //   },
        //   iconColor: Colors.green[700],
        // ),
        _buildFeatureTile(
          title: "Sports Activities",
          icon: const Icon(Icons.sports_score, color: Colors.blue, size: 15), // Reduced icon size
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DailySportsActivity())
            );
          },
          iconColor: Colors.blue,
        ),
        _buildFeatureTile(
          title: "CCTV Cameras",
          icon: Icon(Icons.camera, color: Colors.grey[700], size: 15), // Reduced icon size
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CCTVCamera())
            );
          },
          iconColor: Colors.grey[700],
        ),
        
      ],
    ),
  ),

  // _sectionHeader("Academic Resources"),
  
  // Padding(
  //   padding: const EdgeInsets.symmetric(horizontal: 16),
  //   child: GridView.count(
  //     crossAxisCount: 4, // Changed from 3 to 4
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     mainAxisSpacing: 12, // Reduced spacing
  //     crossAxisSpacing: 12, // Reduced spacing
  //     childAspectRatio: 0.9, // Adjusted for better proportions
  //     children: [
  //       _buildFeatureTile(
  //         title: "Our Results",
  //         icon: const Icon(Icons.rocket, color: Colors.blue, size: 15), // Reduced icon size
  //         onTap: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => const StudentResults())
  //           );
  //         },
  //         iconColor: Colors.blue,
  //       ),
  //       _buildFeatureTile(
  //         title: "Weekly Activity",
  //         icon: Image.asset(
  //           "assets/icon/class.png",
  //           height: 10, // Reduced icon size
  //           color: Colors.green[700],
  //         ),
  //         onTap: () {
  //           Navigator.of(context).pushNamed(StudentWeeklyActivity.routeName, arguments: []);
  //         },
  //         iconColor: Colors.green[700],
  //       ),
  //       _buildFeatureTile(
  //         title: "Parents FAQ",
  //         icon: Image.asset(
  //           "assets/tax-form.png",
  //           height: 10, // Reduced icon size
  //           color: Colors.purple[700],
  //         ),
  //         onTap: () {
  //           launch("https://www.careerdefenceschool.com/pdf/CDS_FAQ_NEW.pdf");
  //         },
  //         iconColor: Colors.purple[700],
  //       ),
  //       _buildFeatureTile(
  //         title: "Medical TIPS",
  //         icon: Icon(FontAwesomeIcons.stethoscope, color: Colors.teal[700], size: 15), // Reduced icon size
  //         onTap: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => MedicalTipsPage())
  //           );
  //         },
  //         iconColor: Colors.teal[700],
  //       ),
  //       _buildFeatureTile(
  //         title: "Unique Features",
  //         icon: Icon(FontAwesomeIcons.star, color: Colors.red[700], size: 15), // Reduced icon size
  //         onTap: () {
  //           Navigator.of(context).pushNamed(UniqueFeaturesPage.routeName);
  //         },
  //         iconColor: Colors.red[700],
  //       ),
  //       _buildFeatureTile(
  //         title: "Certification Courses",
  //         icon: Icon(FontAwesomeIcons.award, color: Colors.amber[700], size: 15), // Reduced icon size
  //         onTap: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => CertificationCourses())
  //           );
  //         },
  //         iconColor: Colors.amber[700],
  //       ),
  //     ],
  //   ),
  // ),

  // _sectionHeader("Training & Activities"),
  
  // Padding(
  //   padding: const EdgeInsets.symmetric(horizontal: 16),
  //   child: GridView.count(
  //     crossAxisCount: 4, // Changed from 3 to 4
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     mainAxisSpacing: 12, // Reduced spacing
  //     crossAxisSpacing: 12, // Reduced spacing
  //     childAspectRatio: 0.9, // Adjusted for better proportions
  //     children: [
  //       _buildFeatureTile(
  //         title: "Leadership Training",
  //         icon: const Icon(Icons.play_arrow, color: Colors.red, size: 15), // Reduced icon size
  //         onTap: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => const LeadershipTrainingScreen())
  //           );
  //         },
  //         iconColor: Colors.red,
  //       ),
  //       _buildFeatureTile(
  //         title: "NDA/NCC Training",
  //         icon: const Icon(Icons.play_arrow, color: Colors.red, size: 15), // Reduced icon size
  //         onTap: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => const NDATrainingScreen())
  //           );
  //         },
  //         iconColor: Colors.red,
  //       ),
  //       _buildFeatureTile(
  //         title: "Organic Farming",
  //         icon: Image.asset(
  //           "assets/icon/organic.jpg",
  //           height: 10, // Reduced icon size
  //           color: Colors.green[700],
  //         ),
  //         onTap: () {
  //           Navigator.of(context).pushNamed(OrganicFarming.routeName);
  //         },
  //         iconColor: Colors.green[700],
  //       ),
  //       _buildFeatureTile(
  //         title: "Daily Menu",
  //         icon: Icon(Icons.food_bank, color: Colors.orange[700], size: 15), // Reduced icon size
  //         onTap: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => const Messmenu())
  //           );
  //         },
  //         iconColor: Colors.orange[700],
  //       ),
  //       _buildFeatureTile(
  //         title: "Sub-Junior Wing",
  //         icon: const Icon(Icons.sports_cricket, color: Colors.blue, size: 15), // Reduced icon size
  //         onTap: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => const Juniorwing())
  //           );
  //         },
  //         iconColor: Colors.blue,
  //       ),
  //       _buildFeatureTile(
  //         title: "Educational Trip",
  //         icon: const Icon(Icons.tour, color: Colors.blue, size: 15), // Reduced icon size
  //         onTap: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => const EducationalTrip())
  //           );
  //         },
  //         iconColor: Colors.blue,
  //       ),
  //       _buildFeatureTile(
  //         title: "Weekly Copy Stamping",
  //         icon: Icon(Icons.check_circle, color: Colors.green[700], size: 15), // Reduced icon size
  //         onTap: () {
  //           Navigator.of(context).pushNamed(WeeklyCopyStampingMain.routeName);
  //         },
  //         iconColor: Colors.green[700],
  //       ),
  //       _buildFeatureTile(
  //         title: "Sports Activities",
  //         icon: const Icon(Icons.sports_score, color: Colors.blue, size: 15), // Reduced icon size
  //         onTap: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => const DailySportsActivity())
  //           );
  //         },
  //         iconColor: Colors.blue,
  //       ),
  //       _buildFeatureTile(
  //         title: "CCTV Cameras",
  //         icon: Icon(Icons.camera, color: Colors.grey[700], size: 15), // Reduced icon size
  //         onTap: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => const CCTVCamera())
  //           );
  //         },
  //         iconColor: Colors.grey[700],
  //       ),
  //     ],
  //   ),
  // ),

  // _sectionHeader("Additional Resources"),
  
  // Padding(
  //   padding: const EdgeInsets.symmetric(horizontal: 16),
  //   child: GridView.count(
  //     crossAxisCount: 4, // Changed from 3 to 4
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     mainAxisSpacing: 12, // Reduced spacing
  //     crossAxisSpacing: 12, // Reduced spacing
  //     childAspectRatio: 0.9, // Adjusted for better proportions
  //     children: [
  //       _buildFeatureTile(
  //         title: "Reference",
  //         icon: Image.asset(
  //           "assets/icon/reference.png",
  //           height: 10, // Reduced icon size
  //           color: Colors.indigo[700],
  //         ),
  //         onTap: () {
  //           Navigator.of(context).pushNamed(StudentReferences.routeName);
  //         },
  //         iconColor: Colors.indigo[700],
  //       ),
  //       _buildFeatureTile(
  //         title: "Science Experiments",
  //         icon: Icon(FontAwesomeIcons.flask, color: Colors.teal[700], size: 15), // Reduced icon size
  //         onTap: () {
  //           Navigator.of(context).pushNamed(ScienceExperiment.routeName);
  //         },
  //         iconColor: Colors.teal[700],
  //       ),
  //       _buildFeatureTile(
  //         title: "Recorded Classes",
  //         icon: Icon(Icons.movie, color: Colors.red[700], size: 15), // Reduced icon size
  //         onTap: () {
  //           Navigator.of(context).pushNamed(MyCourses.routeName);
  //         },
  //         iconColor: Colors.red[700],
  //       ),
  //     ],
  //   ),
  // ),
],
            // Students Dashboard (if logged in)
            if (flag) ...[
              _sectionHeader("Students Dashboard"),
              
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Students",
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          if (user_id == "573")
                            IconButton(
                              onPressed: () {
                                _showMyDialog();
                              },
                              icon: Icon(Icons.search, color: accentColor),
                              tooltip: "Search Students",
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    
                    if (students.isNotEmpty || recentStudents.isNotEmpty) ...[
                      if (user_id == "573" && recentStudents.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            "Recent Students",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentStudents.length,
                          itemBuilder: (context, index) {
                            return _buildStudentListItem(recentStudents[index]);
                          },
                        ),
                        const Divider(),
                      ],

                      if (students.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            "All Students",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            return _buildStudentListItem(students[index]);
                          },
                        ),
                      ],

                      if (students.isEmpty && (user_id != "573" || recentStudents.isEmpty)) ...[
                        _buildDashboardTile(),
                      ],
                    ]
                     else ...[
                      _buildDashboardTile(),
                    ],
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              
              // Account Management Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        CommonService.logout();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          LoginScreen.routeName, 
                          (r) => false
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    OutlinedButton.icon(
                      onPressed: () async {
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Account'),
                            content: const Text(
                              'Are you sure you want to delete your account? This action cannot be undone.',
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (result == true) {
                          deleteAccount();
                        }
                      },
                      icon: const Icon(Icons.delete_forever),
                      label: const Text("Delete Account"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper method to build info tiles
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: accentColor, size: 15),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: secondaryTextColor,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  // Helper method to build student list items
Widget _buildStudentListItem(Map<String, dynamic> item) {
  final normalizedItem = {
    "user_id": item["user_id"]?.toString() ?? item["id"]?.toString() ?? "0",
    "first_name": item["first_name"] ?? "Unknown",
    "last_name": item["last_name"] ?? "",
    "class_for": item["class_for"] ?? item["class"] ?? "Not Available",
    ...item,
  };

  return ListTile(
    leading: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(Icons.person, color: accentColor, size: 20),
    ),
    title: Text(
      "${normalizedItem["first_name"]} ${normalizedItem["last_name"]}",
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: textColor,
        fontSize: 14,
      ),
    ),
    subtitle: Text(
      "Class: ${normalizedItem["class_for"]}",
      style: TextStyle(
        color: secondaryTextColor,
        fontSize: 12,
      ),
    ),
    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    onTap: () {
      Navigator.of(context).pushNamed(
        Dashboard.routeName,
        arguments: normalizedItem,
      );
    },
  );
}


  // Helper method to build dashboard tile
  Widget _buildDashboardTile() {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.dashboard, color: accentColor),
      ),
      title: Text(
        user_name,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(
        "Career Dashboard",
        style: TextStyle(
          color: secondaryTextColor,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: secondaryTextColor),
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => const Dashboard2())
        );
      },
    );
  }

  // Search dialog
  _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Search Student',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: 400,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
                labelText: 'Enter Student Name/Register Mobile No.',
                labelStyle: TextStyle(color: secondaryTextColor),
                prefixIcon: Icon(Icons.search, color: accentColor),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: secondaryTextColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () {
                submit();
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }
}
