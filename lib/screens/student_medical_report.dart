import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:careerapp/screens/openurl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:careerapp/models/stu_med-report_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class StudentMedicalReport extends StatefulWidget {
  static const routeName = '/StudentMedicalReport';

  const StudentMedicalReport({Key? key}) : super(key: key);

  @override
  _StudentMedicalReportState createState() => _StudentMedicalReportState();
}

class _StudentMedicalReportState extends State<StudentMedicalReport>
    with SingleTickerProviderStateMixin {
  // Data variables
  List<dynamic> seminarList = [];
  List<dynamic> data7 = [];
  var heading = "Medical Report";
  final bool _customTileExpanded = false;
  var userData;
  var user_id;
  StuMedReprtModel reportModel = StuMedReprtModel(data: []);
  List<StudentRep> reportList = [];
  Map<String, dynamic> data = {};
  var school_id;
  bool isLoading = true;
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // School data
  List<String> schoolNames = ['Ambala', 'Yamunanagar', 'Patiala'];
  int selected_school = 1; // Default to Ambala
  
  // Theme colors
  final Color cardColor = Colors.white;
  static const Color primaryColor = Color(0xFF1E88E5);    // More vibrant blue
  static const Color secondaryColor = Color(0xFF42A5F5);  // Lighter blue
  static const Color accentColor = Color(0xFF5E35B1);     // Deep purple
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color successColor = Color(0xFF43A047);    // Green
  static const Color warningColor = Color(0xFFEF6C00);    // Orange
  
  @override
  void initState() {
    super.initState();
    // Initialize animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    
    // Fetch data after widget is built
    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)?.settings.arguments;
      data = args is Map ? Map<String, dynamic>.from(args) : <String, dynamic>{};
      school_id = data["school_id"];
      selected_school = int.tryParse(school_id?.toString() ?? '') ?? 1;
      getData();
      getMedicalData();
      getMedicalSeminarBySchool(selected_school);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Fetch medical seminar data by school
  Future<void> getMedicalSeminarBySchool(int selectedSchool) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      var res = await ApiService.getMethod3(
          "/getMedicalSeminar?school_id=$selectedSchool");
      dynamic d = jsonDecode(res.body);

      if (d["error"] == false) {
        if (!mounted) return;
        setState(() {
          seminarList = _asList(d["data"]);
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          seminarList = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching seminar data: $e");
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch medical report data
  Future<void> getData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final studentId = data["id"]?.toString() ?? '';
      if (studentId.isEmpty) {
        reportList = [];
        return;
      }

      var res =
          await ApiService.getMethod3("/getMedicalReport?user_id=$studentId");
      dynamic d = jsonDecode(res.body);

      print("Medical Report Response: $d");

      final reportData = _asList(d["data"]);
      final reports = reportData
          .whereType<Map<String, dynamic>>()
          .map((item) {
            print("Video Field: ${item['video']}");
            return StudentRep.fromJson(item);
          })
          .toList();

      reportList = reports;

      reportModel = StuMedReprtModel(
        data: reportList,
        error: d['error'],
        status: d['status'],
      );
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }


  // Fetch additional medical data
  Future<void> getMedicalData() async {
    try {
      final studentId = data["id"]?.toString() ?? '';
      if (studentId.isEmpty) return;

      var res = await ApiService.getMethod3("/getStudentMedicalReports?user_id=$studentId");
      dynamic d = jsonDecode(res.body);
      if (!mounted) return;
      setState(() {
        data7 = _asList(d["data"]);
      });
    } catch (e) {
      print("Error fetching medical data: $e");
    }
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List) return value;
    return [];
  }

  String _safeDate(String? value) {
    if (value == null || value.isEmpty) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  // Launch phone dialer
  void _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not launch phone dialer'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Gradient background header
          _buildGradientHeader(),
          
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting section
                    _buildGreetingSection(),
                    
                    // Medical Records Card
                    _buildMedicalRecordsCard(),
                    
                    SizedBox(height: 3.h),
                    
                    // Reports Section Title (only show if not in tab view)
                    if (reportList.isNotEmpty) _buildReportsSectionTitle(),
                    
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // App Bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      title: Text(
        heading,
        style: TextStyle(
          color: Colors.white, 
          fontWeight: FontWeight.w600,
          fontSize: 20.sp, // Increased font size
          letterSpacing: 0.5,
        ),
      ),
      backgroundColor: primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white), // Increased icon size
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.white, size: 24), // Increased icon size
          onPressed: () {
            // Show help dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    const Icon(Icons.medical_information, color: primaryColor, size: 28),
                    SizedBox(width: 2.w),
                    Text('Medical Report Help', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This section shows your medical history and reports.',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'You can:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                    ),
                    SizedBox(height: 0.5.h),
                    _buildHelpItem(Icons.visibility, 'View your medical reports'),
                    _buildHelpItem(Icons.medical_services, 'Access counseling reports'),
                    _buildHelpItem(Icons.phone, 'Contact medical staff'),
                    _buildHelpItem(Icons.school, 'View medical seminars by campus'),
                  ],
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK', style: TextStyle(color: primaryColor, fontSize: 14)),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  
  // Help dialog item
  Widget _buildHelpItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: primaryColor), // Increased icon size
          SizedBox(width: 2.w),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13.sp)), // Increased font size
          ),
        ],
      ),
    );
  }
  
  // Gradient Header
  Widget _buildGradientHeader() {
    return Container(
      height: 28.h, // Slightly increased height
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.8),
            primaryColor.withOpacity(0.6),
            primaryColor.withOpacity(0.4),
            primaryColor.withOpacity(0.2),
            Colors.grey[50]!,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
        ),
      ),
    );
  }
  
  // Greeting Section
  Widget _buildGreetingSection() {
    return Padding(
      padding: EdgeInsets.all(3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello,',
            style: TextStyle(
              fontSize: 16.sp, // Increased font size
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
          Row(
            children: [
              Text(
                data['first_name']?.toString() ?? 'Student',
                style: TextStyle(
                  fontSize: 24.sp, // Increased font size
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user,
                      size: 14.sp, // Increased icon size
                      color: Colors.white,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Student',
                      style: TextStyle(
                        fontSize: 12.sp, // Increased font size
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Medical Records Card
  Widget _buildMedicalRecordsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(3.h),
        child: Column(
          children: [
            // Header with icon
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.h),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    FontAwesomeIcons.fileWaveform,
                    size: 34.sp, // Increased icon size
                    color: primaryColor,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Medical Records',
                        style: TextStyle(
                          fontSize: 16.sp, // Increased font size
                          color: textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Now In Your Hand',
                        style: TextStyle(
                          fontSize: 14.sp, // Increased font size
                          color: textPrimaryColor.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'See your entire health history',
                        style: TextStyle(
                          fontSize: 13.sp, // Increased font size
                          color: primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 2.h),
            Divider(color: Colors.grey[200], thickness: 1.5),
            SizedBox(height: 1.h),
            
            // Contact Information
            _buildContactCard(
              name: 'Mrs. Manjula Saini',
              phone: '7496963293',
              role: 'Medical Incharge',
            ),
            
            SizedBox(height: 2.h),
            
            // Tabbed content
            _buildTabbedContent(),
          ],
        ),
      ),
    );
  }
  
  // Contact Card
  Widget _buildContactCard({required String name, required String phone, required String role}) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(2.h),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryColor.withOpacity(0.1), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(1.5.h),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              color: primaryColor,
              size: 18.sp, // Increased icon size
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13.sp, // Increased font size
                    color: textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 12.sp, // Increased font size
                    color: textSecondaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _launchPhone(phone),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: successColor.withOpacity(0.3), width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.phone,
                    color: successColor,
                    size: 16.sp, // Increased icon size
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    phone,
                    style: TextStyle(
                      fontSize: 13.sp, // Increased font size
                      color: successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Tabbed Content
  Widget _buildTabbedContent() {
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: primaryColor,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: TextStyle(
                fontSize: 13.sp, // Increased font size
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 13.sp, // Increased font size
                fontWeight: FontWeight.w400,
              ),
              tabs: const [
                Tab(text: 'Medical\nReports'),
                Tab(text: 'Medical\nSeminars'),
                Tab(text: 'Medical\nTips'),
              ],
            ),
          ),
          
          SizedBox(height: 2.h),
          
          // Tab content
          SizedBox(
            height: 65.h, // Slightly increased height
            child: TabBarView(
              physics: const BouncingScrollPhysics(),
              children: [
                // First tab: Medical Reports
                isLoading
                  ? _buildShimmerLoading()
                  : reportList.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: reportList.length,
                        itemBuilder: (context, index) {
                          return _buildReportCard(report: reportList[index]);
                        },
                      ),

                // Second tab: Medical Seminars with nested tabs
                DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      // School tabs
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          labelColor: Colors.red[700],
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.red[700],
                          indicatorSize: TabBarIndicatorSize.label,
                          labelStyle: TextStyle(
                            fontSize: 11.sp, // Increased font size
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontSize: 11.sp, // Increased font size
                            fontWeight: FontWeight.w400,
                          ),
                          tabs: const [
                            Tab(text: 'Ambala Branch'),
                            Tab(text: 'Ymngr Branch'),
                            Tab(text: 'Patiala Branch'),
                          ],
                          onTap: (index) {
                            int selectedSchool = index + 1;
                            setState(() {
                              selected_school = selectedSchool;
                            });
                            getMedicalSeminarBySchool(selectedSchool);
                          },
                        ),
                      ),
                      
                      SizedBox(height: 2.h),
                      
                      // Seminar content
                      Expanded(
                        child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                              ),
                            )
                          : seminarList.isEmpty
                              ? _buildEmptySeminars()
                              : ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: seminarList.length,
                                  itemBuilder: (context, index) {
                                    var item = seminarList[index];
                                    return _buildSeminarCard(
                                      item,
                                      cardColor,
                                      primaryColor,
                                      accentColor,
                                      schoolNames,
                                      selected_school,
                                      textPrimaryColor,
                                      textSecondaryColor,
                                      secondaryColor,
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
                const MedicalTipsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Empty Seminars State
  Widget _buildEmptySeminars() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.calendarXmark,
            size: 45.sp, // Increased icon size
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            'No Seminars Found',
            style: TextStyle(
              fontSize: 16.sp, // Increased font size
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'There are no medical seminars scheduled for this campus.',
            style: TextStyle(
              fontSize: 14.sp, // Increased font size
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // Reports Section Title
  Widget _buildReportsSectionTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Your Reports',
            style: TextStyle(
              fontSize: 18.sp, // Increased font size
              color: textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${reportList.length} Reports',
              style: TextStyle(
                fontSize: 12.sp, // Increased font size
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Report Card
  Widget _buildReportCard({required StudentRep report}) {
    final reportId = report.id?.toString() ?? '';
    final reportImage = report.image?.toString() ?? '';
    final reportTitle = report.sick?.toString() ?? 'Medical Report';
    final reportUrl = "${ApiService.careerdefenceacademy2}home/medical_report/$reportId";
    final imageUrl = reportImage.isEmpty
        ? ''
        : "${ApiService.careerdefenceacademy2}includes/uploads/medical_form/$reportImage";

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              dynamic row = {
                "school_name": "Medical Report",
                "url": reportUrl
              };
              Navigator.of(context).pushNamed(OpenUrl.routeName, arguments: row);
            },
            splashColor: primaryColor.withOpacity(0.1),
            highlightColor: primaryColor.withOpacity(0.05),
            child: Padding(
              padding: EdgeInsets.all(2.h),
              child: Column(
                children: [
                  // Header row with image and details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Report Image
                      Hero(
                        tag: 'report_$reportId',
                        child: Container(
                          width: 22.w, // Slightly increased width
                          height: 14.h, // Slightly increased height
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: imageUrl.isEmpty
                                ? Container(
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[400],
                                      size: 20.sp,
                                    ),
                                  )
                                : CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(color: Colors.white),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey[400],
                                        size: 20.sp,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 3.w),
                      
                      // Report Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Report Title and Date
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    reportTitle,
                                    style: TextStyle(
                                      fontSize: 15.sp, // Increased font size
                                      color: textPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                                  decoration: BoxDecoration(
                                    color: warningColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _safeDate(report.created),
                                    style: TextStyle(
                                      fontSize: 11.sp, // Increased font size
                                      color: warningColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 1.h),
                            
                            // Fee
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'Fee: ₹${report.totalFee}',
                                style: TextStyle(
                                  fontSize: 13.sp, // Increased font size
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: 1.h),
                            
                            // Status indicator
                            Row(
                              children: [
                                Container(
                                  width: 3.w,
                                  height: 3.w,
                                  decoration: const BoxDecoration(
                                    color: successColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  'Completed',
                                  style: TextStyle(
                                    fontSize: 12.sp, // Increased font size
                                    color: successColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 2.h),
                  Divider(color: Colors.grey[200], thickness: 1.5),
                  SizedBox(height: 1.h),
                  
                  // Action Buttons
                  Row(
                    children: [
                      // View Report Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            dynamic row = {
                              "school_name": "Medical Report",
                              "url": reportUrl
                            };
                            Navigator.of(context).pushNamed(OpenUrl.routeName, arguments: row);
                          },
                          icon: Icon(Icons.remove_red_eye, size: 16.sp, color: Colors.white), // Increased icon size
                          label: Text(
                            'View Report',
                            style: TextStyle(fontSize: 13.sp), // Increased font size
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 1.2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                      
                      SizedBox(width: 2.w),
                      
                      // Counselling Report Button
                     if (report.video != null && report.video!.isNotEmpty)
  Expanded(
    child: OutlinedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoPopupPlayer(
                videoUrl: "${ApiService.careerdefenceacademy2}includes/uploads/medical_form/videos/${report.video!}",
              ),
            ),
          ),
        );
      },
      icon: Icon(Icons.play_circle_fill, size: 16.sp, color: accentColor), // Increased icon size
      label: Text(
        'Testimonial Video',
        style: TextStyle(fontSize: 13.sp), // Increased font size
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: accentColor,
        side: BorderSide(color: accentColor.withOpacity(0.5), width: 1.5),
        padding: EdgeInsets.symmetric(vertical: 1.2.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
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
  
  // Shimmer Loading Effect
  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 2.h),
            height: 20.h, // Increased height
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          );
        },
      ),
    );
  }
  
  // Empty State
  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      padding: EdgeInsets.all(3.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            FontAwesomeIcons.fileMedical,
            size: 45.sp, // Increased icon size
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            'No Medical Reports',
            style: TextStyle(
              fontSize: 18.sp, // Increased font size
              color: textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'You don\'t have any medical reports yet.',
            style: TextStyle(
              fontSize: 14.sp, // Increased font size
              color: textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          ElevatedButton.icon(
            onPressed: () {
              // Refresh data
            
              getMedicalData();
                getData();
            },
            icon: Icon(Icons.refresh, size: 16.sp), // Increased icon size
            label: Text('Refresh', style: TextStyle(fontSize: 13.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Seminar Card
  Widget _buildSeminarCard(
    dynamic item,
    Color cardColor,
    Color primaryColor,
    Color accentColor,
    List<String> schoolNames,
    int selectedSchool,
    Color textPrimaryColor,
    Color textSecondaryColor,
    Color secondaryColor,
  ) {
    final seminar = item is Map ? item : <String, dynamic>{};
    final seminarId = seminar['id']?.toString() ?? '';
    final seminarImage = seminar['image']?.toString() ?? '';
    final seminarImageUrl = seminarImage.isEmpty
        ? ''
        : "${ApiService.careerdefenceacademy2}includes/uploads/medical_seminar/$seminarImage";
    final seminarTitle = seminar['title']?.toString() ?? 'Medical Seminar';
    final seminarUrl = seminar['url']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              final uri = Uri.tryParse(seminarUrl);
              if (uri != null) {
                launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            splashColor: primaryColor.withOpacity(0.1),
            highlightColor: primaryColor.withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                Stack(
                  children: [
                    // Main image with shimmer loading
                    SizedBox(
                      height: 24.h, // Increased height
                      width: double.infinity,
                      child: Hero(
                        tag: 'medical_seminar$seminarId',
                        child: seminarImageUrl.isEmpty
                            ? _buildSeminarImageFallback()
                            : CachedNetworkImage(
                                imageUrl: seminarImageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                    color: Colors.white,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    _buildSeminarImageFallback(),
                              ),
                      ),
                    ),
                    
                    // Gradient overlay
                    Container(
                      height: 24.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                    
                    // Play button overlay
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 8.w, // Increased icon size
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Date chip
                    Positioned(
                      bottom: 1.h,
                      right: 3.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.5.w,
                          vertical: 0.6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 4.w, // Increased icon size
                              color: Colors.white,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              _safeDate(seminar["created_at"]?.toString()),
                              style: TextStyle(
                                fontSize: 11.sp, // Increased font size
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Premium badge if applicable
                    if (seminar['premium'] == '1')
                      Positioned(
                        top: 1.h,
                        left: 3.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.5.w,
                            vertical: 0.6.h,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withOpacity(0.3),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                size: 4.w, // Increased icon size
                                color: Colors.white,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Premium',
                                style: TextStyle(
                                  fontSize: 11.sp, // Increased font size
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                
                // Content area
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with animation
                      Text(
                        seminarTitle,
                        style: TextStyle(
                          fontSize: 16.sp, // Increased font size
                          fontWeight: FontWeight.w700,
                          color: textPrimaryColor,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: 1.h),
                      
                      // Tags row
                      // SingleChildScrollView(
                      //   scrollDirection: Axis.horizontal,
                      //   child: Row(
                      //     children: [
                      //       _buildTag(
                      //         icon: Icons.language_rounded,
                      //         label: 'English',
                      //         color: Colors.blue.shade700,
                      //       ),
                      //       _buildTag(
                      //         icon: Icons.school_rounded,
                      //         label: schoolNames[selected_school - 1],
                      //         color: Colors.purple.shade700,
                      //       ),
                      //       _buildTag(
                      //         icon: Icons.timer_rounded,
                      //         label: '${(item['id'].hashCode % 30) + 5} mins',
                      //         color: Colors.green.shade700,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      
                      SizedBox(height: 2.h),
                      
                      // Bottom row with additional info and view button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Additional info
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(1.w),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.update_rounded,
                                  size: 5.w, // Increased icon size
                                  color: primaryColor,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Daily Update',
                                style: TextStyle(
                                  fontSize: 12.sp, // Increased font size
                                  color: secondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          
                          // View button
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.2.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  secondaryColor,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 5.w, // Increased icon size
                                  color: Colors.white,
                                ),
                                SizedBox(width: 1.5.w),
                                Text(
                                  'View Details',
                                  style: TextStyle(
                                    fontSize: 13.sp, // Increased font size
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeminarImageFallback() {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey.shade400,
            size: 14.w,
          ),
          SizedBox(height: 1.h),
          Text(
            "Image not available",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
  
  // Tag Widget
  Widget _buildTag({required IconData icon, required String label, required Color color}) {
    return Container(
      margin: EdgeInsets.only(right: 2.w),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14.sp),
          SizedBox(width: 1.w),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class VideoPopupPlayer extends StatefulWidget {
  final String videoUrl;

  const VideoPopupPlayer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPopupPlayerState createState() => _VideoPopupPlayerState();
}

class _VideoPopupPlayerState extends State<VideoPopupPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final videoController = VideoPlayerController.network(widget.videoUrl);
      _videoPlayerController = videoController;
      await videoController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: true,
        looping: false,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Video initialization error: $e");
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError || _chewieController == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 40),
            SizedBox(height: 10),
            Text("Failed to load video", style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
      );
    }

    return Chewie(controller: _chewieController!);
  }
}

class MedicalTipsTab extends StatefulWidget {
  const MedicalTipsTab({Key? key}) : super(key: key);

  @override
  State<MedicalTipsTab> createState() => _MedicalTipsTabState();
}

class _MedicalTipsTabState extends State<MedicalTipsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEnglish = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Language switcher
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isEnglish ? "English Tips" : "हिंदी सुझाव",
                style: TextStyle(
                  fontSize: 15.sp, // Increased font size
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              Row(
                children: [
                  Switch(
                    value: _isEnglish,
                    activeThumbColor: Colors.blue,
                    onChanged: (val) {
                      setState(() => _isEnglish = val);
                    },
                  ),
                  Text(_isEnglish ? "EN" : "हिंदी", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ],
          ),
        ),

        // Tab bar
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.blue.shade700,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600), // Increased font size
          unselectedLabelStyle: TextStyle(fontSize: 13.sp), // Increased font size
          tabs: const [
            Tab(text: "Respiratory"),
            Tab(text: "Digestive"),
            Tab(text: "Nutritional"),
            Tab(text: "Allergies"),
            Tab(text: "Infections"),
          ],
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(
              5,
              (index) => _buildMedicalTipCard(index),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalTipCard(int index) {
    final tip = medicalTips[index];
    final title = _isEnglish ? tip["title"] : tip["title_hindi"];
    final causes = _isEnglish ? tip["causes"] : tip["causes_hindi"];
    final preventiveMeasures = _isEnglish ? tip["preventive_measures"] : tip["preventive_measures_hindi"];
    final medicines = _isEnglish ? tip["medicines"] : tip["medicines_hindi"];
    final videoLinks = tip["video_links"] as List<String>;

    return SingleChildScrollView(
      padding: EdgeInsets.all(3.w),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.blue.shade50,
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_getIconForIndex(index), color: Colors.white, size: 24.sp), // Increased icon size
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold), // Increased font size
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Medicines
              _buildSection(_isEnglish ? "Common Medicines:" : "सामान्य दवाएं:", medicines, Icons.medication, Colors.red),

              SizedBox(height: 2.h),
              _buildSection(_isEnglish ? "Causes:" : "कारण:", causes, Icons.warning, Colors.orange),

              SizedBox(height: 2.h),
              _buildSection(_isEnglish ? "Preventive Measures:" : "रोकथाम:", preventiveMeasures, Icons.check_circle, Colors.green),

              SizedBox(height: 2.h),
              Text(
                _isEnglish ? "Related Videos:" : "संबंधित वीडियो:",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14.sp), // Increased font size
              ),
              SizedBox(height: 1.h),

              SizedBox(
                height: 14.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: videoLinks.length,
                  itemBuilder: (context, i) => InkWell(
                    onTap: () => _launchURL(videoLinks[i]),
                    child: Container(
                      margin: EdgeInsets.only(right: 2.w),
                      width: 40.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        border: Border.all(color: Colors.red.shade300, width: 1),
                      ),
                      child: const Icon(Icons.play_circle_fill, size: 45, color: Colors.red), // Increased icon size
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 24, color: color), // Increased icon size
          SizedBox(width: 1.w),
          Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: color)), // Increased font size
        ]),
        SizedBox(height: 0.5.h),
        Text(content, style: TextStyle(fontSize: 13.sp)), // Increased font size
      ],
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.air;
      case 1:
        return Icons.restaurant;
      case 2:
        return Icons.fitness_center;
      case 3:
        return Icons.healing;
      case 4:
        return Icons.coronavirus;
      default:
        return Icons.health_and_safety;
    }
  }

  // Use the same `medicalTips` list from your provided data
 final List<Map<String, dynamic>> medicalTips = [
    {
      "title": "1️⃣ Respiratory Issues (Cough, Cold, Flu)",
      "title_hindi": "1️⃣ श्वसन संबंधी समस्याएं (खांसी, जुकाम, फ्लू)",
      "medicines": "Common Medicines: Cough Syrup, Kuff Plus, Chestencold Tab",
      "medicines_hindi": "सामान्य दवाएं: कफ सिरप, कफ प्लस, चेस्टेनकोल्ड टैब",
      "causes": "🔹 Viral infections due to close contact in hostels and classrooms\n🔹 Poor ventilation and air quality\n🔹 Seasonal changes and temperature fluctuations",
      "causes_hindi": "🔹 छात्रावास और कक्षा में नजदीकी संपर्क के कारण वायरल संक्रमण\n🔹 खराब वेंटिलेशन और वायु गुणवत्ता\n🔹 मौसमी परिवर्तन और तापमान में उतार-चढ़ाव",
      "preventive_measures": "✔ Ensure well-ventilated classrooms with proper air circulation\n✔ Conduct regular cleaning and sanitization of shared spaces\n✔ Encourage students to use handkerchiefs or tissues while coughing or sneezing\n✔ Maintain personal hygiene (e.g., frequent hand washing)\n✔ Provide immunity-boosting drinks like warm turmeric milk or herbal tea during seasonal changes\n✔ Organize health awareness programs to teach students about preventing colds and flu",
      "preventive_measures_hindi": "✔ कक्षाओं को हवादार और अच्छी वायु परिसंचरण युक्त बनाए रखें\n✔ साझा स्थानों की नियमित सफाई और सैनीटाइजेशन सुनिश्चित करें\n✔ छात्रों को खांसते या छींकते समय रूमाल या टिशू का उपयोग करने के लिए प्रोत्साहित करें\n✔ व्यक्तिगत स्वच्छता बनाए रखें (जैसे, बार-बार हाथ धोना)\n✔ प्रतिरक्षा बढ़ाने वाले पेय पदार्थ जैसे हल्दी वाला गर्म दूध या हर्बल चाय प्रदान करें\n✔ छात्रों को जुकाम और फ्लू से बचाव के उपाय सिखाने के लिए स्वास्थ्य जागरूकता कार्यक्रम आयोजित करें",
      "video_links": [
        "https://www.youtube.com/watch?v=WK3MiOX5C08",
        "https://www.youtube.com/watch?v=0XOWOY3rZ0k",
        "https://www.youtube.com/watch?v=BVfnMCamGYM&t=68s"
      ]
    },
    {
      "title": "2️⃣ Digestive Problems (Acidity, Indigestion)",
      "title_hindi": "2️⃣ पाचन संबंधी समस्याएं (अम्लता, अपच)",
      "medicines": "Common Medicines: Aciloc Tab, Aciloc-Tab",
      "medicines_hindi": "सामान्य दवाएं: एसिलोक टैब",
      "causes": "🔹 Irregular eating habits\n🔹 Consumption of oily/spicy foods\n🔹 Stress or anxiety before exams",
      "causes_hindi": "🔹 अनियमित खान-पान की आदतें\n🔹 अधिक तली-भुनी और मसालेदार चीजों का सेवन\n🔹 परीक्षा से पहले तनाव या चिंता",
      "preventive_measures": "✔ Maintain a balanced diet in hostel and school canteens\n✔ Ensure students follow regular meal timings\n✔ Introduce healthy snacks like fruits, nuts, and yogurt\n✔ Promote hydration by ensuring clean drinking water is readily available\n✔ Encourage students to eat slowly and mindfully",
      "preventive_measures_hindi": "✔ छात्रावास और स्कूल की कैंटीन में संतुलित आहार सुनिश्चित करें\n✔ छात्रों को नियमित भोजन करने के लिए प्रेरित करें\n✔ स्वस्थ नाश्ते जैसे फल, नट्स और दही की उपलब्धता सुनिश्चित करें\n✔ स्वच्छ पेयजल की उचित व्यवस्था करें\n✔ छात्रों को धीरे-धीरे और सावधानीपूर्वक खाने के लिए प्रेरित करें",
      "video_links": [
        "https://www.youtube.com/watch?v=OmvardkwIAw",
        "https://www.youtube.com/watch?v=13tAqk9VQvU",
        "https://www.youtube.com/watch?v=joQxnFpDIPE"
      ]
    },
    {
      "title": "3️⃣ Nutritional Deficiencies (Fatigue, Weakness)",
      "title_hindi": "3️⃣ पोषण की कमी (थकान, कमजोरी)",
      "medicines": "Common Medicines: TAB. Multivitamin",
      "medicines_hindi": "सामान्य दवाएं: मल्टीविटामिन टैबलेट",
      "causes": "🔹 Poor dietary intake\n🔹 Lack of fruits, vegetables, and essential nutrients\n🔹 Excessive junk food consumption",
      "causes_hindi": "🔹 अपर्याप्त आहार\n🔹 फलों, सब्जियों और आवश्यक पोषक तत्वों की कमी\n🔹 अत्यधिक जंक फूड का सेवन",
      "preventive_measures": "✔ Design a nutrient-rich menu with balanced portions of protein, carbs, and vitamins\n✔ Organize nutrition awareness programs for students and parents\n✔ Offer healthy snacks like fruit bowls, sprouts, and dry fruits in hostels\n✔ Encourage participation in physical activities to improve metabolism and energy levels",
      "preventive_measures_hindi": "✔ प्रोटीन, कार्बोहाइड्रेट और विटामिन से भरपूर संतुलित आहार योजना तैयार करें\n✔ छात्रों और अभिभावकों के लिए पोषण जागरूकता कार्यक्रम आयोजित करें\n✔ छात्रावास में स्वस्थ नाश्ते जैसे फल, स्प्राउट्स और सूखे मेवे उपलब्ध कराएं\n✔ छात्रों को खेलकूद और शारीरिक गतिविधियों में भाग लेने के लिए प्रेरित करें ताकि चयापचय (मेटाबॉलिज्म) बेहतर बना रहे",
      "video_links": [
        "https://www.youtube.com/watch?v=F67xAbembAA",
        "https://www.youtube.com/watch?v=dliMsyfmYp4",
        "https://www.youtube.com/watch?v=cPg7UYLUxWA"
      ]
    },
    {
      "title": "4️⃣ Allergies (Skin Allergy, Throat Pain)",
      "title_hindi": "4️⃣ एलर्जी (त्वचा एलर्जी, गले में दर्द)",
      "medicines": "Common Medicines: Levocetzy Tab, Monteral LC Tab",
      "medicines_hindi": "सामान्य दवाएं: लेवोसेटज़ी टैब, मोंटेरल एलसी टैब",
      "causes": "🔹 Dust, pollen, or environmental allergens\n🔹 Use of unclean bedding, curtains, or carpets\n🔹 Skin irritation from chemical products",
      "causes_hindi": "🔹 धूल, पराग या पर्यावरणीय एलर्जी\n🔹 गंदे बिस्तर, पर्दे या कालीनों का उपयोग\n🔹 रासायनिक उत्पादों से त्वचा में जलन",
      "preventive_measures": "✔ Conduct regular dusting and cleaning of dormitories and classrooms\n✔ Ensure bedding, mattresses, and curtains are washed frequently\n✔ Introduce air purifiers in classrooms and dormitories if feasible\n✔ Educate students to avoid sharing personal hygiene items like towels and combs",
      "preventive_measures_hindi": "✔ छात्रावास और कक्षाओं की नियमित धूल सफाई और सफाई सुनिश्चित करें\n✔ बिस्तर, गद्दे और पर्दों की नियमित धुलाई की व्यवस्था करें\n✔ यदि संभव हो तो कक्षाओं और छात्रावासों में एयर प्यूरीफायर लगवाएं\n✔ छात्रों को व्यक्तिगत स्वच्छता बनाए रखने और तौलिए, कंघी आदि साझा न करने की सलाह दें",
      "video_links": [
        "https://www.youtube.com/watch?v=GTJ4WWB3v1A",
        "https://www.youtube.com/watch?v=qiWiYfqeDjg",
        "https://www.youtube.com/watch?v=1PO1IbW9ojY"
      ]
    },
    {
      "title": "5️⃣ Bacterial Infections (Fever, Throat Infections, Skin Infections)",
      "title_hindi": "5️⃣ बैक्टीरियल संक्रमण (बुखार, गले का संक्रमण, त्वचा संक्रमण)",
      "medicines": "Common Medicines: Amoxy CV Tab, Zifi Tab",
      "medicines_hindi": "सामान्य दवाएं: एमॉक्सी सीवी टैब, ज़िफी टैब",
      "causes": "🔹 Close contact in hostel environments\n🔹 Poor personal hygiene\n🔹 Sharing of personal belongings",
      "causes_hindi": "🔹 छात्रावास में नजदीकी संपर्क\n🔹 व्यक्तिगत स्वच्छता की कमी\n🔹 व्यक्तिगत वस्तुओं को साझा करना",
      "preventive_measures": "✔ Introduce weekly health check-ups to identify symptoms early\n✔ Promote proper hand hygiene with regular handwashing reminders\n✔ Educate students about not sharing personal items like water bottles, towels, or razors\n✔ Ensure proper wound care facilities are available in the medical room",
      "preventive_measures_hindi": "✔ प्रारंभिक लक्षणों की पहचान के लिए साप्ताहिक स्वास्थ्य जांच करें\n✔ नियमित रूप से हाथ धोने की आदत को बढ़ावा दें\n✔ छात्रों को व्यक्तिगत वस्तुओं जैसे पानी की बोतल, तौलिया या रेजर साझा न करने के बारे में शिक्षित करें\n✔ चिकित्सा कक्ष में उचित घाव देखभाल सुविधाएं उपलब्ध कराएं",
      "video_links": [
        "https://www.youtube.com/watch?v=KUcOlfjMjGc",
        "https://www.youtube.com/watch?v=9lyzdPe8jgU",
        "https://www.youtube.com/watch?v=-aIvWxfpCco"
      ]
    },
  ];
}
