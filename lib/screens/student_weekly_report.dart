import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentWeeklyReport extends StatefulWidget {
  static const routeName = '/StudentWeeklyReport';

  const StudentWeeklyReport({Key? key}) : super(key: key);

  @override
  State<StudentWeeklyReport> createState() => _StudentWeeklyReportState();
}

class _StudentWeeklyReportState extends State<StudentWeeklyReport> {
  dynamic data = {};
  var school_id = "1";
  var email = '';

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      data = ModalRoute.of(context)!.settings.arguments;
      school_id = data["school_id"];

      setState(() {
        if (school_id == "1") {
          email = 'careerdefenceschool@gmail.com';
        } else if (school_id == "2") {
          email = 'patialacds@gmail.com';
        } else if (school_id == "3") {
          email = 'cdsyamunanagar@gmail.com';
        }
      });
    });
  }

  _callNumber(number) async {
    await launch("tel://" + number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 15.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Emergency Contacts",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.indigo.shade800,
                      Colors.indigo.shade500,
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 20.w, bottom: 0.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello,',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          '${data['first_name'] ?? "Student"}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(1.5.h),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.info_outline,
                              color: Colors.indigo.shade700,
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Important Notice',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo.shade800,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  'Please contact only in emergency cases',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  'Email: $email',
                                  style: TextStyle(
                                    fontSize: 13.sp, // Increased email size
                                    color: Colors.indigo.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '9AM to 4PM only',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w500,
                                    ),
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
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Text(
                          'Contact Directory',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade800,
                          ),
                        ),
                      ),
                      if (school_id == "1") _buildContactsList1(),
                      if (school_id == "2") _buildContactsList2(),
                      if (school_id == "3") _buildContactsList3(),
                      SizedBox(height: 4.h),
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

  Widget _buildContactsList1() {
    return Column(
      children: [
        _contactCard(
          name: 'Ms Nikita',
          designation: 'Service Manager',
          email: 'careerdefenceschool@gmail.com',
          phone: '7496963282',
          avatarColor: Colors.blue,
        ),
        _contactCard(
          name: 'Ms Sheetal',
          designation: 'Chief Coordinator',
          email: 'careerdefenceschool@gmail.com',
          phone: '9254031740',
          avatarColor: Colors.pink,
        ),
        _contactCard(
          name: 'Ms Ritika',
          designation: 'Chief Admissions Officer',
          email: 'careerdefenceschool@gmail.com',
          phone: '8950268710',
          avatarColor: Colors.green,
        ),
        _contactCard(
          name: 'Mrs. Manjula Saini',
          designation: '(Medical Incharge)',
          email: 'careerdefenceschool@gmail.com',
          phone: '9254031730',
          avatarColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildContactsList2() {
    return Column(
      children: [
        _contactCard(
          name: 'Ms Harleen Sandhu',
          designation: 'Service Manager',
          email: 'patialacds@gmail.com',
          phone: '9817297761',
          avatarColor: Colors.blue,
        ),
        _contactCard(
          name: 'Er Gagan Wadhwa',
          designation: 'Administrative Head',
          email: 'patialacds@gmail.com',
          phone: '7496963827',
          avatarColor: Colors.purple,
        ),
        _contactCard(
          name: 'Mr Harsh Sharma',
          designation: 'Vice Principal',
          email: 'patialacds@gmail.com',
          phone: '9254031726',
          avatarColor: Colors.green,
        ),
        _contactCard(
          name: 'Mrs. Manjula Saini',
          designation: '(Medical Incharge)',
          email: 'careerdefenceschool@gmail.com',
          phone: '7496963293',
          avatarColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildContactsList3() {
    return Column(
      children: [
        _contactCard(
          name: 'Ms. Nikita Sharma',
          designation: 'Service Manager (1st to 8th)',
          email: 'cdsyamunanagar@gmail.com',
          phone: '9878898391',
          avatarColor: Colors.blue,
        ),
        _contactCard(
          name: 'Harleen Sandhu',
          designation: 'Service Manager (9th to 12th)',
          email: 'cdsyamunanagar@gmail.com',
          phone: '9817297761',
          avatarColor: Colors.purple,
        ),
        // _contactCard(
        //   name: 'Mr Karan',
        //   designation: 'Admission Head',
        //   email: 'cdsyamunanagar@gmail.com',
        //   phone: '7496963825',
        //   avatarColor: Colors.amber,
        // ),
        _contactCard(
          name: 'Mr Suman',
          designation: 'Super 50 Coordinator',
          email: 'cdsyamunanagar@gmail.com',
          phone: '7496963825',
          avatarColor: Colors.deepOrange,
        ),
        _contactCard(
          name: 'Ms Anuradha',
          designation: 'Nursery-8th Coordinator',
          email: 'cdsyamunanagar@gmail.com',
          phone: '7087423801',
          avatarColor: Colors.indigo,
        ),
        _contactCard(
          name: 'Mrs. Manjula Saini',
          designation: '( Medical Incharge)',
          email: 'careerdefenceschool@gmail.com',
          phone: '9254031730',
          avatarColor: Colors.red,
        ),
      ],
    );
  }

  Widget _contactCard({
    required String name,
    required String designation,
    required String email,
    required String phone,
    required Color avatarColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _callNumber(phone),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: avatarColor.withOpacity(0.2),
                  child: Text(
                    name.substring(0, 1),
                    style: TextStyle(
                      color: avatarColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
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
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        designation,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.indigo.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 13.sp, // Increased email size in contact card
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.5.w),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.call,
                        color: Colors.green.shade700,
                        size: 20.sp,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        phone,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
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
}
