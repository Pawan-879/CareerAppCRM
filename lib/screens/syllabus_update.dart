import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:shimmer/shimmer.dart';

import '../services/api_services.dart';

class SyllabusUpdate extends StatefulWidget {
  static const routeName = '/syllabus_update';

  const SyllabusUpdate({Key? key}) : super(key: key);

  @override
  State<SyllabusUpdate> createState() => _SyllabusUpdateState();
}

class _SyllabusUpdateState extends State<SyllabusUpdate>
    with SingleTickerProviderStateMixin {
  List<dynamic> contentData = [];
  List<dynamic> detailsData = [];
  Map<String, dynamic>? data;
  late TabController _tabController;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Add haptic feedback when changing tabs
      HapticFeedback.lightImpact();
    });
    
    Future.delayed(Duration.zero, () {
      setState(() {
        data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      });
      getData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> getData() async {
    if (data == null) return;

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      var res = await ApiService.getMethod3(
          "/getSyllabusUpdate?class_name=${data!["class_for"]}&school_id=${data!["school_id"]}");

      dynamic d = jsonDecode(res.body);
      print("Response Data: ${res.body}");

      if (d["error"] == false) {
        setState(() {
          contentData =
              d["data"].where((item) => item["category"] == "Content").toList();
          detailsData =
              d["data"].where((item) => item["category"] == "Details").toList();
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          errorMessage = "No data found for class: ${data!["class_for"]}";
          isLoading = false;
        });
        print(errorMessage);
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = "Failed to load data. Please try again.";
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          data != null ? "Syllabus Update for ${data!["class_for"]}" : "Syllabus Update",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => getData(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF1565C0),
              indicatorWeight: 3,
              labelColor: const Color(0xFF1565C0),
              unselectedLabelColor: Colors.grey[600],
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
              tabs: const [
                Tab(
                  text: "Index Page",
                  icon: Icon(Icons.book),
                ),
                Tab(
                  text: "Chapter Wise \nSolved Imp Questions",
                  icon: Icon(Icons.info_outline),
                ),
              ],
            ),
          ),
        ),
      ),
      body: data == null
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
              ),
            )
          : isLoading
              ? _buildLoadingState()
              : hasError
                  ? _buildErrorState()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        buildList(contentData),
                        buildList(detailsData),
                      ],
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.arrow_upward),
        onPressed: () {
          // Scroll to top functionality would be implemented here
          // You would need a ScrollController for each list
        },
      ),
    );
  }

Widget _buildLoadingState() {
  return Padding(
    padding: EdgeInsets.all(4.w),
    child: ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: Container(
            height: 20.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      },
    ),
  );
}


  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 15.w,
            color: Colors.red[400],
          ),
          SizedBox(height: 2.h),
          Text(
            errorMessage,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: getData,
            icon: const Icon(Icons.refresh),
            label: const Text("Try Again"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildList(List<dynamic> listData) {
    if (listData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 15.w,
              color: Colors.grey[400],
            ),
            SizedBox(height: 2.h),
            Text(
              "No updates available",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF1565C0),
      onRefresh: getData,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: listData.length,
          itemBuilder: (context, index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(bottom: 2.h),
              child: listTile(listData[index]),
            );
          },
        ),
      ),
    );
  }

  Widget listTile(Map<String, dynamic> item) {
    List<String> fileUrls = item['image'].split(",");
    
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.blue.shade50],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.description,
                      color: const Color(0xFF1565C0),
                      size: 6.w,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['subject'],
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        // SizedBox(height: 1.h),
                         Text(
                          item['title'],
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[700],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 3.5.w,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              DateFormat('dd MMM yyyy').format(
                                  DateTime.parse(item["created_at"])),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (fileUrls.isNotEmpty && fileUrls[0].isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),
                    Text(
                      "Attachments",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 1.h),
                    SizedBox(
                      height: 15.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: fileUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(right: 2.w),
                            child: filePreview(fileUrls[index]),
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget filePreview(String fileUrl) {
    if (fileUrl.isEmpty) return const SizedBox();
    
    bool isPdf = fileUrl.toLowerCase().endsWith(".pdf");
    String fullUrl = "${ApiService.careerdefenceacademy2}/$fileUrl";

    return GestureDetector(
      onTap: () async {
        try {
          if (await canLaunch(fullUrl)) {
            await launch(fullUrl);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Could not open file"),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error opening file: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Hero(
        tag: fullUrl,
        child: Container(
          width: 25.w,
          height: 15.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: isPdf
                ? Container(
                    color: Colors.red.shade50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.picture_as_pdf,
                            color: Colors.red,
                            size: 8.w,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          "View PDF",
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: fullUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
    color: Colors.grey[300],  // Simple grey placeholder
    child: Center(
      child: Icon(
        Icons.image, // Placeholder icon
        color: Colors.grey[500],
        size: 6.w,
      ),
    ),
  ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 0.5.h,
                            horizontal: 1.w,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Text(
                            "View",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

