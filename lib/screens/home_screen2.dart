import 'package:careerapp/screens/leads.dart';
// import 'package:careerapp/screens/pdf_viewer.dart';
// import 'package:careerapp/screens/pdf_viewer2.dart';
import 'package:careerapp/screens/staff_salary.dart';
import 'package:careerapp/screens/student_import_updates.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../services/api_services.dart';
import 'dashboard.dart';
import 'dashboard2.dart';
import 'appointments.dart' show Appointments;

class Home2 extends StatefulWidget {
  const Home2({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _Home2State createState() => _Home2State();
}

class _Home2State extends State<Home2> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var defaultCourse = "Not Working";
  var user_name = "Guest\n";
  var students = [];
  var class_name = "Guest";
  var user_id = '0';
  var userData;
  var flag = false;
  var textcontroller = TextEditingController();
  var type = "";
  var tab_name = "";
  late TabController _tabController;
  var data = [];
  var allleads = [];
  var filteredStudents = [];
  var myleads = [];
  final _authData = {'id': '', 'status': '', 'remark': '', 'staff_id': ''};
  final scrollController = ScrollController();
  var staff_id, category;
  var page = 1;
  var full_name = "";
  var user_phone = "";
  var dob, doj;
  var user_phone2 = "";
  var class_for = "";
  var section_assigned = "";
  // var createdAt = "";
  String? createdAt;

  var staffData;

  @override
  void initState() {
    super.initState();
     _tabController = TabController(length: 2, vsync: this);
    getUserData();
    // loadData();
  }

 Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('staffData')) {
      staffData = json.decode(prefs.getString('staffData')!);
      print("staffData: $staffData");
      staff_id = staffData["user_id"];
      full_name = staffData["name"];
      user_phone = staffData["mobile"];
      user_phone2 = staffData["mobile2"];
     class_for = staffData['class_assigned'] ?? '';
section_assigned = staffData['section_assigned'] ?? '';

      dob = staffData["dob"] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(staffData["dob"])) : null;
      doj = staffData["doj"] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(staffData["doj"])) : null;
      createdAt = staffData["createdAt"] != null
    ? DateFormat('dd MMM yyyy').format(DateTime.parse(staffData["createdAt"]))
    : null; // ❌ assigning null to non-nullable


      await loadData();
      setState(() {});
    }
  }

 Future<void> loadData() async {
    if (class_for.isEmpty) return;
    var res = await ApiService.getMethod('/getmystudentsClass?class=$class_for');
    var body = jsonDecode(res.body);
    if (body['status'] == '1') {
      students = body['detail'];
      var seen = <String>{};
      students = students.where((s) => seen.add(s['user_id'])).toList();
      filteredStudents = List.from(students);
    } else {
      students = [];
    }
    setState(() {});
  }
  void filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredStudents = students;
      });
    } else {
      setState(() {
        filteredStudents = students.where((student) {
          return student['first_name'].toLowerCase().contains(query.toLowerCase()) ||
              student['class'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF5F7FA),
    appBar: AppBar(
      backgroundColor: Colors.white,
      title: const Text("Staff Dashboard", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),),
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.blueAccent,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blueAccent,
     tabs: const [
  Tab(
    icon: Icon(Icons.assignment_outlined, size: 14), // smaller icon
    child: Text(
      "Staff Activity",
      style: TextStyle(fontSize: 10), // smaller text
    ),
  ),
  Tab(
    icon: Icon(Icons.dashboard_customize_outlined, size: 14),
    child: Text(
      "Students Dashboard",
      style: TextStyle(fontSize: 10),
    ),
  ),
],

      ),
    ),
    body: TabBarView(
      controller: _tabController,
      children: [
        _buildStaffActivityTab(),
        _buildStudentsDashboardTab(),
      ],
    ),
  );
}

  Widget _buildStaffActivityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProfileCard(),
        const SizedBox(height: 10),
        _buildQuickActions(),
        const SizedBox(height: 10),
        _buildStaffActivitySection(),
      ],
    );
  }

  Widget _buildStudentsDashboardTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStudentsDashboard(),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A73E8), Color(0xFF6C92F4)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    "assets/65.png",
                    fit: BoxFit.contain,
                    height: 40,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      full_name.isNotEmpty ? full_name : "Staff Member",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Staff ID: ${staff_id ?? 'N/A'}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.cake_outlined, color: Colors.white, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          dob != null ? "DOB: $dob" : 'DOB: Not available',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 16),
                        const SizedBox(width: 5),
                       Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
   Text(
  doj != null ? "DOJ: $doj" : 'DOJ: Not available',
  style: TextStyle(
    color: Colors.white.withOpacity(0.9),
    fontSize: 12,
  ),
),
if (createdAt != null && staffData?["createdAt"] != null) ...[
  const SizedBox(height: 3),
  Text(
    _getDurationSinceCreatedAt(staffData!["createdAt"]),
    style: TextStyle(
      color: Colors.greenAccent.shade100,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  ),
],
  ],
),

                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final Uri whatsappUrl = Uri.parse("https://wa.me/$user_phone");
                    if (await canLaunchUrl(whatsappUrl)) {
                      await launchUrl(whatsappUrl);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          user_phone.isNotEmpty ? user_phone : "N/A",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final Uri phoneUrl = Uri.parse("tel:$user_phone2");
                    if (await canLaunchUrl(phoneUrl)) {
                      await launchUrl(phoneUrl);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone, color: Colors.blue, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          user_phone2.isNotEmpty ? user_phone2 : "N/A",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            title: "Important\nUpdates",
            icon: Icons.announcement_outlined,
            color: const Color(0xFF00BFA5),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StudentImportUpdates()),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            title: "Staff Policy",
            icon: Icons.policy_outlined,
            color: const Color(0xFF5C6BC0),
            onTap: () {
              dynamic data5 = {
                'course_id': '',
                'link': 'https://www.careerdefenceschool.com/pdf/staff-policy.pdf',
                'filename': 'Staff Policy',
              };
              // Navigator.of(context).pushNamed(PDFViewer2.routeName, arguments: data5);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffActivitySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A73E8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: Color(0xFF1A73E8),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Staff Activity Report",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildActivityCard(
                title: "My Leads",
                icon: Icons.contacts,
                color: const Color(0xFF4CAF50),
                onTap: () {
                  Navigator.of(context).pushNamed(Leads.routeName, arguments: staffData);
                },
              ),
              _buildActivityCard(
                title: "Salary Details",
                icon: FontAwesomeIcons.moneyBill,
                color: const Color(0xFFF57C00),
                onTap: () {
                  Navigator.of(context).pushNamed(StaffSalary.routeName, arguments: {});
                },
              ),

              _buildActivityCard(
                title: "Appointments",
                icon: Icons.event_available,
                color: const Color(0xFF009688),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return Appointments();
                      },
                    ),
                  );
                },
              ),
              _buildActivityCard(
                title: "Reports",
                icon: LineIcons.calendar,
                color: const Color(0xFF7B1FA2),
                onTap: () {},
              ),
              _buildActivityCard(
                title: "Incentives",
                icon: FontAwesomeIcons.sackDollar,
                color: const Color(0xFFD32F2F),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsDashboard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A73E8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.people_outline,
                      color: Color(0xFF1A73E8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Students Dashboard",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black87),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: StudentSearchDelegate(students),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Student Name",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  "Class",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
Text(
  "Total Students: ${filteredStudents.length}",
  style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: Colors.black87,
  ),
),
          const SizedBox(height: 10),
          filteredStudents.isNotEmpty
              ? SizedBox(
                  height: 300,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildStudentListItem(context, filteredStudents[index], index),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Dashboard2()),
                    );
                  },
                  child:
                   Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "No students found. Tap to go to dashboard.",
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildStudentListItem(BuildContext context, dynamic item, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(Dashboard.routeName, arguments: item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: index.isEven ? Colors.white : const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
      width: 20,
      child: Text(
        '${index + 1}.',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  item["first_name"][0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF1A73E8),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${item["first_name"]} ${item["last_name"] ?? ''}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "ID: ${item["user_id"]}",
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item["class"],
                style: const TextStyle(
                  color: Color(0xFF1A73E8),
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

class StudentSearchDelegate extends SearchDelegate {
  final List students;
  StudentSearchDelegate(this.students);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = students.where((student) {
      return student['first_name'].toLowerCase().contains(query.toLowerCase()) ||
          student['class'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    final seenIds = <String>{};
    final uniqueResults = results.where((student) => seenIds.add(student['user_id'])).toList();

    return Container(
      color: const Color(0xFFF5F7FA),
      child: ListView.builder(
        itemCount: uniqueResults.length,
        itemBuilder: (context, index) {
          final item = uniqueResults[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF1A73E8).withOpacity(0.1),
                child: Text(
                  item['first_name'][0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF1A73E8),
                    fontWeight: FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ),
              title: Text(
                '${item['first_name']} ${item['last_name'] ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 8),
              ),
              subtitle: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A73E8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item['class'],
                      style: const TextStyle(
                        color: Color(0xFF1A73E8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).pushNamed(Dashboard.routeName, arguments: item);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = students.where((student) {
      return student['first_name'].toLowerCase().contains(query.toLowerCase()) ||
          student['class'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    final seenIds = <String>{};
    final uniqueSuggestions = suggestions.where((student) => seenIds.add(student['user_id'])).toList();

    return Container(
      color: const Color(0xFFF5F7FA),
      child: ListView.builder(
        itemCount: uniqueSuggestions.length,
        itemBuilder: (context, index) {
          final item = uniqueSuggestions[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF1A73E8).withOpacity(0.1),
                child: Text(
                  item['first_name'][0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF1A73E8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
             title: Text(
  '${item['first_name']} ${item['last_name'] ?? ''}',
  style: const TextStyle(fontWeight: FontWeight.w600),
),

              subtitle: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A73E8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item['class'],
                      style: const TextStyle(
                        color: Color(0xFF1A73E8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).pushNamed(Dashboard.routeName, arguments: item);
              },
            ),
          );
        },
      ),
    );
  }
}
String _getDurationSinceCreatedAt(String? dateStr) {
  if (dateStr == null) return 'Duration not available';
  final createdDate = DateTime.tryParse(dateStr);
  if (createdDate == null) return 'Invalid date';

  final now = DateTime.now();
  int years = now.year - createdDate.year;
  int months = now.month - createdDate.month;

  if (months < 0) {
    years -= 1;
    months += 12;
  }

  return '$years year${years != 1 ? 's' : ''} and $months month${months != 1 ? 's' : ''}';
}

