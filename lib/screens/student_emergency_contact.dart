import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StudentEmergencyContact extends StatefulWidget {
  static const routeName = '/StudentEmergencyContact';

  const StudentEmergencyContact({Key? key}) : super(key: key);

  @override
  State<StudentEmergencyContact> createState() => _StudentEmergencyContactState();
}

class _StudentEmergencyContactState extends State<StudentEmergencyContact> with SingleTickerProviderStateMixin {
  dynamic data = {};
  var school_id = "1";
  var email = 'careerdefenceschool@gmail.com';
  late TabController _tabController;
  final List<String> _categories = ['All', 'Service Managers', 'Administration', 'Academic', 'Medical'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    
    // Set system UI overlay style for a more immersive experience
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _callNumber(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch dialer for $number'))
      );
    }
  }
  
  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch email for $email'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 22.h,
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.indigo.shade800,
                          Colors.indigo.shade600,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Container(
                            height: 12.h,
                            width: 12.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          left: -30,
                          bottom: -30,
                          child: Container(
                            height: 15.h,
                            width: 15.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(3.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Emergency Contacts',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Hi, ${data['first_name'] ?? 'Parents'}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                'Available from 9AM to 4PM',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: EdgeInsets.only(left: 3.h, bottom: 1.h),
                  title: innerBoxIsScrolled
                      ? Text(
                          'Emergency Contacts',
                          style: TextStyle(
                            color: Colors.indigo.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        )
                      : null,
                ),
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: Colors.indigo.shade800,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 10.sp,
                  ),
                  indicatorColor: Colors.indigo.shade800,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: _categories.map((category) => Tab(text: category)).toList(),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: _categories.map((category) {
              return _buildContactList(category);
            }).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => _buildEmergencyInfoSheet(),
          );
        },
        backgroundColor: Colors.indigo.shade800,
        child: const Icon(Icons.info_outline, color: Colors.white),
      ),
    );
  }

  Widget _buildEmergencyInfoSheet() {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(3.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Emergency Information',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade800,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.h),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 2.h),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Important Notice',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Please contact these numbers only in case of emergency.',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Text(
              'School Email',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 1.h),
            InkWell(
              onTap: () => _sendEmail(email),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: Colors.indigo.shade800,
                    ),
                    SizedBox(width: 1.h),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.indigo.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Office Hours',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.indigo.shade800,
                  ),
                  SizedBox(width: 1.h),
                  Text(
                    '9:00 AM - 4:00 PM (Monday - Friday)',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(
      begin: 1.0,
      end: 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuad,
    );
  }

  Widget _buildContactList(String category) {
    // Filter contacts based on category
    List<Map<String, String>> contacts = _getContactsByCategory(category);
    
    return contacts.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off_outlined,
                  size: 40.sp,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 2.h),
                Text(
                  'No contacts found',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(2.h),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return _buildContactCard(
                name: contact['name']!,
                designation: contact['designation']!,
                email: contact['email']!,
                phone: contact['phone']!,
                index: index,
              );
            },
          );
  }

  Widget _buildContactCard({
    required String name,
    required String designation,
    required String email,
    required String phone,
    required int index,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showContactOptions(name, designation, email, phone),
          child: Padding(
            padding: EdgeInsets.all(2.h),
            child: Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: _getAvatarColor(index),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name.substring(0, 1),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 2.h),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        designation,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.indigo.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(1.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone_outlined,
                    color: Colors.green,
                    size: 18.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
      .fadeIn(duration: const Duration(milliseconds: 300))
      .slideX(begin: 0.1, end: 0, duration: const Duration(milliseconds: 300));
  }

  void _showContactOptions(String name, String designation, String email, String phone) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(3.h),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 3.h),
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: Colors.indigo.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.substring(0, 1),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade800,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              name,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              designation,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.indigo.shade700,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.phone,
                  label: 'Call',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    _callNumber(phone);
                  },
                ),
                _buildActionButton(
                  icon: Icons.message,
                  label: 'SMS',
                  color: Colors.orange,
                  onTap: () async {
                    Navigator.pop(context);
                    final Uri smsUri = Uri(scheme: 'sms', path: phone);
                    await launchUrl(smsUri);
                  },
                ),
                _buildActionButton(
                  icon: Icons.email,
                  label: 'Email',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _sendEmail(email);
                  },
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_outlined,
                    color: Colors.grey.shade700,
                  ),
                  SizedBox(width: 1.h),
                  Text(
                    phone,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(width: 2.h),
                  Icon(
                    Icons.copy_outlined,
                    color: Colors.indigo.shade700,
                    size: 14.sp,
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ).animate().slideY(
        begin: 1.0,
        end: 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuad,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(2.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAvatarColor(int index) {
    List<Color> colors = [
      Colors.indigo.shade800,
      Colors.blue.shade700,
      Colors.teal.shade700,
      Colors.green.shade700,
      Colors.amber.shade700,
      Colors.orange.shade700,
      Colors.red.shade700,
      Colors.purple.shade700,
    ];
    return colors[index % colors.length];
  }

  List<Map<String, String>> _getContactsByCategory(String category) {
    List<Map<String, String>> allContacts = [];
    
    // School 1 contacts
    if (school_id == "1") {
      allContacts.addAll([
        {
          'name': 'Ms Neha Sood',
          'designation': 'Administrative Officer',
          'email': 'careerdefenceschool@gmail.com',
          'phone': '9996600233',
          'category': 'Administration',
        },
        {
          'name': 'Ms Soniya',
          'designation': 'Principal Office',
          'email': 'careerdefenceschool@gmail.com',
          'phone': '8569828065',
          'category': 'Administration',
        },
        // {
        //   'name': 'Ms Bhavna Harnot',
        //   'designation': 'Pocket Money',
        //   'email': 'careerdefenceschool@gmail.com',
        //   'phone': '9996699868',
        //   'category': 'Administration',
        // },
        {
          'name': 'Ms Kavita',
          'designation': 'Form Department',
          'email': 'formhelpcareer@gmail.com',
          'phone': '8307246153',
          'category': 'Administration',
        },
        {
          'name': 'Ms Renu Chopra',
          'designation': 'Academic Head',
          'email': 'careerdefenceschool@gmail.com',
          'phone': '9996600288',
          'category': 'Academic',
        },
        {
          'name': 'Ms Ritika',
          'designation': 'School Reception',
          'email': 'careerdefenceschool@gmail.com',
          'phone': '8950268710',
          'category': 'Administration',
        },
        {

          'name': 'Ms Harleen Sandhu',
          'designation': 'Service Manager Patiala',
          'email': 'patialacds@gmail.com',
          'phone': '9817297761',
          'category': 'Service Managers',
        },
         {

          'name': 'Ms Shivani Kashyap',
          'designation': 'Service Manager Yamunanagar',
          'email': 'cdsyamunanagar@gmail.com',
          'phone': '9878898391',
          'category': 'Service Managers',
        },
         {

          'name': 'Ms Nikita',
          'designation': 'Service Manager Ambala',
          'email': 'careerdefenceschool@gmail.com',
          'phone': '7496963282',
          'category': 'Service Managers',
        },
        {
          'name': 'Dr. Manjula Saini',
          'designation': 'Doctor',
          'email': 'careerdefenceschool@gmail.com',
          'phone': '7496963293',
          'category': 'Medical',
        },
      ]);
    }
    
    // School 2 contacts
    else if (school_id == "2") {
      allContacts.addAll([
        {
          'name': 'Er Gagan Wadhwa',
          'designation': 'Administrative Officer',
          'email': 'patialacds@gmail.com',
          'phone': '9814088841',
          'category': 'Administration',
        },
        {
          'name': 'Mr. Chaman',
          'designation': 'Principal office',
          'email': 'patialacds@gmail.com',
          'phone': '9254048360',
          'category': 'Administration',
        },
        {
          'name': 'Patiala Pocket Money',
          'designation': 'Incharge No',
          'email': 'patialacds@gmail.com',
          'phone': '9254995177',
          'category': 'Administration',
        },
        {
          'name': 'Ms. Kavita',
          'designation': 'Form Dept.',
          'email': 'formhelpcareer@gmail.com',
          'phone': '8307246153',
          'category': 'Administration',
        },
        {
          'name': 'Ms. Isha Oberai',
          'designation': 'Admission Head',
          'email': 'patialacds@gmail.com',
          'phone': '9254048357',
          'category': 'Academic',
        },
        {
          'name': 'Ms. Manpreet Kaur',
          'designation': 'School Reception',
          'email': 'patialacds@gmail.com',
          'phone': '9254027515',
          'category': 'Administration',
        },
        {
          'name': 'Mr Milap',
          'designation': 'Chief Warden',
          'email': 'patialacds@gmail.com',
          'phone': '9254995157',
          'category': 'Hostel',
        },
        {
          'name': 'Dr. Manjula Saini',
          'designation': 'Doctor',
          'email': 'patialacds@gmail.com',
          'phone': '9254048362',
          'category': 'Medical',
        },
      ]);
    }
    
    // School 3 contacts
    else if (school_id == "3") {
      allContacts.addAll([
        // {
        //   'name': 'Mr Amit Pundir',
        //   'designation': 'Administrative Officer',
        //   'email': 'cdsyamunanagar@gmail.com',
        //   'phone': '7496963310',
        //   'category': 'Administration',
        // },
        // {
        //   'name': 'Ms. Gagan',
        //   'designation': 'Admission Head',
        //   'email': 'cdsyamunanagar@gmail.com',
        //   'phone': '7088776688',
        //   'category': 'Administration',
        // },
        {
          'name': 'Mr. Milap',
          'designation': 'Super 50 Sports Head',
          'email': 'cdsyamunanagar@gmail.com',
          'phone': '7087423804',
          'category': 'Academic',
        },
        {
          'name': 'Mr. Suman',
          'designation': 'Super 50 Academic Head',
          'email': 'cdsyamunanagar@gmail.com',
          'phone': '7496963285',
          'category': 'Academic',
        },
        {
          'name': 'Ms Anuradha',
          'designation': 'Pocket Money',
          'email': 'cdsyamunanagar@gmail.com',
          'phone': '7496963292',
          'category': 'Administration',
        },
        {
          'name': 'Mr Harsh',
          'designation': 'Academic Head',
          'email': 'cdsyamunanagar@gmail.com',
          'phone': '9254031742',
          'category': 'Academic',
        },
        {
          'name': 'Ms. Yugti',
          'designation': 'School Reception',
          'email': 'cdsyamunanagar@gmail.com',
          'phone': '7496963308',
          'category': 'Administration',
        },
        {
          'name': 'Mr Anil Suppahiya',
          'designation': 'Chief Warden',
          'email': 'cdsyamunanagar@gmail.com',
          'phone': '7496963289',
          'category': 'Hostel',
        },
        {
          'name': 'Mr Vikas Limba',
          'designation': 'Warden Jr Boys',
          'email': 'cdsyamunanagar@gmail.com',
          'phone': '7496963287',
          'category': 'Hostel',
        },
        {
          'name': 'Mr Sukhreet',
          'designation': 'Warden Sr. Boys',
          'email': 'cdsyamunanagar@gmail.com',
          'phone': '7496963288',
          'category': 'Hostel',
        },
        {
          'name': 'Dr. Manjula Saini',
          'designation': 'Doctor',
          'email': 'cdsyamunanagar@gmail.com',
          'phone': '7496963293',
          'category': 'Medical',
        },
        {
          'name': 'Ms. Kavita',
          'designation': 'Form Dept.',
          'email': 'formhelpcareer@gmail.com',
          'phone': '8307246153',
          'category': 'Administration',
        },
      ]);
    }
    
    // Filter contacts based on category
    if (category == 'All') {
      return allContacts;
    } else {
      return allContacts.where((contact) => contact['category'] == category).toList();
    }
  }
}
