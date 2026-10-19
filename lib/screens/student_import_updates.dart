import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:careerapp/screens/openurl.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class StudentImportUpdates extends StatefulWidget {
  static const routeName = '/StudentImportUpdatess';

  const StudentImportUpdates({Key? key}) : super(key: key);

  @override
  _StudentImportUpdatesState createState() => _StudentImportUpdatesState();
}

class _StudentImportUpdatesState extends State<StudentImportUpdates> {
  var data6 = [];
  var heading = "Important Updates";
  var userData;
  var user_id;
  dynamic data = {};
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)!.settings.arguments;
      getData();
    });
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    
    var res = await ApiService.getMethod3("/getImportUpdates2");
    dynamic d = jsonDecode(res.body);

    if (d["error"] == false) {
      data6 = d["data"];
    }
    
    setState(() {
      isLoading = false;
    });
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 80,
            floating: false,
            pinned: true,
            backgroundColor: Colors.indigo,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 28),
                onPressed: () async {
                  final Uri url = Uri.parse('https://careerdefenceacademy.com/HomeController/important_updates');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not launch URL')),
                    );
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                heading,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.shade800,
                          Colors.blue.shade500,
                        ],
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 0.2,
                    child: Image.asset(
                      'assets/icon/update.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Introduction section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/icon/update.png',
                          height: 10.h,
                          width: 10.h,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stay Updated',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                                color: Colors.indigo.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'All your important updates in one place',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 1.5),
                ],
              ),
            ),
          ),
          
          // Content - Updates List
          isLoading
              ? SliverToBoxAdapter(child: _buildLoadingShimmer())
              : data6.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            Icon(
                              Icons.inbox_outlined,
                              size: 100,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No updates available',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final update = data6[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: _buildUpdateCard(update, index),
                              ),
                            ),
                          );
                        },
                        childCount: data6.length,
                      ),
                    ),
          
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard(dynamic update, int index) {
    final bool hasImage = update["image"] != null;
    final bool hasPdf = update["pdf"] != null;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.indigo.shade600,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.indigo.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                    if (index < data6.length - 1)
                      Container(
                        width: 2,
                        height: 50,
                        color: Colors.indigo.shade200,
                        margin: const EdgeInsets.only(top: 6),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date chip
                    Container(
                      margin: const EdgeInsets.only(top: 20, right: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        _formatDate(update["date"] ?? ''),
                        style: TextStyle(
                          color: Colors.indigo.shade800,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // Heading
                    Padding(
                      padding: const EdgeInsets.only(top: 14, right: 20),
                      child: Text(
                        update['heading'] ?? '',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ),
                    
                    // Image if available
                    if (hasImage)
                      GestureDetector(
                        onTap: () {
                          dynamic data3 = {
                            "school_name": "Important Update",
                            "url": "${ApiService.careerdefenceacademy2}includes/uploads/important_updates/${update["image"]}"
                          };
                          Navigator.of(context).pushNamed(OpenUrl.routeName, arguments: data3);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 16, right: 20),
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                Image.network(
                                  "${ApiService.careerdefenceacademy2}includes/uploads/important_updates/${update["image"]}",
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 220,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: double.infinity,
                                      height: 220,
                                      color: Colors.grey.shade200,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / 
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.indigo.shade400,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      height: 220,
                                      color: Colors.grey.shade200,
                                      child: Center(
                                        child: Icon(
                                          Icons.error_outline,
                                          color: Colors.red.shade400,
                                          size: 50,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Positioned(
                                  right: 12,
                                  bottom: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.zoom_in,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'View',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
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
                        ),
                      ),
                    
                    // Message content
                    Padding(
                      padding: const EdgeInsets.only(top: 16, right: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Html(
                          data: update['message'] ?? '',
                          style: {
                            "html": Style(
                              color: Colors.black87,
                              fontSize: FontSize(14.sp),
                              padding: HtmlPaddings.zero,
                              margin: Margins.zero,
                              lineHeight: LineHeight(1.5),
                            ),
                            "p": Style(
                              margin: Margins.only(bottom: 10),
                              fontSize: FontSize(14.sp),
                            ),
                            "a": Style(
                              color: Colors.indigo,
                              textDecoration: TextDecoration.underline,
                              fontSize: FontSize(14.sp),
                            ),
                            "h1": Style(
                              fontSize: FontSize(22.sp),
                              fontWeight: FontWeight.bold,
                            ),
                            "h2": Style(
                              fontSize: FontSize(20.sp),
                              fontWeight: FontWeight.bold,
                            ),
                            "h3": Style(
                              fontSize: FontSize(18.sp),
                              fontWeight: FontWeight.bold,
                            ),
                            "h4": Style(
                              fontSize: FontSize(16.sp),
                              fontWeight: FontWeight.bold,
                            ),
                            "h5": Style(
                              fontSize: FontSize(15.sp),
                              fontWeight: FontWeight.bold,
                            ),
                            "h6": Style(
                              fontSize: FontSize(14.sp),
                              fontWeight: FontWeight.bold,
                            ),
                            "li": Style(
                              fontSize: FontSize(14.sp),
                              margin: Margins.only(bottom: 6),
                            ),
                            "strong": Style(
                              fontWeight: FontWeight.bold,
                            ),
                          },
                        ),
                      ),
                    ),
                    
                    // PDF button if available
                    if (hasPdf)
                      Padding(
                        padding: const EdgeInsets.only(top: 20, right: 20, bottom: 20),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            launchUrl(Uri.parse(
                              "${ApiService.careerdefenceacademy2}includes/uploads/important_updates/${update["pdf"]}"
                            ));
                          },
                          icon: const Icon(Icons.picture_as_pdf, size: 24),
                          label: const Text('View PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            textStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    
                    if (!hasPdf)
                      const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}