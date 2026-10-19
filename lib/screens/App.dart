import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careerapp/screens/ask_query.dart';
import 'package:careerapp/screens/home_screen.dart';
import 'package:careerapp/screens/home_screen2.dart';
import 'package:careerapp/screens/home_screen3.dart';
import 'package:careerapp/screens/dailyvideos_screen.dart';
import 'package:careerapp/screens/training.dart';
import 'package:careerapp/screens/user_profile_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'mydrawer.dart';
import 'package:careerapp/screens/notifications.dart';
import '../widgets/bottom_expandable_app_bar/bottom_expandable_app_bar.dart';
import '../widgets/bottom_expandable_app_bar/controller.dart';
import 'openurl.dart';
import 'social/feeds.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:careerapp/screens/student_results.dart';

class App extends StatefulWidget {
  static const String routeName = '/app';

  const App({Key? key}) : super(key: key);
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool staffLogin = false;
  bool consulLogin = false;
  late BottomBarController controller;
  final InAppReview inAppReview = InAppReview.instance;
  int roleId = 0;
  bool showStaffTrainingTab = false;

  // Flickering text variables
  int _currentTextIndex = 0;
  late Timer _flickerTimer;
  final List<String> _schoolNames = [
    "Career Defence School Ambala (HR)",
    "CBSE Affiliation No : 532338",
    "Career Defence School Patiala (PB)",
    "CBSE Affiliation No : 532338",
    "Career Defence School Ymngr (HR)",
    "CBSE Affiliation No : 532338",
  ];

  @override
  void initState() {
    super.initState();
    getUserData();
    controller = BottomBarController(vsync: this, dragLength: 550, snap: true);
    loadReview(); // Disabled: do not show the app review prompt on login.

    // Start affiliation text rotation.
    _startFlickerTimer();

    //for web
    _listenForMessages();
    setupInteractedMessage();
  }

  void _startFlickerTimer() {
    _flickerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentTextIndex = (_currentTextIndex + 1) % _schoolNames.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _flickerTimer.cancel();
    super.dispose();
  }

  Future<void> _listenForMessages() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            message.notification!.title.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(message.notification!.body.toString()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
                Navigator.pushNamed(context, "/new_updates");
              },
              child: const Text('Open',
                  style: TextStyle(color: Color(0xFF3D5CFF))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child:
                  const Text('Dismiss', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      );
    });
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    Navigator.pushNamed(context, "/new_updates");
  }

  loadReview() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('staffData') && prefs.getString('staffData') != '') {
      var staffData = json.decode(prefs.getString('staffData')!);
      if (staffData["user_id"] != '') {
        staffLogin = true;
      }

      // Check and assign roleId
      if (staffData["role_id"] != null) {
        roleId = int.tryParse(staffData["role_id"].toString()) ?? 0;
        // if (roleId == 3) {
        showStaffTrainingTab = true;
        // }
      }

      setState(() {});
    }

    if (prefs.containsKey('consulData') &&
        prefs.getString('consulData') != '') {
      var staffData = json.decode(prefs.getString('consulData')!);
      if (staffData["id"] != '') {
        consulLogin = true;
      }

      // Check and assign roleId
      if (staffData["role_id"] != null) {
        roleId = int.tryParse(staffData["role_id"].toString()) ?? 0;
        // if (roleId == 3) {
        showStaffTrainingTab = true;
        // }
      }

      setState(() {});
    }
  }

  Future<void> share() async {
    await Share.share(
        'Install Career Defence School App and Start Online Classes by Today\nhttps://play.google.com/store/apps/details?id=com.careergroup.careerapp');
  }

  final List<Widget> _widgetOptions = <Widget>[
    const Feeds(),
    const Home(),
    const AskQuery(),
    const DailyVideos(),
    const StudentResults(),
    const UserProfile(),
  ];

  final List<Widget> _widgetOptions2 = <Widget>[
    const Feeds(),
    const Home(),
    const AskQuery(),
    const DailyVideos(),
    const StudentResults(),
    const Home2(),
  ];

  final List<Widget> _widgetOptions3 = <Widget>[
    const Feeds(),
    const Home(),
    const AskQuery(),
    const DailyVideos(),
    const StudentResults(),
    const Home3(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      drawer: const MyDrawer(),
      body: Center(
        child: staffLogin
            ? _widgetOptions2.elementAt(_selectedIndex)
            : (consulLogin
                ? _widgetOptions3.elementAt(_selectedIndex)
                : _widgetOptions.elementAt(_selectedIndex)),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: SvgPicture.asset(
            "assets/drawer.svg",
            height: 12,
            width: 10,
            color: const Color(0xFF3D5CFF),
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      titleSpacing: 2,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 4, right: 6),
          child: ClipRect(
            child: SizedBox(
              height: 32,
              width: double.infinity,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 700),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                layoutBuilder:
                    (Widget? currentChild, List<Widget> previousChildren) {
                  return Stack(
                    alignment: Alignment.centerLeft,
                    fit: StackFit.expand,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _schoolNames[_currentTextIndex],
                  key: ValueKey<int>(_currentTextIndex),
                  style: const TextStyle(
                    color: Color(0xFF2E3E5C),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_active,
              color: Color(0xFFFF5630),
              size: 22,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Notifications()),
              );
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.share,
              color: Color(0xFF3D5CFF),
              size: 22,
            ),
            onPressed: share,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AskQuery()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF3D5CFF),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3D5CFF).withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.chat,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: _buildBottomBar(context),
      ),
    );
  }

  BottomExpandableAppBar _buildBottomBar(BuildContext context) {
    return BottomExpandableAppBar(
      attachSide: Side.Top,
      controller: controller,
      expandedHeight: MediaQuery.of(context).size.height - 75,
      horizontalMargin: 0,
      appBarHeight: 64,
      bottomOffset: 0,
      expandedBackColor: Colors.transparent,
      bottomAppBarColor: Colors.white,
      bottomAppBarBody: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildBottomNavItem(
                index: 0, icon: Icons.home_rounded, label: "Home"),
            _buildBottomNavItem(
                index: 2, icon: LineIcons.certificate, label: "Scholarship"),
            _buildBottomNavItem(
                index: 3, icon: LineIcons.video, label: "Hostel\nBenefit"),
            if (showStaffTrainingTab)
              _buildBottomNavItem(
                  index: 4,
                  icon: LineIcons.userGraduate,
                  label: "Staff\nTraining"),
            _buildBottomNavItem(
                index: 5, icon: LineIcons.userCircle, label: "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isNarrow = constraints.maxWidth < 64;

          return InkWell(
            onTap: () {
              if (index == 2) {
                // Open Scholarship link
                dynamic row = {
                  "school_name": "Apply For Scholarship Test",
                  "url": "https://www.careerdefenceschool.com/admission/"
                };
                Navigator.of(context)
                    .pushNamed(OpenUrl.routeName, arguments: row);
              } else if (index == 4) {
                // Navigate to Training Page
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const StaffTraining()),
                );
              } else {
                // Update tab normally
                setState(() {
                  _selectedIndex = index;
                });
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              padding: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3D5CFF).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF3D5CFF).withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected
                          ? const Color(0xFF3D5CFF)
                          : Colors.grey[600],
                      size: isNarrow ? 19 : 21,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isNarrow ? 7.5 : 8.5,
                      height: 0.95,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF3D5CFF)
                          : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 2,
                    width: isSelected ? 18 : 0,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D5CFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
