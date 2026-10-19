import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:sizer/sizer.dart';
import 'package:photo_view/photo_view.dart';

class StudentCallingReport extends StatefulWidget {
  static const routeName = '/StudentCallingReports';

  const StudentCallingReport({Key? key}) : super(key: key);

  @override
  _StudentCallingReportState createState() => _StudentCallingReportState();
}

class _StudentCallingReportState extends State<StudentCallingReport>
    with SingleTickerProviderStateMixin {
  var data6 = [];
  var resolutionData = [];
  var heading = "Student Calling Report";
  var userData;
  var user_id;
  Color textColor = const Color(0xff2A2E48);
  String incharge = '';
  dynamic data = {};
  late TabController _tabController;
  List weeklyReportData = [];
  List weeklyMedicalData = [];
  bool isLoading = false;

  // Enhanced color scheme
  final Color primaryColor = const Color(0xFF6366F1);
  final Color secondaryColor = const Color(0xFF8B5CF6);
  final Color accentColor = const Color(0xFF06B6D4);
  final Color successColor = const Color(0xFF10B981);
  final Color warningColor = const Color(0xFFF59E0B);
  final Color errorColor = const Color(0xFFEF4444);
  final Color surfaceColor = const Color(0xFFF8FAFC);
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // _tabController = TabController(length: 2, vsync: this);

    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)!.settings.arguments;
      getCallReport();
      setState(() {});
    });
  }

  getCallReport() async {
    setState(() => isLoading = true);
    try {
      var res = await ApiService.getMethod3("/getCallingReport?user_id=" + data["id"]);
      dynamic d = jsonDecode(res.body);

      if (d["error"] == false) {
        setState(() {
          data6 = d["data"];
          // incharge = data6.isNotEmpty ? data6[0]["incharge"].trim() : '';
        });
      }
    } catch (e) {
      print("Error fetching call report: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

 getWeeklyReport() async {
  setState(() => isLoading = true);
  print("Fetching weekly report for user_id: ${data["id"]}..."); // Log start

  try {
    var res = await ApiService.getMethod3("/getWeeklyCalling?user_id=${data["id"]}");
    dynamic d = jsonDecode(res.body);
    
    print("Weekly report response: $d"); // Log full response

    if (d["error"] == false) {
      setState(() {
        weeklyReportData = d["data"];
      });
      print("Weekly report data set successfully."); // Log success
    } else {
      print("Error from API: ${d["message"] ?? "Unknown error"}"); // Log API error
    }
  } catch (e) {
    print("Error fetching weekly report: $e"); // Log catch block error
  } finally {
    setState(() => isLoading = false);
    print("Finished fetching weekly report."); // Log end
  }
}

 getWeeklyMedicalReport() async {
  setState(() => isLoading = true);
  print("Fetching weekly report for user_id: ${data["id"]}..."); // Log start

  try {
    var res = await ApiService.getMethod3("/getWeeklymedicalCalling?user_id=${data["id"]}");
    dynamic d = jsonDecode(res.body);
    
    print("Weekly report response: $d"); // Log full response

    if (d["error"] == false) {
      setState(() {
        weeklyMedicalData = d["data"];
      });
      print("Weekly report data set successfully."); // Log success
    } else {
      print("Error from API: ${d["message"] ?? "Unknown error"}"); // Log API error
    }
  } catch (e) {
    print("Error fetching weekly report: $e"); // Log catch block error
  } finally {
    setState(() => isLoading = false);
    print("Finished fetching weekly report."); // Log end
  }
}

  getCallResolution() async {
    setState(() => isLoading = true);
    try {
      var res = await ApiService.getMethod3("/getCallingResolution?id=" + data["id"]);
      print(res.body);
      if (res.body.isEmpty) {
        print("Error: Empty response from server.");
        return;
      }
      dynamic d = jsonDecode(res.body);
      if (d["error"] == false) {
        setState(() {
          resolutionData = d["data"];
        });
      }
    } catch (e) {
      print("Exception in getCallResolution: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar
          SliverAppBar(
            expandedHeight: 20.h,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, secondaryColor],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 1.h),
                      Icon(
                        Icons.assessment_outlined,
                        size: 6.h,
                        color: Colors.white,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Student Reports',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      Text(
                        'Comprehensive Communication Overview',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w400,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: Container(
              margin: EdgeInsets.all(1.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Enhanced Top Card
                _buildEnhancedTopCard(),
                
                // Enhanced Tab Bar
                _buildEnhancedTabBar(),
                
                // Tab Content
                SizedBox(
                  height: 60.h,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCallResolutionTab(),
                      // _buildCallReportTab(),
                      _buildWeeklyReportTab(),
                       _buildWeeklyMedicalReportTab()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTopCard() {
    return Container(
      margin: EdgeInsets.all(2.h),
      padding: EdgeInsets.all(2.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor.withOpacity(0.1), accentColor.withOpacity(0.2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.support_agent_outlined,
              size: 6.h,
              color: accentColor,
            ),
          ),
          SizedBox(width: 2.h),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Class Incharge',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  incharge.isEmpty ? 'Not Assigned' : incharge,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 1.h, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Communication Hub Active',
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: successColor,
                      fontWeight: FontWeight.w600,
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

  Widget _buildEnhancedTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.h),
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
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 10.sp),
        tabs: [
          Tab(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz_outlined, size: 2.h),
                SizedBox(height: 0.3.h),
                const Text("Complaint \nResolutions", textAlign: TextAlign.center),
              ],
            ),
          ),
          // Tab(
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Icon(Icons.call_outlined, size: 2.h),
          //       SizedBox(height: 0.5.h),
          //       Text("Call Reports", textAlign: TextAlign.center),
          //     ],
          //   ),
          // ),
          Tab(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_view_week_outlined, size: 2.h),
                SizedBox(height: 0.5.h),
                const Text("Weekly \nFeedback", textAlign: TextAlign.center),
              ],
            ),
          ),
           Tab(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_view_week_outlined, size: 2.h),
                SizedBox(height: 0.5.h),
                const Text("Weekly \nMedical", textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
        onTap: (index) {
          if (index == 0 && resolutionData.isEmpty) {
            getCallResolution();
          }
          if (index == 1 && weeklyReportData.isEmpty) {
            getWeeklyReport();
          }
           if (index == 2 && weeklyMedicalData.isEmpty) {
            getWeeklyMedicalReport();
          }
        },
      ),
    );
  }

Widget _buildWeeklyMedicalReportTab() {
  if (isLoading) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
      ),
    );
  }

  return weeklyMedicalData.isNotEmpty
      ? ListView.builder(
          padding: EdgeInsets.all(2.h),
          itemCount: weeklyMedicalData.length,
          itemBuilder: (context, index) {
            return _buildEnhancedWeeklyItem(weeklyMedicalData[index]);
          },
        )
      : _buildEmptyState(
          icon: Icons.medical_services_outlined,
          title: "No Medical Reports",
          subtitle: "Weekly medical reports will appear here",
        );
}

  Widget _buildCallReportTab() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      );
    }

    return data6.isNotEmpty
        ? ListView.builder(
            padding: EdgeInsets.all(2.h),
            itemCount: data6.length,
            itemBuilder: (context, index) {
              return _buildEnhancedCallItem(data6[index]);
            },
          )
        : _buildEmptyState(
            icon: Icons.call_outlined,
            title: "No Call History",
            subtitle: "Call reports will appear here once available",
          );
  }

  Widget _buildCallResolutionTab() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      );
    }

    return resolutionData.isNotEmpty
        ? ListView.builder(
            padding: EdgeInsets.all(2.h),
            itemCount: resolutionData.length,
            itemBuilder: (context, index) {
              return _buildEnhancedResolutionItem(context, resolutionData[index]);
            },
          )
        : _buildEmptyState(
            icon: Icons.quiz_outlined,
            title: "No Resolutions",
            subtitle: "Complaint resolutions will appear here",
          );
  }

  Widget _buildWeeklyReportTab() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      );
    }

    return weeklyReportData.isNotEmpty
        ? ListView.builder(
            padding: EdgeInsets.all(2.h),
            itemCount: weeklyReportData.length,
            itemBuilder: (context, index) {
              return _buildEnhancedWeeklyItem(weeklyReportData[index]);
            },
          )
        : _buildEmptyState(
            icon: Icons.calendar_view_week_outlined,
            title: "No Weekly Reports",
            subtitle: "Weekly remarks will appear here",
          );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(3.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 6.h,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCallItem(item) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withOpacity(0.7)],
                ),
              ),
              child: Icon(
                Icons.call_received,
                size: 3.h,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item["relation"]?.trim() ?? 'Unknown',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 0.8.h),
                          Row(
                            children: [
                              Icon(Icons.phone, size: 1.5.h, color: Colors.grey.shade600),
                              SizedBox(width: 0.5.h),
                              Text(
                                item["mobile"] ?? 'No phone',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 1.5.h, color: Colors.grey.shade600),
                              SizedBox(width: 0.5.h),
                              Text(
                                DateFormat('dd MMM yyyy').format(DateTime.parse(item["date"])),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 1.h, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Incoming',
                            style: TextStyle(
                              color: successColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 9.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 1.5.h, color: Colors.grey.shade600),
                            SizedBox(width: 0.5.h),
                            Text(
                              item["duration"]?.trim() ?? '0:00',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildEnhancedWeeklyItem(item) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(2.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
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
                padding: EdgeInsets.all(1.h),
                decoration: BoxDecoration(
                  color: warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.note_alt_outlined,
                  color: warningColor,
                  size: 2.h,
                ),
              ),
              SizedBox(width: 1.h),
              Expanded(
                child: Text(
                  "Weekly Remarks",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Container(
            padding: EdgeInsets.all(1.5.h),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              item["remarks"] ?? "No remarks available",
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.black.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 1.5.h, color: Colors.grey.shade600),
              SizedBox(width: 0.5.h),
              Text(
                DateFormat('dd MMM yyyy').format(DateTime.parse(item["created_at"])),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedResolutionItem(BuildContext context, Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Header with gradient
            Container(
              padding: EdgeInsets.all(2.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor.withOpacity(0.1), secondaryColor.withOpacity(0.1)],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(1.h),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.quiz_outlined,
                      color: Colors.white,
                      size: 2.5.h,
                    ),
                  ),
                  SizedBox(width: 1.5.h),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Resolution Case",
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(DateTime.parse(item["created_at"])),
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 1.2.h, vertical: 0.6.h),
                    decoration: BoxDecoration(
                      color: successColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Resolved",
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(2.h),
              child: Column(
                children: [
                  // Question Section
                  _buildQASection(
                    icon: Icons.help_outline,
                    iconColor: errorColor,
                    title: "Question",
                    content: item["question"] ?? "No Question",
                    isQuestion: true,
                  ),
                  
                  SizedBox(height: 2.h),
                  
                  // Answer Section
                  _buildQASection(
                    icon: Icons.lightbulb_outline,
                    iconColor: successColor,
                    title: "Answer",
                    content: item["answer"] ?? "No Answer",
                    isQuestion: false,
                  ),
                  
                  // Proof Section
                  if (item["proof_file"] != null && item["proof_file"].isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => _buildEnhancedProofViewer(context, item["proof_file"]),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(1.5.h),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: accentColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.attachment, color: accentColor, size: 2.h),
                            SizedBox(width: 1.h),
                            Text(
                              "View Attached Proof",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.open_in_new, color: accentColor, size: 1.8.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQASection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required bool isQuestion,
  }) {
    return Container(
      padding: EdgeInsets.all(1.5.h),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(0.8.h),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 2.h),
              ),
              SizedBox(width: 1.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            content,
            style: TextStyle(
              fontSize: isQuestion ? 12.sp : 11.sp,
              fontWeight: isQuestion ? FontWeight.w600 : FontWeight.w500,
              color: Colors.black.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedProofViewer(BuildContext context, String proofFile) {
    String fullUrl = "https://careerdefenceacademy.com/$proofFile";
    bool isImage = proofFile.toLowerCase().endsWith('.jpg') ||
                   proofFile.toLowerCase().endsWith('.png') ||
                   proofFile.toLowerCase().endsWith('.jpeg');

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(2.h),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.attachment, color: Colors.white, size: 2.5.h),
                  SizedBox(width: 1.h),
                  Expanded(
                    child: Text(
                      "Attached Proof",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isImage
                  ? PhotoView(
                      imageProvider: NetworkImage(fullUrl),
                      backgroundDecoration: const BoxDecoration(color: Colors.white),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 6.h,
                            color: errorColor,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "Unsupported file format",
                            style: TextStyle(
                              color: errorColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}