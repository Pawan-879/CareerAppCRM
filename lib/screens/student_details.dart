import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:careerapp/screens/pdf_viewer.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';


class StudentDetails extends StatefulWidget {
  static const routeName = '/studentdetails';

  const StudentDetails({Key? key}) : super(key: key);

  @override
  State<StudentDetails> createState() => _StudentDetailsState();
}

class _StudentDetailsState extends State<StudentDetails> with SingleTickerProviderStateMixin {
  var data;
  var loan_data;
  var load_type = '';
  late List<bool> isSelected;
  final bool _customTileExpanded = false;
  var personal_details = true;
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  var student_detail = {
    "cds_tc": "",
    "cds_report_card": "",
    "cds_slc_no": "",
    "last_school_tc": ""
  };

  @override
  void initState() {
    super.initState();
    isSelected = [true, false];
    
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
    
    _animationController.forward();
    
    // Simulate data loading delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  getData(String id) async {
    print("Fetching data for user ID: $id");
    
    try {
      // First API call
      var res = await ApiService.getMethod3("/getStudentCDSDetails?user_id=$id");
      print("Response from /getStudentCDSDetails:");
      print(res.body);

      dynamic d = jsonDecode(res.body);
      if (mounted) {
        setState(() {
          student_detail["cds_tc"] = d["data"]["cds_tc"] ?? '';
          student_detail["cds_report_card"] = d["data"]["cds_report_card"] ?? '';
          student_detail["cds_slc_no"] = d["data"]["cds_slc_no"] ?? '';
          student_detail["last_school_tc"] = d["data"]["last_school_tc"] ?? '';
        });
      }

      // Second API call
      var res2 = await ApiService.getMethod3("/getStudentLoans?user_id=$id");
      print("Response from /getStudentLoans:");
      print(res2.body);

      dynamic d2 = jsonDecode(res2.body);
      if (mounted) {
        setState(() {
          load_type = d2["data"]["loan_type"] ?? '';
          loan_data = d2["data"] ?? '';
          print("Parsed loan data:");
          print(loan_data);
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context)?.settings.arguments;
    getData(data["id"]);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF3949AB),
        title: const Text(
          "Student Details",
          style: TextStyle(
            fontSize: 20.0, 
            fontWeight: FontWeight.w600,
            color: Colors.white
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF3949AB),
          statusBarIconBrightness: Brightness.light,
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.share, color: Colors.white),
        //     onPressed: () {
        //       // Share functionality
        //     },
        //   ),
        // ],
      ),
      body: isLoading 
        ? _buildLoadingShimmer() 
        : FadeTransition(
            opacity: _fadeAnimation,
            child: _buildBody(),
          ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildProfileHeader(),
        _buildInfoCard(),
        const SizedBox(height: 16),
        _buildTabSelector(),
        const SizedBox(height: 16),
        personal_details
          ? _buildPersonalDetailsSection()
          : _buildSchoolDetailsSection(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF3949AB),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Hero(
            tag: 'profile-${data["id"]}',
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CachedNetworkImage(
                  imageUrl: "${ApiService.websiteUrl}ads/profileimg.png",
                  height: 100.0,
                  width: 100.0,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3949AB)),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "${data["first_name"]} ${data["last_name"]}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data["father_name"].toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Session: ${data["batch"]}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
           if (data["city"] != null) const SizedBox(height: 8),
          if (data["city"] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      data["city"],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          if (data["address"] != null) const SizedBox(height: 8),
          if (data["address"] != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      data["address"],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          // const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Color(0xFF4CAF50),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Class",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data["class_for"],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 70,
              width: 1,
              color: Colors.grey.withOpacity(0.3),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.phone,
                      color: Color(0xFF2196F3),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Contact",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                 Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      '(Main No.) ${data["mobile"]} (Father)',
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4CAF50),
      ),
    ),
    const SizedBox(height: 1),
    Text(
      '(Other No.) ${data["mother_mobile"]} (Mother)',
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE91E63),
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
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      personal_details = true;
                      isSelected = [true, false];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: personal_details ? const Color(0xFF3949AB) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "Personal Details",
                        style: TextStyle(
                          color: personal_details ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      personal_details = false;
                      isSelected = [false, true];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !personal_details ? const Color(0xFF3949AB) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "School Details",
                        style: TextStyle(
                          color: !personal_details ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildPersonalDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildExpandableCard(
            title: 'Basic Details',
            icon: Icons.person,
            iconColor: const Color(0xFF3949AB),
            backgroundColor: const Color(0xFFE8EAF6),
            content: _basic_details(data),
          ),
          const SizedBox(height: 16),
          _buildExpandableCard(
            title: 'Student Loan Details',
            icon: Icons.account_balance,
            iconColor: const Color(0xFF4CAF50),
            backgroundColor: const Color(0xFFE8F5E9),
            content: _loan_details(load_type, loan_data),
          ),
          const SizedBox(height: 16),
          _buildExpandableCard(
            title: 'Parents Details',
            icon: Icons.family_restroom,
            iconColor: const Color(0xFFFF9800),
            backgroundColor: const Color(0xFFFFF3E0),
            content: _parent_details(data),
          ),
          const SizedBox(height: 16),
          _buildExpandableCard(
            title: 'Document Details',
            icon: Icons.description,
            iconColor: const Color(0xFF9C27B0),
            backgroundColor: const Color(0xFFF3E5F5),
            content: _documents(data),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolDetailsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildExpandableCard(
            title: 'Last School Details',
            icon: Icons.history_edu,
            iconColor: const Color(0xFF2196F3),
            backgroundColor: const Color(0xFFE3F2FD),
            content: _last_school_details(data),
          ),
          const SizedBox(height: 16),
          _buildExpandableCard(
            title: 'Current School Details',
            icon: Icons.school,
            iconColor: const Color(0xFF3949AB),
            backgroundColor: const Color(0xFFE8EAF6),
            content: _cds_school_details(data),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: const Color(0xFF3949AB),
          ),
        ),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          childrenPadding: const EdgeInsets.all(16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [content],
        ),
      ),
    );
  }

  Widget _basic_details(item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem("Date of Birth", item["dob"].toString()),
        _buildDetailItem("Gender", item["gender"].toString()),
        _buildDetailItem("Blood Group", item["blood_group"].toString()),
        _buildDetailItem("Religion", item["religion"].toString()),
      ],
    );
  }

  Widget _loan_details(loadType, item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem(
          "Loan Type", 
          loadType != '' 
            ? (item["loan_type"] == "1" 
                ? "Document for Salaried Person" 
                : "Document for Business Family")
            : "Not Selected"
        ),
        
        _buildDocumentItem(
          "Bank Statement",
          loadType != '' && item["bank_statement"] != null,
          () {
            if (loadType != '' && item["bank_statement"] != null) {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/student_loan_documents/" +
                  item["bank_statement"]);
            }
          }
        ),
        
        _buildDocumentItem(
          "Pan Card",
          loadType != '' && item["pen_card"] != null,
          () {
            if (loadType != '' && item["pen_card"] != null) {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/student_loan_documents/" +
                  item["pen_card"]);
            }
          }
        ),
        
        _buildDocumentItem(
          "Gas Copy",
          loadType != '' && item["gas_copy"] != null,
          () {
            if (loadType != '' && item["gas_copy"] != null) {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/student_loan_documents/" +
                  item["gas_copy"]);
            }
          }
        ),
        
        _buildDocumentItem(
          "Business Proof",
          loadType != '' && item["business_proof"] != null,
          () {
            if (loadType != '' && item["business_proof"] != null) {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/student_loan_documents/" +
                  item["business_proof"]);
            }
          }
        ),
        
        _buildDocumentItem(
          "Electricity Bill",
          loadType != '' && item["electricity_bill"] != null,
          () {
            if (loadType != '' && item["electricity_bill"] != null) {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/student_loan_documents/" +
                  item["electricity_bill"]);
            }
          }
        ),
      ],
    );
  }

  Widget _parent_details(item) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EAF6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person, size: 16, color: Color(0xFF3949AB)),
                        SizedBox(width: 4),
                        Text(
                          "Father's Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3949AB),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailItem("Name", item["father_name"].toString()),
                  _buildDetailItem("Qualification", item["father_qual"].toString()),
                  _buildDetailItem("Annual Income", item["father_annual_income"].toString()),
                  _buildDetailItem("Occupation", item["father_occup"].toString(), maxLines: 3),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person, size: 16, color: Color(0xFFE91E63)),
                        SizedBox(width: 4),
                        Text(
                          "Mother's Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailItem("Name", item["mother_name"].toString()),
                  _buildDetailItem("Qualification", item["mother_qual"].toString()),
                  _buildDetailItem("Annual Income", item["mother_annual_income"].toString()),
                  _buildDetailItem("Occupation", item["mother_occup"].toString(), maxLines: 3),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _documents(item) {
    return Column(
      children: [
        _buildDocumentListItem(
          "Student Aadhar Card",
          item["aadhar_card"] != null && item["aadhar_card"] != '',
          () {
            if (item["aadhar_card"] != null && item["aadhar_card"] != '') {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/students_documents/aadhar_card/" +
                  item["aadhar_card"]);
            }
          },
        ),
        
        _buildDocumentListItem(
          "Father Aadhar Card",
          item["father_id"] != null && item["father_id"] != '',
          () {
            if (item["father_id"] != null && item["father_id"] != '') {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/students_documents/father_id/" +
                  item["father_id"]);
            }
          },
        ),
        
        _buildDocumentListItem(
          "Mother Aadhar Card",
          item["mother_id"] != null && item["mother_id"] != '',
          () {
            if (item["mother_id"] != null && item["mother_id"] != '') {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/students_documents/mother_id/" +
                  item["mother_id"]);
            }
          },
        ),
         _buildDocumentListItem(
          "Father Passport Photo",
          item["father_img"] != null && item["father_img"] != '',
          () {
            if (item["father_img"] != null && item["father_img"] != '') {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/students_documents/father_img/" +
                  item["father_img"]);
            }
          },
        ),

        _buildDocumentListItem(
          "Mother Passport Photo",
          item["mother_img"] != null && item["mother_img"] != '',
          () {
            if (item["mother_img"] != null && item["mother_img"] != '') {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/students_documents/mother_img/" +
                  item["mother_img"]);
            }
          },
        ),
        
        _buildDocumentListItem(
          "DOB Certificate",
          item["dob_cert_upload"] != null && item["dob_cert_upload"] != '',
          () {
            if (item["dob_cert_upload"] != null && item["dob_cert_upload"] != '') {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/students_documents/dob_cert_upload/" +
                  item["dob_cert_upload"]);
            }
          },
        ),
        
        _buildDocumentListItem(
          "Domicile Certificate",
          item["domicile_certificate"] != null && item["domicile_certificate"] != '',
          () {
            if (item["domicile_certificate"] != null && item["domicile_certificate"] != '') {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/students_documents/domicile_certificate/" +
                  item["domicile_certificate"]);
            }
          },
        ),
        
        _buildDocumentListItem(
          "Category Certificate",
          item["category_certificate"] != null && item["category_certificate"] != '',
          () {
            if (item["category_certificate"] != null && item["category_certificate"] != '') {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/students_documents/category_certificate/" +
                  item["category_certificate"]);
            }
          },
        ),
        
        _buildDocumentListItem(
          "Student Sign",
          item["student_sign_upload"] != null && item["student_sign_upload"] != '',
          () {
            if (item["student_sign_upload"] != null && item["student_sign_upload"] != '') {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/students_documents/student_sign_upload/" +
                  item["student_sign_upload"]);
            }
          },
        ),
        
        _buildDocumentListItem(
          "Student Left Thumb",
          item["student_left_thumb"] != null && item["student_left_thumb"] != '',
          () {
            if (item["student_left_thumb"] != null && item["student_left_thumb"] != '') {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/students_documents/student_left_thumb/" +
                  item["student_left_thumb"]);
            }
          },
        ),
        
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFB300), width: 1),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFFFFB300)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Important Note: Upload Original Scanned Documents Only",
                  style: TextStyle(
                    color: Color(0xFF795548),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _last_school_details(item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem("Last School Name", item["last_school_name"].toString()),
        _buildDetailItem("Last School Class", item["last_attended_class"].toString()),
        _buildDetailItem("Last School Address", item["last_school_address"].toString()),
        _buildDetailItem("Last School Percent Marks", item["last_school_percent_marks"].toString()),
        _buildDetailItem("Last School Board", item["last_school_board"].toString()),
        
        _buildDocumentItem(
          "Last School Report Card",
          item["report_card"] != null && item["report_card"] != '',
          () {
            if (item["report_card"] != null && item["report_card"] != '') {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/students_documents/report_card/" +
                  item["report_card"]);
            }
          }
        ),
        
        _buildDocumentItem(
          "Last School SLC No",
          item["last_school_tc"] != null && item["last_school_tc"] != '',
          () {
            if (item["last_school_tc"] != null && item["last_school_tc"] != '') {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/students_documents/last_school_tc/" +
                  item["last_school_tc"]);
            }
          }
        ),
        
        _buildDetailItem("Apaar ID", item["apaar_id"].toString()),
        _buildDetailItem("Pen No.", item["pen_no"].toString()),
      ],
    );
  }

  Widget _cds_school_details(item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDocumentItem(
          "CDS TC",
          student_detail["cds_tc"] != null && student_detail["cds_tc"] != 'null',
          () {
            if (student_detail["cds_tc"] != null && student_detail["cds_tc"] != 'null') {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/students_documents/cds_tc/${student_detail["cds_tc"]}");
            }
          }
        ),
        
        _buildDocumentItem(
          "CDS Report Card",
          student_detail["cds_report_card"] != null && student_detail["cds_report_card"] != 'null',
          () {
            if (student_detail["cds_report_card"] != null && student_detail["cds_report_card"] != 'null') {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/students_documents/cds_report_card/${student_detail["cds_report_card"]}");
            }
          }
        ),
        
        _buildDocumentItem(
          "CDS SLC No.",
          student_detail["cds_slc_no"] != null && student_detail["cds_slc_no"] != 'null',
          () {
            if (student_detail["cds_slc_no"] != null && student_detail["cds_slc_no"] != 'null') {
              launch("${ApiService.careerdefenceacademy2}includes/uploads/students_documents/cds_slc_no/${student_detail["cds_slc_no"]}");
            }
          }
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, {int maxLines = 2}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String label, bool isAvailable, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isAvailable ? "Available" : "Not Available",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isAvailable ? const Color(0xFF4CAF50) : Colors.red,
                ),
              ),
            ],
          ),
          if (isAvailable)
            ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text("View"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3949AB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentListItem(String title, bool isAvailable, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isAvailable ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isAvailable ? Icons.description : Icons.close,
            color: isAvailable ? const Color(0xFF4CAF50) : Colors.red,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        trailing: isAvailable
            ? IconButton(
                icon: const Icon(
                  Icons.visibility,
                  color: Color(0xFF3949AB),
                ),
                onPressed: onTap,
              )
            : const Text(
                "Not Available",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        dense: true,
      ),
    );
  }
}