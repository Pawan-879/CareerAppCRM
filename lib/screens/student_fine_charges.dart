import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:careerapp/services/api_services.dart';
import 'dart:convert';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shimmer/shimmer.dart';

class StudentFineCharges extends StatefulWidget {
  static const routeName = '/StudentFineCharges';

  const StudentFineCharges({super.key});

  @override
  _StudentFineChargesState createState() => _StudentFineChargesState();
}

class _StudentFineChargesState extends State<StudentFineCharges> with SingleTickerProviderStateMixin {
  var data6 = [];
  var userData;
  var user_id;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Modern color scheme
  Color primaryColor = const Color(0xFF3E64FF);
  Color accentColor = const Color(0xFF5EDFFF);
  Color textColor = const Color(0xFF2A2E48);
  Color cardColor = Colors.white;
  Color backgroundColor = const Color(0xFFF8F9FE);
  Color highlightColor = const Color(0xFFFF5E5E);
  
  String incharge = '';
  dynamic data = {};
  double amount = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Setup animations
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
    
    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)!.settings.arguments;
      getData(data["id"]);
    });
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  getData(id) async {
    setState(() {
      isLoading = true;
    });
    
    try {
      var res = await ApiService.getMethod3("/getFineCharges?user_id=" + id);
      dynamic d = jsonDecode(res.body);
      data6 = d["data"];
      
      amount = 0; // Reset amount before calculating
      for (var element in data6) {
        amount = amount + double.parse(element["amount"].toString());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to load data. Please try again.'),
          backgroundColor: highlightColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.white),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.refresh, size: 16, color: Colors.white),
            ),
            onPressed: () {
              if (data != null && data["id"] != null) {
                getData(data["id"]);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient and pattern
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
              ),
            ),
            child: const Opacity(
              opacity: 0.1,
              child: GridPattern(color: Colors.white),
            ),
          ),
          
          // Main content container with curved top
          Container(
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.only(top: 16.h),
            width: double.infinity,
            height: 84.h,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(40),
              ),
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
          ),
          
          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 4.w,
                        right: 4.w,
                        top: 0.h,
                        bottom: 2.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Student Fine Charges',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontSize: 18.sp,
                            ),
                          ),
                          // Text(
                          //   'Fine Charges',
                          //   style: TextStyle(
                          //     color: Colors.white,
                          //     fontWeight: FontWeight.bold,
                          //     fontSize: 18.sp,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Top card with total amount
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, (1 - _animationController.value) * 50),
                                child: Opacity(
                                  opacity: _animationController.value,
                                  child: child,
                                ),
                              );
                            },
                            child: topCard(),
                          ),
                          
                          // Section title
                          Padding(
                            padding: EdgeInsets.only(left: 2.w, top: 3.h, bottom: 1.h),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'All Details',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${data6.length} Items',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // List of fine charges
                          isLoading
                              ? loadingShimmer()
                              : data6.isEmpty
                                  ? emptyState()
                                  : ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: data6.length,
                                      itemBuilder: (context, index) {
                                        return AnimatedBuilder(
                                          animation: _animationController,
                                          builder: (context, child) {
                                            // Staggered animation for list items
                                            final itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                                              CurvedAnimation(
                                                parent: _animationController,
                                                curve: Interval(
                                                  0.4 + (index * 0.1).clamp(0.0, 0.6),
                                                  1.0,
                                                  curve: Curves.easeOut,
                                                ),
                                              ),
                                            );
                                            
                                            return Transform.translate(
                                              offset: Offset(0, (1 - itemAnimation.value) * 50),
                                              child: Opacity(
                                                opacity: itemAnimation.value,
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: listItem(data6[index]),
                                        );
                                      },
                                    ),
                          SizedBox(height: 2.h),
                        ],
                      ),
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

  Widget topCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C3E50),
            Color(0xFF4CA1AF),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CA1AF).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Fine Charges',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Rs. ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                        ),
                      ),
                      isLoading
                          ? SizedBox(
                              width: 80,
                              child:AnimatedOpacity(
  duration: const Duration(seconds: 1),
  opacity: isLoading ? 0.5 : 1.0,
  child: Container(
    height: 24,
    width: 80,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.4),
      borderRadius: BorderRadius.circular(4),
    ),
  ),
),
                            )
                          : Text(
                              amount.toStringAsFixed(2),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22.sp,
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white.withOpacity(0.8),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "These fine charges are reflected in your account. Please clear them at your earliest convenience.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
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

  Widget listItem(item) {
    final bool hasAttachment = item["attachment"] != null && item["attachment"].toString().trim().isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Show detailed view if needed
            },
            splashColor: primaryColor.withOpacity(0.1),
            highlightColor: primaryColor.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side - Reason
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.description_outlined,
                                    color: primaryColor,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Reason",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item["reason"]?.trim() ?? '-',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Right side - Date & Amount
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item["date"] == null
                                    ? '-'
                                    : DateFormat('dd MMM yyyy').format(DateTime.parse(item["date"])),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Amount',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10.sp,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Rs. ${item["amount"]?.trim() ?? '0'}",
                              style: TextStyle(
                                color: highlightColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Attachment section
                  if (hasAttachment) ...[
                    const Divider(height: 24),
                    GestureDetector(
                      onTap: () async {
                        var path = "${ApiService.careerdefenceacademy2}includes/uploads/fine_charges/" +
                            item["attachment"];
                        
                        try {
                          await launch(path);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Could not open the attachment'),
                              backgroundColor: highlightColor,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.attach_file,
                              color: primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "View Attachment",
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 10.sp,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.download,
                              color: primaryColor,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

 Widget loadingShimmer() {
  return Column(
    children: List.generate(
      3,
      (index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}


  Widget emptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         Icon(
  Icons.sentiment_satisfied_alt,
  size: 80,
  color: primaryColor,
),

          const SizedBox(height: 20),
          Text(
            'No Fine Charges',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no pending fine charges at the moment',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom grid pattern for background
class GridPattern extends StatelessWidget {
  final Color color;
  
  const GridPattern({Key? key, required this.color}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPainter(color: color),
      size: Size.infinite,
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  
  GridPainter({required this.color});
  
 @override
void paint(Canvas canvas, Size size) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = 0.5;

  const spacing = 20.0;

  for (double i = 0; i < size.width; i += spacing) {
    canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
  }

  for (double i = 0; i < size.height; i += spacing) {
    canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }
}

  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Widget loadingShimmer() {
//   return Column(
//     children: List.generate(
//       3,
//       (index) => Container(
//         margin: EdgeInsets.only(bottom: 12),
//         height: 120,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.grey[300],
//           borderRadius: BorderRadius.circular(16),
//         ),
//       ),
//     ),
//   );
// }
// Widget emptyState() {
//   return Container(
//     padding: EdgeInsets.symmetric(vertical: 40),
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(Icons.sentiment_satisfied_alt, size: 80, color: primaryColor),
//         SizedBox(height: 20),
//         Text(
//           'No Fine Charges',
//           style: TextStyle(
//             color: textColor,
//             fontWeight: FontWeight.bold,
//             fontSize: 16.sp,
//           ),
//         ),
//         SizedBox(height: 8),
//         Text(
//           'You have no pending fine charges at the moment',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: Colors.grey,
//             fontSize: 12.sp,
//           ),
//         ),
//       ],
//     ),
//   );
// }

