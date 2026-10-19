import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransferCertificateScreen extends StatefulWidget {
  static const routeName = '/transfer-certificate';

  const TransferCertificateScreen({Key? key}) : super(key: key);

  @override
  State<TransferCertificateScreen> createState() => _TransferCertificateScreenState();
}

class _TransferCertificateScreenState extends State<TransferCertificateScreen> {
  Map<String, dynamic> studentData = {};
  bool isLoading = true;
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchStudentDetails();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void fetchStudentDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('userData')) {
        final userData = json.decode(prefs.getString('userData')!);
        final userId = userData["user_id"];

        print("Fetching data for user_id: $userId");

        var res = await ApiService.getMethod3("/getStudentDetail?user_id=$userId");

        print("Response Status Code: ${res.statusCode}");
        print("Response Body: ${res.body}");

        if (res.statusCode == 200) {
          final body = jsonDecode(res.body);

          if (body != null && body["data"] != null) {
            setState(() {
              studentData = body["data"];
              isLoading = false;
            });
          } else {
            print("Empty or invalid response data.");
            setState(() {
              isLoading = false;
            });
          }
        } else {
          print("Failed to load student data. Status: ${res.statusCode}");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("No userData found in SharedPreferences");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching student data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return '';
    }
  }

  String getValue(String? val) => val != null && val.isNotEmpty ? val : '';

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Show success dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Request Submitted'),
          content: const Text('Your transfer certificate request has been submitted successfully. You will be notified once it is processed.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String getAcademicSession(String? doj) {
    if (doj == null) return '';
    try {
      final date = DateTime.parse(doj);
      final year = date.year;
      return "$year-${year + 1}";
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Rich UI Header
                SliverAppBar(
                  expandedHeight: 200.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      "Transfer Certificate",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 3.0,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                    background: Container(
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
                      child: Stack(
                        children: [
                          Positioned(
                            right: 20,
                            bottom: 60,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    getValue("${studentData['first_name'] ?? ''} ${studentData['last_name'] ?? ''}".trim()),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    "Class: ${getValue(studentData['class_for'])}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    "ID: ${getValue(studentData['user_id'].toString())}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            bottom: 60,
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.school,
                                  size: 35,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Form Content
                SliverToBoxAdapter(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Address Card
                          Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "To,",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "The Principal,",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Career Defence School",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "[Campus Name or Location]",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Request for Transfer Certificate",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Student Details Card
                          Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Student Details",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  buildInfoRow(
                                    "Full Name of Student",
                                    getValue("${studentData['first_name'] ?? ''} ${studentData['last_name'] ?? ''}".trim()),
                                  ),
                                  buildInfoRow(
                                    "Father's Name",
                                    getValue(studentData['father_name']),
                                  ),
                                  buildInfoRow(
                                    "Mother's Name",
                                    getValue(studentData['mother_name']),
                                  ),
                                  buildInfoRow(
                                    "Date of Birth",
                                    formatDate(studentData['dob']),
                                  ),
                                  buildInfoRow(
                                    "Admission No.",
                                    getValue(studentData['user_id'].toString()),
                                  ),
                                  buildInfoRow(
                                    "Class & Section Last Attended",
                                    getValue(studentData['class_for']),
                                  ),
                                  buildInfoRow(
                                    "Academic Session",
                                    getAcademicSession(studentData['doj']),
                                  ),
                                  buildInfoRow(
                                    "Date of Leaving School",
                                    formatDate(studentData['doj']),
                                  ),
                                  buildInfoRow(
                                    "Any Fee Dues",
                                    studentData['balance'] == "0" ? "No" : "Yes (₹${studentData['balance']})",
                                    isHighlighted: studentData['balance'] != "0",
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Reason Field Card
                          Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Reason for Transfer",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _reasonController,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText: "Please provide reason for transfer request",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please provide a reason for transfer';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Declaration Card
                          Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Declaration",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      "I hereby request you to kindly issue the Transfer Certificate for the above-mentioned student. All dues have been cleared. I understand that this application will be processed as per the school's policy.",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Signature of Parent/Guardian",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            width: 150,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey.shade400,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Date",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat('dd/MM/yyyy').format(DateTime.now()),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
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

                          // Office Use Card
                          Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "For Office Use Only",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  buildOfficeCheckItem("No Dues Verified by Accounts"),
                                  buildOfficeCheckItem("Library Clearance"),
                                  buildOfficeCheckItem("Hostel Clearance (if applicable)"),
                                  buildOfficeCheckItem("Final Approval by Principal"),
                                  const SizedBox(height: 8),
                                  buildOfficeField("Transfer Certificate Issued on", ""),
                                  buildOfficeField("TC No.", ""),
                                  buildOfficeField("Principal's Signature & Seal", ""),
                                ],
                              ),
                            ),
                          ),

                          // Submit Button
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 30),
                            child: ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 5,
                              ),
                              child: const Text(
                                "SUBMIT REQUEST",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildInfoRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isHighlighted ? Colors.red : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOfficeCheckItem(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Icon(
                Icons.check,
                size: 16,
                color: Colors.transparent,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget buildOfficeField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
              child: Text(
                value,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

