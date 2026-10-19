import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:careerapp/screens/student_details.dart';
import 'package:careerapp/screens/student_medical_report.dart';
import 'package:careerapp/screens/student_weekly_report.dart';
import 'package:careerapp/screens/parents_faqs.dart';
import 'package:careerapp/screens/student_import_updates.dart';
import 'package:sizer/sizer.dart';

class Dashboard2 extends StatefulWidget {
  static const routeName = '/Dashboard2';

  const Dashboard2({Key? key}) : super(key: key);

  @override
  State<Dashboard2> createState() => _Dashboard2State();
}

class _Dashboard2State extends State<Dashboard2> {
  var user = {};
  var full_name = "Loading...";
  var user_phone = "";
  var studyingin = "";

  // You must define your theme colors
  final Color errorColor = Colors.red;
  final Color warningColor = Colors.orange;
  final Color primaryColor = Colors.blue;
  final Color successColor = Colors.green;
  final Color secondaryColor = Colors.deepPurple;

  // Simulated flag (update as per your actual logic)
  final bool flag_recorded_class = true;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      var userData = json.decode(prefs.getString('userData')!);
      full_name = userData["user_name"].toString().toUpperCase();
      user_phone = userData["user_phone"].toString().toUpperCase();
      studyingin = userData["studyingin"].toString().toUpperCase();
      user = userData;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f4f4),
      appBar: AppBar(
        title: const Text("Dashboard",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 15),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(children: [
        _buildHeader(),
        SizedBox(
          width: 200,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(5),
              backgroundColor: Colors.teal[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
            ),
            child: const Text('Important Updates', style: TextStyle(fontSize: 12)),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StudentImportUpdates()));
            },
          ),
        ),
        const SizedBox(height: 10),
        _buildGridSections(context),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              "${ApiService.websiteUrl}ads/profileimg.png",
              height: 90,
              width: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text("Student Name: $full_name",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          Text("Studying: $studyingin",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text("Phone: $user_phone",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildGridSections(BuildContext context) {
    List<List<Widget>> allRows = [
      [
        _buildMenuItem(Icons.person_outline, "Student Details", StudentDetails.routeName),
        _buildMenuItem(Icons.medical_services_outlined, "Medical Report", StudentMedicalReport.routeName, color: errorColor),
        _buildMenuItem(Icons.phone_in_talk_outlined, "Emergency No.", StudentWeeklyReport.routeName, color: warningColor),
        _buildMenuItem(Icons.help_outline, "Parents FAQ", ParentsFaqs.routeName),
        // _buildMenuItem(Icons.medical_services_outlined, "Medical Tips", MedicalTips.routeName),
        // _buildMenuItem(FontAwesomeIcons.graduationCap, "Syllabus", SyllabusUpdate.routeName),
        // _buildMenuItem(FontAwesomeIcons.graduationCap, "Daily Sports Activity", DailySportsActivity.routeName),
        // _buildMenuItem(FontAwesomeIcons.graduationCap, "Student Results", StudentResults.routeName),
        // _buildMenuItem(FontAwesomeIcons.graduationCap, "Parents FAQ", 
        // ParentsFaqs.routeName),
        // _buildMenuItem(FontAwesomeIcons.graduationCap, "Science Experiments", ScienceExperiments.routeName),
        // _buildMenuItem(FontAwesomeIcons.graduationCap, "Unique Features", UniqueFeatures.routeName),
      ],
      // Add more rows as needed...
    ];

    return Column(
      children: allRows
          .map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 2.w,
                  mainAxisSpacing: 2.w,
                  childAspectRatio: 0.9,
                  children: row,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String route,
      {Color color = Colors.black}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(route, arguments: user);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
