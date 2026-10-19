import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:careerapp/screens/exam_details.dart';
import 'package:careerapp/screens/login.dart';
import 'package:careerapp/screens/notifications.dart';
import 'package:careerapp/screens/our_services.dart';
import 'package:careerapp/screens/upgrade_screen.dart';
import 'package:careerapp/screens/raise_complaint.dart';

import 'package:careerapp/services/common_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:careerapp/screens/aboutus.dart';
import 'package:careerapp/screens/apply_tc.dart';

import 'package:careerapp/screens/contactus.dart';
import 'package:careerapp/screens/fillform.dart';
import 'package:careerapp/screens/feedbackform.dart';
import 'package:careerapp/screens/gaterequest.dart';
import 'package:careerapp/screens/school_fee.dart';
import 'package:careerapp/screens/faq.dart';
import 'package:careerapp/screens/allusers.dart';
import 'package:careerapp/screens/openurl.dart';
import 'package:careerapp/screens/downloads.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer>
    with SingleTickerProviderStateMixin {
  String userName = "Guest";
  String userEmail = "guest@gmail.com";
  dynamic userData;
  String studyingIn = "";
  String referral = "";
  String? userId;

  late AnimationController _controller;
  late Animation<double> _blinkAnimation;
  bool showUpgrade = true;

  @override
  void initState() {
    super.initState();
    getUserData();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _blinkAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);

    // text alternate logic
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          showUpgrade = !showUpgrade;
        });
      }
      return true;
    });
  }

  getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData') && prefs.getString('userData') != '') {
      userData = json.decode(prefs.getString('userData')!);
      if (userData["user_name"] != '') {
        userName = userData["user_name"] ?? userName;
        userEmail = userData["user_email"] ?? userEmail;
        referral = userData["referral"] ?? '';
        studyingIn = userData["studyingin"] ?? '';
        userId = userData["user_id"]?.toString();
      }
    }
    if (prefs.containsKey('staffData') && prefs.getString('staffData') != '') {
      userData = json.decode(prefs.getString('staffData')!);
      if (userData["name"] != '') {
        userName = "${userData["name"]}(Staff Login)";
        userEmail = userData["email"] ?? userEmail;
        referral = '';
        studyingIn = '';
        userId = userData["user_id"]?.toString();
      }
    }
    if (prefs.containsKey('consulData') &&
        prefs.getString('consulData') != '') {
      userData = json.decode(prefs.getString('consulData')!);
      if (userData["name"] != '') {
        userName = userData["name"] ?? userName;
        userEmail = userData["email"] ?? userEmail;
        referral = '';
        studyingIn = '';
        userId = userData["user_id"]?.toString();
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> share() async {
    await Share.share(
        "Hi I'm inviting you to use Career Defence App for preparing Sainik school & Rms Here's my code $referral just enter it while registering Share & Earn 500 money\n\nhttps://play.google.com/store/apps/details?id=com.careergroup.careerapp");
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      child: Drawer(
        width: (MediaQuery.sizeOf(context).width * 0.9)
            .clamp(300.0, 340.0)
            .toDouble(),
        child: SizedBox(
          width: double.infinity,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  buildUserInfo(context),
                  const SizedBox(height: 10.0),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Aboutus()));
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.help,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "About Us",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  FadeTransition(
                    opacity: _blinkAnimation,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RaiseComplaintScreen(),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4E5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFC266)),
                        ),
                        child: const Row(children: [
                          Icon(Icons.campaign_rounded,
                              color: Color(0xFFE87900)),
                          SizedBox(width: 30),
                          Expanded(
                            child: Text('Raise Complaint',
                                style: TextStyle(
                                    color: Color(0xFF9A4D00),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 14, color: Color(0xFFE87900)),
                        ]),
                      ),
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const TransferCertificateScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.assignment,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "Apply For TC\n(Transfer Certificate)",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  if (userId == "1421" ||
                      userId == "1422" ||
                      userId == "1423" ||
                      userId == "573" ||
                      userId == "46" ||
                      userId == "710" ||
                      userId == "711" ||
                      userId == "712" ||
                      userId == "1510" ||
                      userId == "1511" ||
                      userId == "1512")
                    // Show Visitors Data menu

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AllUsersScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.group,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "Visitors In-Out",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      ),
                    ),

                  if (userId == "573" ||
                      userId == "46" ||
                      userId == "1399" ||
                      userId == "1432" ||
                      userId == "1434" ||
                      userId == "1435" ||
                      userId == "1436" ||
                      userId == "1437" ||
                      userId == "1438" ||
                      userId == "1439" ||
                      userId == "1081" ||
                      userId == "1079" ||
                      userId == "948" ||
                      userId == "947" ||
                      userId == "949" ||
                      userId == "943" ||
                      userId == "942" ||
                      userId == "935" ||
                      userId == "710" ||
                      userId == "711" ||
                      userId == "712" ||
                      userId == "1510" ||
                      userId == "1511" ||
                      userId == "1512")
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AdminGatePassScreen()));
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 20, top: 12, bottom: 12),
                          child: Row(children: [
                            Icon(
                              Icons.group,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 30.0),
                            Text(
                              "Gate Request",
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16.0),
                            ),
                          ]),
                        )),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UpgradeFeatures()));
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.workspace_premium,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 30.0),
                            FadeTransition(
                              opacity: _blinkAnimation,
                              child: Text(
                                showUpgrade
                                    ? "Upgrade to Plus"
                                    : "Unique Features",
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Notifications()));
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.notifications,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "Notifications",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  // GestureDetector(
                  //     onTap: () {
                  //       Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (context) => const Wallet()));
                  //     },
                  //     child: Container(
                  //       padding: const EdgeInsets.only(
                  //           left: 16.0, right: 20, top: 12, bottom: 12),
                  //       child: Row(children: const [
                  //         Icon(
                  //           Icons.account_balance_wallet,
                  //           color: Colors.blue,
                  //         ),
                  //         SizedBox(width: 30.0),
                  //         Text(
                  //           "My Wallet",
                  //           style:
                  //               TextStyle(color: Colors.black, fontSize: 16.0),
                  //         ),
                  //       ]),
                  //     )),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FillformScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.mobile_friendly,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "Apply Online Forms",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  GestureDetector(
                      onTap: () {
                        dynamic row = {
                          "school_name": "Apply For Free Sample Papers",
                          "url":
                              "https://www.careerdefenceschool.com/applysamplepapers.php"
                        };
                        Navigator.of(context)
                            .pushNamed(OpenUrl.routeName, arguments: row);
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            FontAwesomeIcons.book,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "Apply For Free \nSample Papers",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Schoolfee()));
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.payment,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "Pay School Fee",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  GestureDetector(
                      onTap: () {
                        dynamic data3 = {
                          "school_name": "Apply Scholarship Form",
                          "url": "https://www.careerdefenceschool.com/admission"
                        };
                        Navigator.of(context)
                            .pushNamed(OpenUrl.routeName, arguments: data3);
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.mobile_friendly,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "Apply Scholarship Form",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  GestureDetector(
                      onTap: () {
                        dynamic data3 = {
                          "school_name": "Hostel Items",
                          "url":
                              "https://www.careerdefenceschool.com/form/hostel"
                        };
                        Navigator.of(context)
                            .pushNamed(OpenUrl.routeName, arguments: data3);
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.shop,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "Hostel Items",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  // GestureDetector(
                  //     onTap: () {
                  //       Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (context) => const BuybooksScreen()));
                  //     },
                  //     child: Container(
                  //       padding: const EdgeInsets.only(
                  //           left: 16.0, right: 20, top: 12, bottom: 12),
                  //       child: Row(children: const [
                  //         Icon(
                  //           Icons.book,
                  //           color: Colors.blue,
                  //         ),
                  //         SizedBox(width: 30.0),
                  //         Text(
                  //           "Buy Books",
                  //           style:
                  //               TextStyle(color: Colors.black, fontSize: 16.0),
                  //         ),
                  //       ]),
                  //     )),
                  GestureDetector(
                      onTap: () {
                        dynamic data3 = {
                          "school_name": "CDS Yamunanagar Pictures",
                          "url":
                              "https://photos.google.com/share/AF1QipMYGMLo_MwtLRAAL_HnaRj_SEuAsWRA8L8oW8S5Ipuudf5klFMCU-yTbvh3CcWefw?pli=1&key=X3NUWmJoNzFKZmpYaG1xdG5CU1dPZmREaUJCbURR"
                        };
                        Navigator.of(context)
                            .pushNamed(OpenUrl.routeName, arguments: data3);
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.camera,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "CDS Yamunanagar Pictures",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  GestureDetector(
                      onTap: () {
                        dynamic data3 = {
                          "school_name": "CDS Yamunanagar Video",
                          "url":
                              "https://drive.google.com/file/d/1iNPepEvemptIiHPQJJNu55kBBpTZzqdz/view"
                        };
                        Navigator.of(context)
                            .pushNamed(OpenUrl.routeName, arguments: data3);
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.video_call,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "CDS Yamunanagar Video",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  GestureDetector(
                      onTap: () {
                        dynamic data3 = {
                          "school_name": "CDS Ambala Pictures",
                          "url":
                              "https://drive.google.com/drive/u/2/folders/18uOxyOTs2f66a2HBorOINfY-wPyqkun8"
                        };
                        Navigator.of(context)
                            .pushNamed(OpenUrl.routeName, arguments: data3);
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.camera,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "CDS Ambala Pictures",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  GestureDetector(
                      onTap: () {
                        dynamic data3 = {
                          "school_name": "CDS Ambala Video",
                          "url":
                              "https://drive.google.com/file/d/1iNPepEvemptIiHPQJJNu55kBBpTZzqdz/view"
                        };
                        Navigator.of(context)
                            .pushNamed(OpenUrl.routeName, arguments: data3);
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.video_call,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "CDS Ambala Video",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  GestureDetector(
                      onTap: () {
                        dynamic data3 = {
                          "school_name": "CDS Patiala Pictures",
                          "url":
                              "https://drive.google.com/drive/u/2/folders/18uOxyOTs2f66a2HBorOINfY-wPyqkun8"
                        };
                        Navigator.of(context)
                            .pushNamed(OpenUrl.routeName, arguments: data3);
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.camera,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "CDS Patiala Pictures",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  GestureDetector(
                      onTap: () {
                        dynamic data3 = {
                          "school_name": "CDS Patiala Video",
                          "url":
                              "https://drive.google.com/file/d/1WVJufLUIwKeOP_sJc0kj3hRrho9pRDYG/view"
                        };
                        Navigator.of(context)
                            .pushNamed(OpenUrl.routeName, arguments: data3);
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.video_call,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "CDS Patiala Video",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  // GestureDetector(
                  //     onTap: () {
                  //       Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (context) => const Weeklytest()));
                  //     },
                  //     child: Container(
                  //       padding: const EdgeInsets.only(
                  //           left: 16.0, right: 20, top: 12, bottom: 12),
                  //       child: Row(children: const [
                  //         Icon(
                  //           Icons.check,
                  //           color: Colors.blue,
                  //         ),
                  //         SizedBox(width: 30.0),
                  //         Text(
                  //           "Weekly Test",
                  //           style:
                  //               TextStyle(color: Colors.black, fontSize: 16.0),
                  //         ),
                  //       ]),
                  //     )),
                  GestureDetector(
                      onTap: () {
                        dynamic data3 = {
                          "school_name": "Apply Scholarship Form",
                          "url": "https://www.careerdefenceschool.com/admission"
                        };
                        Navigator.of(context)
                            .pushNamed(OpenUrl.routeName, arguments: data3);
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.mobile_friendly,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "Apply Hostel \nSubsidy/CA Form",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ExamDetails()));
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.info,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "Exam Details",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const OurServices()));
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.miscellaneous_services,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "Our Services",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  referral != ''
                      ? GestureDetector(
                          onTap: () {
                            share();
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 20, top: 12, bottom: 12),
                            child: Row(children: [
                              Icon(
                                Icons.share,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 30.0),
                              Text(
                                "Invite and Earn Money",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16.0),
                              ),
                            ]),
                          ))
                      : const SizedBox(height: 1),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Downloads()));
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.download_sharp,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "Downloads",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FAQPage()));
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.question_answer,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "Important Exam FAQ's",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  GestureDetector(
                      onTap: () {
                        //  if (studyingin == "Career Defence School") {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Feedbackform()));
                        // } else {
                        //   Fluttertoast.showToast(
                        //       msg: "Your are not eligible for this form.",
                        //       timeInSecForIosWeb: 10);
                        // }
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.check_box,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "Feedback Form",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse(
                            "https://www.careerdefenceschool.com/pdf/CDS_FAQ_NEW.pdf"));
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.info,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "Parents FAQ",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Contactus()));
                      },
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 20, top: 12, bottom: 12),
                        child: Row(children: [
                          Icon(
                            Icons.email,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 30.0),
                          Text(
                            "Contact Us",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ]),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  buildUserInfo(context) => Container(
        color: Colors.blue[600],
        //height: deviceSize.height * 0.3,
        padding: const EdgeInsets.only(bottom: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              onTap: () {
                Navigator.of(context).pop();
              },
              leading: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 15.0,
            ),
            profileimage(),
            const SizedBox(
              height: 15.0,
            ),
            Text(
              userName.toUpperCase(),
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              userEmail,
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            referral != ''
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const Text(
                          "Referral Code: ",
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          referral,
                          style: const TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: referral));
                              Fluttertoast.showToast(
                                  msg: "Code is Copied",
                                  timeInSecForIosWeb: 10);
                            },
                            child: const Icon(
                              Icons.copy,
                              color: Colors.white,
                            ))
                      ])
                : const SizedBox(height: 1),
            const SizedBox(height: 10),
            GestureDetector(
                onTap: () {
                  CommonService.logout();

                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => LoginScreen()));
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      LoginScreen.routeName, (r) => false);
                },
                child: FutureBuilder(
                    future: CommonService.isLoggedIn(),
                    builder: (ctx, dataSnapshot) => (dataSnapshot.data == true)
                        ? const Material(
                            color: Colors.white,
                            child: InkWell(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 20.0,
                                    right: 20.0,
                                    top: 5.0,
                                    bottom: 5.0),
                                child: Text("Logout"),
                              ),
                            ),
                          )
                        : const Material(
                            color: Colors.white,
                            child: InkWell(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 20.0,
                                    right: 20.0,
                                    top: 5.0,
                                    bottom: 5.0),
                                child: Text("Login"),
                              ),
                            ),
                          )))
          ],
        ),
      );

  profileimage() {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage('assets/logo.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
