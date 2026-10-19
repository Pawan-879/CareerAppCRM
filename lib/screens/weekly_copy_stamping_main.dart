import 'dart:convert';
import 'package:careerapp/screens/weekly_copy_stamping.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:path/path.dart' as p;
import '../services/api_services.dart';

class WeeklyCopyStampingMain extends StatefulWidget {
  static const routeName = '/weekly_copy_stamping_main';

  const WeeklyCopyStampingMain({Key? key}) : super(key: key);

  @override
  State<WeeklyCopyStampingMain> createState() => _WeeklyCopyStampingMainState();
}

class _WeeklyCopyStampingMainState extends State<WeeklyCopyStampingMain> with SingleTickerProviderStateMixin {
  var data6 = [];
  dynamic data = {};
  late TabController _tabController;
  bool isLoading = true;

  List<dynamic> subJuniorData = [];
  List<dynamic> juniorData = [];
  List<dynamic> seniorData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)!.settings.arguments;
      getData();
    });
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    
    data6 = [];
    var res = await ApiService.getMethod3("/getWCSBySubject?class_name=" +
        data["class_for"] +
        "&school_id=" +
        data["school_id"]);
    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      data6 = d["data"];
      filterData();
    }
    
    setState(() {
      isLoading = false;
    });
  }

  filterData() {
    subJuniorData = data6.where((item) {
      int cls = int.tryParse(item['class_name'].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return cls >= 1 && cls <= 4;
    }).toList();

    juniorData = data6.where((item) {
      int cls = int.tryParse(item['class_name'].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return cls >= 5 && cls <= 8;
    }).toList();

    seniorData = data6.where((item) {
      int cls = int.tryParse(item['class_name'].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return cls >= 9 && cls <= 12;
    }).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
             backgroundColor: Colors.blue,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Weekly Copy Stamping',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: TabBar(
  controller: _tabController,
  indicatorColor: Colors.white,
  indicatorWeight: 3,
  indicatorSize: TabBarIndicatorSize.label,
  labelColor: Colors.white,
  unselectedLabelColor: Colors.white.withOpacity(0.7),
  labelStyle: TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  ),
  tabs: const [
    Tab(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Sub-Junior'),
          Text(
            'Class LKG to 4th',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    ),
    Tab(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Junior'),
          Text(
            'Class 5th to 8th',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    ),
    Tab(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Senior'),
          Text(
            'Class 9th to 12th',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    ),
  ],
),
          ),
        ),
      ),
      body: isLoading
          ? buildLoadingShimmer()
          : TabBarView(
              controller: _tabController,
              children: [
                buildList(subJuniorData),
                buildList(juniorData),
                buildList(seniorData),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: getData,
                     backgroundColor: Colors.blue,
        elevation: 4,

        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget buildLoadingShimmer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            "Loading data...",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildList(List<dynamic> dataList) {
    if (dataList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No data available",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: getData,
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
              style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,

                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: dataList.length,
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
      itemBuilder: (context, index) {
        return Hero(
          tag: 'subject_${dataList[index]['subject_name']}_${dataList[index]['class_name']}',
          child: Material(
            type: MaterialType.transparency,
            child: listTile(dataList[index]),
          ),
        );
      },
    );
  }

  Widget listTile(item) {
    var subject = item['subject_name'].replaceAll('_', ' ').toUpperCase() + " COPY STAMPING PICS";
    var type = p.extension(item['image']).toLowerCase();
    Color subjectColor = getSubjectColor(item['subject_name']);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: () {
            dynamic request = {
              "subject_name": item['subject_name'],
              "class_name": item['class_name'],
              "school_id": data['school_id'],
              "subject": subject
            };
            Navigator.of(context).pushNamed(WeeklyCopyStamping.routeName, arguments: request);
          },
          child: Padding(
            padding: EdgeInsets.all(2.w),
            child: Row(
              children: [
                Container(
                  width: 20.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: subjectColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: subjectColor.withOpacity(0.3), width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: type == ".pdf"
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.red[700],
                                  size: 32,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "PDF",
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                "${ApiService.careerdefenceacademy2}includes/uploads/weekly_copy_stamping/" + item['image'],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(subjectColor),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: subjectColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item['class_name'],
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: subjectColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        subject,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(DateTime.parse(item["created"])),
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
                Container(
                  decoration: BoxDecoration(
                    color: subjectColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: subjectColor,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color getSubjectColor(String subject) {
    // Map subjects to colors for visual distinction
    Map<String, Color> subjectColors = {
      'mathematics': Colors.blue[700]!,
      'math': Colors.blue[700]!,
      'science': Colors.green[700]!,
      'english': Colors.purple[700]!,
      'hindi': Colors.orange[700]!,
      'social_science': Colors.red[700]!,
      'social_studies': Colors.red[700]!,
      'physics': Colors.indigo[700]!,
      'chemistry': Colors.teal[700]!,
      'biology': Colors.lightGreen[700]!,
      'computer': Colors.cyan[700]!,
    };

    // Convert subject to lowercase for case-insensitive matching
    String lowerSubject = subject.toLowerCase();
    
    // Find matching subject or return a default color
    for (var key in subjectColors.keys) {
      if (lowerSubject.contains(key)) {
        return subjectColors[key]!;
      }
    }
    
    // Default color if no match found
    return Colors.blue[700]!;
  }
}

