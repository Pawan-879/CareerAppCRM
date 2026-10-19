import 'dart:convert';
import 'dart:io';
// References screen temporarily disabled.
// import 'package:careerapp/screens/lead_references.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
// Add this line

class Leads extends StatefulWidget {
  static const routeName = '/Leads';
  const Leads({Key? key}) : super(key: key);

  @override
  State<Leads> createState() => _LeadsState();
}

class _LeadsState extends State<Leads> with TickerProviderStateMixin {
  dynamic data = <dynamic>[];
  var school_id = "1";
  var email = '';
  var page = 1;
  var staff_id;
  var hightly_interested = 0;
  var interested = 0;
  var not_interested = 0;
  var registration = 0;
  var admission = 0;
  var total_cases = 0;
  var states = [];
  var state;
  var search = "";
  var filter = "";
  var status = "";
  bool isLoading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _loadError;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<FormState> _formKey2 = GlobalKey();
  TextEditingController myController = TextEditingController();
  var textcontroller = TextEditingController();

  final _authData2 = {'id': '', 'user_id': '', 'remark': '', 'remark_type': ''};
  final _authData = {
    'student_name': '',
    'father_name': '',
    'father_occupation': '',
    'annual_family_income': '',
    'class_name': '',
    'mobile1': '',
    'mobile2': '',
    'status': '',
    'followup_date': '',
    'state': '',
    'city': '',
    'address': '',
    'pincode': '',
    'user_id': '',
    'remark': ''
  };
  final scrollController = ScrollController();
  var images = [
    "https://careerdefenceacademy.com/includes/banners/slider1.jpeg",
    "https://careerdefenceacademy.com/includes/banners/slider3.jpeg",
    "https://careerdefenceacademy.com/includes/banners/slider4.jpeg"
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    getUserData();
    scrollAction();
    getAllStates();
  }

  @override
  void dispose() {
    _animationController.dispose();
    scrollController.dispose();
    myController.dispose();
    textcontroller.dispose();
    super.dispose();
  }

  getAllStates() async {
    try {
      var res2 = await ApiService.getMethod3("/getAllStates");
      dynamic mydata2 = json.decode(res2.body);
      states = mydata2["data"];
    } catch (err) {
      print(err);
    }
    if (mounted) setState(() {});
  }

  Future<void> getUserData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      _loadError = null;
      data = <dynamic>[];
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawStaffData = prefs.getString('staffData');
      if (rawStaffData == null || rawStaffData.trim().isEmpty) {
        throw StateError(
            'Staff login data was not found. Please sign in again.');
      }
      final decoded = json.decode(rawStaffData);
      if (decoded is! Map<String, dynamic> ||
          decoded['user_id'] == null ||
          decoded['user_id'].toString().isEmpty) {
        throw StateError('Staff ID is missing. Please sign in again.');
      }
      staff_id = decoded['user_id'].toString();
      page = 1;
      await getMyStudents(staff_id, 1);
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
          _loadError = error is FormatException
              ? 'Staff login data is invalid. Please sign in again.'
              : error.toString().replaceFirst('Bad state: ', '');
        });
      }
    }
  }

  void scrollAction() {
    scrollController.addListener(() {
      if (!scrollController.hasClients ||
          isLoading ||
          _loadingMore ||
          !_hasMore ||
          staff_id == null) return;
      if (scrollController.position.extentAfter < 250) {
        getMyStudents(staff_id, page + 1);
      }
    });
  }

  submit() async {
    _formKey.currentState!.save();
    if (validateAndSave()) {
      setState(() {
        isLoading = true;
      });
      try {
        _authData['user_id'] = staff_id;
        var response = await ApiService.postMethod3(
          '/addLead',
          json.encode(_authData),
        );
        if (response["status"] == "1") {
          Fluttertoast.showToast(
              msg: response["message"],
              timeInSecForIosWeb: 4,
              backgroundColor: Colors.green,
              textColor: Colors.white);
        } else {
          Fluttertoast.showToast(
              msg: response["message"],
              timeInSecForIosWeb: 4,
              backgroundColor: Colors.red,
              textColor: Colors.white);
        }
        page = 1;
        data = [];
        await getMyStudents(staff_id, page);
        Navigator.of(context).pop();
      } catch (err) {
        print(err);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  updateLead() async {
    _formKey2.currentState!.save();
    if (validateAndSave2()) {
      setState(() {
        isLoading = true;
      });
      _authData2["user_id"] = staff_id;
      var data1 = json.encode(_authData2);
      try {
        var response = await ApiService.postMethod3('/updateLead', data1);
        if (response["error"] == false) {
          Navigator.of(context).pop();
          Fluttertoast.showToast(
              msg: "Lead remark added successfully",
              timeInSecForIosWeb: 4,
              backgroundColor: Colors.green,
              textColor: Colors.white);
          page = 1;
          data = [];
          await getMyStudents(staff_id, page);
        }
      } catch (err) {
        print(err);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  bool validateAndSave2() {
    final form = _formKey2.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> getMyStudents(dynamic id, dynamic requestedPage) async {
    final staffId = id?.toString() ?? '';
    final nextPage = int.tryParse(requestedPage.toString()) ?? 1;
    if (staffId.isEmpty || (nextPage > 1 && (_loadingMore || !_hasMore)))
      return;
    if (nextPage == 1) {
      if (mounted)
        setState(() {
          isLoading = true;
          _loadError = null;
        });
    } else {
      _loadingMore = true;
      if (mounted) setState(() {});
    }
    try {
      final query = Uri(queryParameters: {
        'id': staffId,
        'page': '$nextPage',
        'search': search,
        'filter': filter,
        'status': status,
      }).query;
      final response =
          await ApiService.getMethod3('/getCounsellorLeads?$query');
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Server returned ${response.statusCode}');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map || decoded['data'] is! List) {
        throw const FormatException('Invalid response from leads API');
      }
      final items = decoded['data'] as List;
      if (!mounted) return;
      setState(() {
        if (nextPage == 1) data = <dynamic>[];
        data.addAll(items);
        page = nextPage;
        _hasMore = items.isNotEmpty;
        hightly_interested = decoded['highly_interested'] ?? 0;
        interested = decoded['interested'] ?? 0;
        not_interested = decoded['not_interested'] ?? 0;
        registration = decoded['registration'] ?? 0;
        admission = decoded['admission'] ?? 0;
        total_cases = decoded['total_cases'] ?? 0;
        _loadError = null;
      });
    } catch (error) {
      if (mounted) setState(() => _loadError = 'Unable to load leads: $error');
    } finally {
      _loadingMore = false;
      if (mounted) setState(() => isLoading = false);
    }
  }

  searchFilter() {
    page = 1;
    data = [];
    search = myController.text.trim();
    getMyStudents(staff_id, 1);
  }

  searchByStatus(s) {
    search = "";
    filter = "";
    myController.text = "";
    page = 1;
    data = [];
    status = s.toString();
    getMyStudents(staff_id, 1);
  }

  clearFilter() {
    data = [];
    search = "";
    filter = "";
    status = "";
    myController.text = "";
    getMyStudents(staff_id, 1);
    setState(() {});
  }

  _callNumber(number) async {
    await launch("tel://" + number);
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: isLoading && data.isEmpty
          ? _buildLoadingWidget()
          : FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                onRefresh: () async {
                  await getUserData();
                },
                color: const Color(0xFF6366F1),
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildPerformanceCards(),
                      // _buildImageSlider(deviceSize),
                      _buildSearchAndFilter(),
                      if (isLoading && data.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: LinearProgressIndicator(
                            minHeight: 3,
                            color: Color(0xFF6366F1),
                            backgroundColor: Color(0xFFE0E7FF),
                          ),
                        ),
                      if (_loadError != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(_loadError!,
                                      textAlign: TextAlign.center),
                                  const SizedBox(height: 8),
                                  OutlinedButton.icon(
                                    onPressed: getUserData,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      _buildLeadsList(),
                      if (_loadingMore)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Lead Dashboard',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
          Text('Manage your student enquiries',
              style: TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Refresh leads',
          onPressed: isLoading ? null : getUserData,
          icon: const Icon(Icons.refresh_rounded),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
          SizedBox(height: 16),
          Text(
            "Loading your leads...",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCards() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Performance Overview",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 112,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildPerformanceCard(
                  "Excellent",
                  hightly_interested.toString(),
                  const Color(0xFF10B981),
                  LineIcons.trophy,
                  () => searchByStatus("1"),
                ),
                _buildPerformanceCard(
                  "Good",
                  interested.toString(),
                  const Color(0xFFF59E0B),
                  LineIcons.thumbsUp,
                  () => searchByStatus("2"),
                ),
                _buildPerformanceCard(
                  "Poor",
                  not_interested.toString(),
                  const Color(0xFFEF4444),
                  LineIcons.thumbsDown,
                  () => searchByStatus("3"),
                ),
                _buildPerformanceCard(
                  "Registration",
                  registration.toString(),
                  const Color(0xFF06B6D4),
                  LineIcons.userPlus,
                  () => searchByStatus("5"),
                ),
                _buildPerformanceCard(
                  "Admission",
                  admission.toString(),
                  const Color(0xFF8B5CF6),
                  LineIcons.graduationCap,
                  () => searchByStatus("6"),
                ),
                _buildPerformanceCard(
                  "Total Leads",
                  total_cases.toString(),
                  const Color(0xFF6366F1),
                  LineIcons.users,
                  () => searchByStatus(""),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(String title, String count, Color color,
      IconData icon, VoidCallback onTap) {
    return Container(
      width: 132,
      margin: const EdgeInsets.only(right: 10, bottom: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.82)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.22),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    Text(count,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSlider(Size deviceSize) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Swiper(
          itemBuilder: (BuildContext context, int index) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(images[index]),
                  fit: BoxFit.contain,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            );
          },
          itemCount: images.length,
          autoplay: true,
          autoplayDelay: 4000,
          duration: 800,
          pagination: const SwiperPagination(
            builder: DotSwiperPaginationBuilder(
              activeColor: Colors.white,
              color: Colors.white54,
              size: 8,
              activeSize: 10,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EAF2)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1E293B).withOpacity(.05),
              blurRadius: 14,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Find a lead',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          const Text('Search by student name or mobile number',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: myController,
                  onSubmitted: (_) => searchFilter(),
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'Name or mobile number',
                    hintStyle:
                        const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF6366F1), width: 1.5)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                  icon: Icons.search_rounded,
                  color: const Color(0xFF6366F1),
                  onTap: searchFilter),
              const SizedBox(width: 8),
              _buildActionButton(
                  icon: Icons.refresh_rounded,
                  color: const Color(0xFF64748B),
                  onTap: clearFilter),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Filter by date',
              prefixIcon: const Icon(Icons.calendar_month_outlined,
                  color: Color(0xFF64748B)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
            isExpanded: true,
            dropdownColor: Colors.white,
            initialValue: filter.isEmpty ? null : filter,
            onChanged: (value) {
              setState(() => filter = value ?? '');
              getMyStudents(staff_id, 1);
            },
            items: <String>[
              'Today',
              'Yesterday',
              'This week',
              'Last week',
              'This month',
              'Last month',
              'All Leads'
            ]
                .map((value) =>
                    DropdownMenuItem<String>(value: value, child: Text(value)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: Colors.white, size: 21)),
      ),
    );
  }

  Widget _buildLeadsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Leads List",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                "${data.length} leads",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (data.isEmpty && _loadError == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: Text('No leads found')),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) {
                return _buildEnhancedLeadTile(data[index], index);
              },
            ),
          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildEnhancedLeadTile(dynamic leadData, int index) {
    var name = leadData["student_name"] ?? 'N/A';
    var fatherName = leadData["father_name"] ?? 'N/A';
    var mobile = leadData["mobile1"] ?? 'N/A';
    var remark = leadData["new_remark"] ?? '';
    var createdAt = leadData["created_at"] != null
        ? DateFormat('dd MMM yyyy')
            .format(DateTime.parse(leadData["created_at"]))
        : '';
    var followupDate = leadData["followup_date"] != null
        ? DateFormat('dd MMM yyyy')
            .format(DateTime.parse(leadData["followup_date"]))
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: getBorderColor(leadData["status"]), width: 2),
        boxShadow: [
          BoxShadow(
            color: getBgColor(leadData["status"]).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        getBgColor(leadData["status"]),
                        getBgColor(leadData["status"]).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    LineIcons.user,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Father: $fatherName",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            mobile,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: getBgColor(leadData["status"]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    getStatus(leadData["status"]),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (remark.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(
                  remark,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFDC2626),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (createdAt.isNotEmpty) ...[
                  const Icon(Icons.calendar_today,
                      size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    "Created: $createdAt",
                    style:
                        const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
                const Spacer(),
                if (followupDate.isNotEmpty) ...[
                  const Icon(Icons.schedule,
                      size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    "Follow-up: $followupDate",
                    style:
                        const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              runSpacing: 10,
              spacing: 12,
              children: [
                _buildLeadActionButton(
                  icon: LineIcons.whatSApp,
                  color: const Color(0xFF25D366),
                  label: "WhatsApp",
                  onTap: () async {
                    var contact = leadData["mobile1"];
                    var androidUrl =
                        "whatsapp://send?phone=$contact&text=Hello";
                    var iosUrl =
                        "https://wa.me/$contact?text=${Uri.parse('Hello')}";
                    try {
                      if (Platform.isIOS) {
                        await launchUrl(Uri.parse(iosUrl));
                      } else {
                        await launchUrl(Uri.parse(androidUrl));
                      }
                    } on Exception {}
                  },
                ),
                _buildLeadActionButton(
                  icon: Icons.phone,
                  color: const Color(0xFF3B82F6),
                  label: "Call",
                  onTap: () => launch("tel://" + leadData["mobile1"]),
                ),
                // References button disabled as requested.
                // _buildLeadActionButton(
                //   icon: LineIcons.userFriends,
                //   color: const Color(0xFF8B5CF6),
                //   label: "References",
                //   onTap: () => Navigator.of(context).pushNamed(
                //     LeadReferences.routeName,
                //     arguments: leadData,
                //   ),
                // ),
                _buildLeadActionButton(
                  icon: Icons.event_available_rounded,
                  color: const Color(0xFF8B5CF6),
                  label: "Appointment",
                  onTap: () async {
                    final saved = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => _LeadAppointmentForm(
                          lead: Map<String, dynamic>.from(leadData),
                          staffId: staff_id?.toString() ?? '',
                          schoolId: school_id.toString(),
                        ),
                      ),
                    );
                    if (saved == true && mounted) {
                      await getMyStudents(staff_id, 1);
                    }
                  },
                ),
                _buildLeadActionButton(
                  icon: LineIcons.edit,
                  color: const Color(0xFF059669),
                  label: "Edit",
                  onTap: () => _editLeadForm(leadData),
                ),
                _buildLeadActionButton(
                  icon: LineIcons.comment,
                  color: const Color(0xFFEF4444),
                  label: "Comment",
                  onTap: () => _updateMyDialog(leadData),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 68,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                          color: color.withOpacity(.22),
                          blurRadius: 7,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 5),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showMyDialog,
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      elevation: 8,
      icon: const Icon(LineIcons.plus),
      label: const Text(
        "Add Lead",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  // Enhanced Dialog Methods
  _updateMyDialog(data) async {
    _authData2["id"] = data["id"];
    textcontroller.text = "";

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF8FAFC)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LineIcons.comment,
                        color: Color(0xFF6366F1),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Add Comment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Remarks",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            _authData2['remark'] = value;
                          });
                        },
                        controller: textcontroller,
                        keyboardType: TextInputType.multiline,
                        minLines: 4,
                        maxLines: 4,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF6366F1), width: 2),
                          ),
                          labelText: 'Enter your remarks here...',
                          labelStyle: const TextStyle(color: Color(0xFF64748B)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Remark Type",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF6366F1), width: 2),
                          ),
                          hintText: "Select Remark Type",
                          hintStyle: const TextStyle(
                              fontSize: 14, color: Color(0xFF64748B)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        initialValue: null,
                        onChanged: (value) {
                          setState(() {
                            _authData2["remark_type"] = value!;
                          });
                        },
                        items: <String>['new', 'follow']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value.toUpperCase(),
                              style: const TextStyle(color: Color(0xFF1E293B)),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: updateLead,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Submit Comment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _showMyDialog() {
    TextEditingController startInput = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF8FAFC)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LineIcons.userPlus,
                        color: Color(0xFF6366F1),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Add New Lead',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormField(
                            label: "Student Name *",
                            hintText: "Enter student name",
                            validator: (value) => value!.isEmpty
                                ? 'Student Name field can\'t be empty'
                                : null,
                            onSaved: (value) =>
                                _authData['student_name'] = value!,
                          ),
                          _buildFormField(
                            label: "Father Name",
                            hintText: "Enter father name",
                            onSaved: (value) =>
                                _authData['father_name'] = value!,
                          ),
                          _buildDropdownField(
                            label: "Father Occupation",
                            hintText: "Select father occupation",
                            items: [
                              'Defence & Armed Forces',
                              'Government Job',
                              'Private Job',
                              'Business',
                              'Farmers',
                              'Armed Forces (CRPF/BSF/CISF/SSB/ITBT/ASSAM RIFLES)',
                              'Others'
                            ],
                            onChanged: (value) =>
                                _authData['father_occupation'] = value!,
                          ),
                          _buildDropdownField(
                            label: "Annual Family Income",
                            hintText: "Select annual family income",
                            items: [
                              'Under 2 lakhs',
                              '2 lakhs to 4 Lakhs',
                              '4 lakhs to 6 lakhs',
                              '6 lakhs to 8 lakhs',
                              'More than 8 lakhs'
                            ],
                            onChanged: (value) =>
                                _authData['annual_family_income'] = value!,
                          ),
                          _buildFormField(
                            label: "Mobile 1 *",
                            hintText: "Enter mobile number",
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty)
                                return 'Mobile can\'t be empty';
                              if (value.length < 10)
                                return 'Mobile length should be 10';
                              return null;
                            },
                            onSaved: (value) => _authData['mobile1'] = value!,
                          ),
                          _buildFormField(
                            label: "Mobile 2",
                            hintText: "Enter alternate mobile number",
                            keyboardType: TextInputType.number,
                            onSaved: (value) => _authData['mobile2'] = value!,
                          ),
                          _buildDropdownField(
                            label: "Status *",
                            hintText: "Select status",
                            items: [
                              'Poor (Not Interested)',
                              'Good (Interested)',
                              'Excellent (Highly Interested)',
                              'Registration',
                              'Admission',
                              'Refund'
                            ],
                            validator: (value) =>
                                value == null ? 'Please select status' : null,
                            onChanged: (value) => _authData['status'] = value!,
                          ),
                          _buildDropdownField(
                            label: "Class",
                            hintText: "Select class",
                            items: [
                              'LKG',
                              'UKG',
                              'Class 1',
                              'Class 2',
                              'Class 3',
                              'Class 4',
                              'Class 5',
                              'Class 6',
                              'Class 7',
                              'Class 8',
                              'Class 9',
                              'Class 10',
                              'Class 11 Science',
                              'Class 11 Commerce',
                              'Class 12 Science',
                              'Class 12 Commerce',
                            ],
                            onChanged: (value) =>
                                _authData['class_name'] = value!,
                          ),
                          _buildDateField(
                            label: "Follow-up Date",
                            controller: startInput,
                            onDateSelected: (date) =>
                                _authData['followup_date'] = date,
                          ),
                          _buildStateDropdown(),
                          _buildFormField(
                            label: "City Name",
                            hintText: "Enter city name",
                            onSaved: (value) => _authData['city'] = value!,
                          ),
                          _buildFormField(
                            label: "Address",
                            hintText: "Enter address",
                            onSaved: (value) => _authData['address'] = value!,
                          ),
                          _buildFormField(
                            label: "Remark",
                            hintText: "Enter remark",
                            onSaved: (value) => _authData['remark'] = value!,
                          ),
                          _buildFormField(
                            label: "Pincode",
                            hintText: "Enter pincode",
                            onSaved: (value) => _authData['pincode'] = value!,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Add Lead',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
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
          ),
        );
      },
    );
  }

  Widget _buildFormField({
    required String label,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    String? initialValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          validator: validator,
          onSaved: onSaved,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hintText,
    required List<String> items,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    String? value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
          isExpanded: true,
          dropdownColor: Colors.white,
          initialValue: value,
          validator: validator,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child:
                  Text(value, style: const TextStyle(color: Color(0xFF1E293B))),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required Function(String) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            hintText: "Select date",
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            suffixIcon:
                const Icon(Icons.calendar_today, color: Color(0xFF6366F1)),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF6366F1),
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Color(0xFF1E293B),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              String formattedDate =
                  DateFormat('dd-MM-yyyy').format(pickedDate);
              controller.text = formattedDate;
              onDateSelected(formattedDate);
            }
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select State *",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            hintText: "Select State",
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
          isExpanded: true,
          dropdownColor: Colors.white,
          initialValue: state == "" ? null : state,
          onChanged: (value) {
            setState(() {
              state = value!;
              _authData['state'] = value;
            });
          },
          validator: (value) => value == null ? 'Please select state' : null,
          items: states
              .map<DropdownMenuItem<String>>(
                (value) => DropdownMenuItem<String>(
                  value: value["state_name"],
                  child: Text(
                    value["state_name"],
                    style: const TextStyle(color: Color(0xFF1E293B)),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _editLeadForm(dynamic lead) async {
    final formKey = GlobalKey<FormState>();
    final fields = <String, String>{
      'id': lead['id']?.toString() ?? '',
      'lead_id': lead['id']?.toString() ?? '',
      'student_name': lead['student_name']?.toString() ?? '',
      'father_name': lead['father_name']?.toString() ?? '',
      'father_occupation': lead['father_occupation']?.toString() ?? '',
      'annual_family_income': lead['annual_family_income']?.toString() ?? '',
      'class_name': lead['class_name']?.toString() ?? '',
      'mobile1': lead['mobile1']?.toString() ?? '',
      'mobile2': lead['mobile2']?.toString() ?? '',
      'status': _normalizeLeadStatus(lead['status']),
      'followup_date': _dateForInput(lead['followup_date']),
      'state': lead['state']?.toString() ?? '',
      'city': lead['city']?.toString() ?? '',
      'address': lead['address']?.toString() ?? '',
      'pincode': lead['pincode']?.toString() ?? '',
      'user_id': staff_id?.toString() ?? '',
    };
    bool saving = false;

    Widget sectionTitle(IconData icon, String title, String subtitle) =>
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 10),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withOpacity(.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF4F46E5), size: 19),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 12)),
                ])),
          ]),
        );

    Widget textField(
      String key,
      String label, {
      TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator,
      int maxLines = 1,
      String? hint,
    }) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            initialValue: fields[key],
            keyboardType: keyboardType,
            maxLines: maxLines,
            textCapitalization: key == 'student_name' || key == 'father_name'
                ? TextCapitalization.words
                : TextCapitalization.none,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
              ),
            ),
            validator: validator,
            onSaved: (value) => fields[key] = value?.trim() ?? '',
          ),
        );

    await showDialog<void>(
      context: context,
      barrierDismissible: !saving,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 560,
              maxHeight: MediaQuery.of(context).size.height * .9,
            ),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: Row(children: [
                  const Icon(Icons.edit_note, color: Colors.white, size: 25),
                  const SizedBox(width: 10),
                  const Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('Edit Lead',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                        Text('Update the student and follow-up details',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                      ])),
                  IconButton(
                    tooltip: 'Close',
                    onPressed:
                        saving ? null : () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ]),
              ),
              Expanded(
                child: Form(
                  key: formKey,
                  child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
                      children: [
                        sectionTitle(Icons.school_outlined,
                            'Student information', 'Name and current class'),
                        textField('student_name', 'Student name *',
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Enter the student name'
                                    : null),
                        textField('class_name', 'Class'),
                        sectionTitle(Icons.people_outline, 'Parent and contact',
                            'How to reach the family'),
                        textField('father_name', 'Father / parent name'),
                        textField('father_occupation', 'Father occupation'),
                        textField(
                            'annual_family_income', 'Annual family income'),
                        textField('mobile1', 'Primary mobile *',
                            keyboardType: TextInputType.phone,
                            validator: (value) => value == null ||
                                    !RegExp(r'^\d{10}$').hasMatch(value.trim())
                                ? 'Enter a 10 digit mobile number'
                                : null),
                        textField('mobile2', 'Alternate mobile',
                            keyboardType: TextInputType.phone,
                            validator: (value) => value != null &&
                                    value.trim().isNotEmpty &&
                                    !RegExp(r'^\d{10}$').hasMatch(value.trim())
                                ? 'Enter a 10 digit mobile number'
                                : null),
                        sectionTitle(Icons.location_on_outlined, 'Location',
                            'Address details for this lead'),
                        textField('state', 'State'),
                        textField('city', 'City / district'),
                        textField('address', 'Address', maxLines: 2),
                        textField('pincode', 'Pincode',
                            keyboardType: TextInputType.number,
                            validator: (value) => value != null &&
                                    value.trim().isNotEmpty &&
                                    !RegExp(r'^\d{6}$').hasMatch(value.trim())
                                ? 'Enter a 6 digit pincode'
                                : null),
                        sectionTitle(
                            Icons.flag_outlined,
                            'Lead status and follow-up',
                            'Track interest and next contact date'),
                        DropdownButtonFormField<String>(
                          value: fields['status'],
                          decoration: InputDecoration(
                            labelText: 'Lead status *',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          items: const <MapEntry<String, String>>[
                            MapEntry('1', 'Highly Interested'),
                            MapEntry('2', 'Interested'),
                            MapEntry('3', 'Not Interested'),
                            MapEntry('4', 'Refund'),
                            MapEntry('5', 'Registration'),
                            MapEntry('6', 'Admission'),
                          ]
                              .map((item) => DropdownMenuItem(
                                  value: item.key, child: Text(item.value)))
                              .toList(),
                          onChanged: (value) => setDialogState(
                              () => fields['status'] = value ?? '2'),
                          validator: (value) =>
                              value == null ? 'Choose a status' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: ValueKey(fields['followup_date']),
                          initialValue: fields['followup_date'],
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Follow-up date',
                            hintText: 'Choose a date',
                            suffixIcon: const Icon(Icons.calendar_month),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onTap: () async {
                            final now = DateTime.now();
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.tryParse(
                                      fields['followup_date'] ?? '') ??
                                  now,
                              firstDate: DateTime(now.year - 1),
                              lastDate: DateTime(now.year + 5),
                            );
                            if (date != null) {
                              setDialogState(() => fields['followup_date'] =
                                  DateFormat('yyyy-MM-dd').format(date));
                            }
                          },
                        ),
                      ]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                child: Row(children: [
                  Expanded(
                      child: OutlinedButton(
                    onPressed:
                        saving ? null : () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48)),
                    child: const Text('Cancel'),
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: saving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                formKey.currentState!.save();
                                fields['user_id'] = staff_id?.toString() ?? '';
                                setDialogState(() => saving = true);
                                try {
                                  final response = await ApiService.postMethod3(
                                      '/editLead', json.encode(fields));
                                  final success = response is Map &&
                                      (response['error'] == false ||
                                          response['status'].toString() == '1');
                                  if (success) {
                                    if (dialogContext.mounted)
                                      Navigator.pop(dialogContext);
                                    Fluttertoast.showToast(
                                      msg: response['message']?.toString() ??
                                          'Lead updated successfully',
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                    );
                                    await getMyStudents(staff_id, 1);
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: response is Map
                                          ? response['message']?.toString() ??
                                              'Unable to update lead'
                                          : 'Invalid response from server',
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                  }
                                } catch (error) {
                                  Fluttertoast.showToast(
                                    msg: 'Unable to update lead: $error',
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                } finally {
                                  if (dialogContext.mounted)
                                    setDialogState(() => saving = false);
                                }
                              },
                        icon: saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save_outlined),
                        label: Text(saving ? 'Saving…' : 'Save changes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      )),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  String _normalizeLeadStatus(dynamic raw) {
    const values = {'1', '2', '3', '4', '5', '6'};
    final value = raw?.toString() ?? '';
    if (values.contains(value)) return value;
    final lowered = value.toLowerCase();
    if (lowered.contains('high') || lowered.contains('excellent')) return '1';
    if (lowered.contains('not interested') || lowered.contains('poor'))
      return '3';
    if (lowered.contains('registration')) return '5';
    if (lowered.contains('admission')) return '6';
    if (lowered.contains('refund')) return '4';
    return '2';
  }

  String _dateForInput(dynamic value) {
    final raw = value?.toString() ?? '';
    if (raw.isEmpty) return '';
    try {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(raw));
    } catch (_) {
      try {
        return DateFormat('yyyy-MM-dd')
            .format(DateFormat('dd-MM-yyyy').parse(raw));
      } catch (_) {
        return '';
      }
    }
  }

  Color getBgColor(status) {
    switch (status) {
      case "1":
        return const Color(0xFF10B981);
      case "2":
        return const Color(0xFFF59E0B);
      case "3":
        return const Color(0xFFEF4444);
      case "4":
        return const Color(0xFF3B82F6);
      case "5":
        return const Color(0xFF06B6D4);
      case "6":
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color getBorderColor(status) {
    return getBgColor(status).withOpacity(0.3);
  }

  String getStatus(status) {
    switch (status) {
      case "1":
        return "Highly Interested";
      case "2":
        return "Interested";
      case "3":
        return "Not Interested";
      case "5":
        return "Registration";
      case "6":
        return "Admission";
      case "4":
        return "Refund";
      default:
        return "Pending";
    }
  }
}


// Appointment screen using all select options from the supplied web form.
class _LeadAppointmentForm extends StatefulWidget {
  final Map<String, dynamic> lead;
  final String staffId;
  final String schoolId;
  const _LeadAppointmentForm({required this.lead, required this.staffId, required this.schoolId});
  @override
  State<_LeadAppointmentForm> createState() => _LeadAppointmentFormState();
}

class _LeadAppointmentFormState extends State<_LeadAppointmentForm> {
  final formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> inputs = {};
  final Map<String, String> choices = {};
  final Set<String> branches = {};
  List<MapEntry<String,String>> stateOptions = [];
  List<MapEntry<String,String>> districtOptions = [];
  List<MapEntry<String,String>> seniorOptions = [const MapEntry('0','Individual')];
  List<MapEntry<String,String>> juniorOptions = [];
  bool loadingOptions = true;
  bool saving = false;
  DateTime? visitDate, droppingDate, followupDate;
  static const Color primary = Color(0xFF6366F1);
    static const List<MapEntry<String,String>> appointment_typeOptions = [
    MapEntry("dropping_only", "Select Dropping Date"),
    MapEntry("visit_only", "Select Visit Date"),
    MapEntry("visit_dropping", "Select Visit Plus Dropping Date"),
  ];
  static const List<MapEntry<String,String>> visit_typeOptions = [
    MapEntry("Personal Vehicle", "Personal Vehicle"),
    MapEntry("School Vehicle", "School Vehicle"),
    MapEntry("Train", "Train"),
    MapEntry("Flight", "Flight"),
    MapEntry("Bus", "Bus/Transport"),
  ];
  static const List<MapEntry<String,String>> time_slotOptions = [
    MapEntry("9T011am", "9 AM TO 11 AM (High Admission Rush)"),
    MapEntry("11T01pm", "11 AM TO 1 PM (Normal Admission Rush)"),
    MapEntry("1T03pm", "1 PM TO 3 PM (High Admissions Visits Rush)"),
    MapEntry("3T05pm", "3 PM TO 5 PM (Visit Not Allowed Convince For Night Stay Or Visit Without Hostel)"),
  ];
  static const List<MapEntry<String,String>> interestedOptions = [
    MapEntry("normal_academics", "1 — Maximum Calls - Normal Academics Classes + Hostel"),
    MapEntry("super_50_sports", "2 ➤ Super 50 Sports"),
    MapEntry("weak_student", "3 — Maximum Calls - Weak & Average Students"),
    MapEntry("after_12th", "4 ➤ After 12th Dropper Batch"),
    MapEntry("baccha/mummy/papa/dada/dadi_nhi_man_rhe", "5 ➤ Online Zoom Evening Classes"),
    MapEntry("open_schooling_for", "6 ➤ Open Schooling For Class 10th & 12th"),
    MapEntry("competetive_exam", "7 — Maximum Calls - Competitive Exam Or Super 50"),
  ];
  static const List<MapEntry<String,String>> classOptions = [
    MapEntry("NURSERY", "NURSERY"),
    MapEntry("LKG", "LKG"),
    MapEntry("UKG", "UKG"),
    MapEntry("CLASS 1", "CLASS 1 (5 to 7 Years)"),
    MapEntry("CLASS 2", "CLASS 2 (OAK GROVE SCHOOL MUSSOORIE) (6 to 8 Years)"),
    MapEntry("CLASS 3", "CLASS 3 (OAK GROVE & RAI SPORTS SCHOOL PANIPAT)"),
    MapEntry("CLASS 4", "CLASS 4 (RAI SPORTS SCHOOL)"),
    MapEntry("CLASS 5", "CLASS 5 (SAINIK SCHOOL & MILITARY SPORTS)"),
    MapEntry("CLASS 6", "CLASS 6 (SAINIK SCHOOL & MILITARY SPORTS)"),
    MapEntry("CLASS 7", "CLASS 7 (RIMC DEHRADUN EXAM)"),
    MapEntry("CLASS 8", "CLASS 8 (SAINIK SCHOOL & MILITARY SPORTS)"),
    MapEntry("CLASS 9", "CLASS 9 (SAINIK SCHOOL & MILITARY SPORTS)"),
    MapEntry("CLASS 10", "CLASS 10 (IIT JEE NEET NDA CLAT ALIET CUET)"),
    MapEntry("CLASS 11 SCIENCE", "CLASS 11 SCIENCE (IIT JEE NEET NDA)"),
    MapEntry("CLASS 11 COMMERCE", "CLASS 11 COMMERCE (CLAT ALIET CUET)"),
    MapEntry("CLASS 11 ARTS", "CLASS 11 ARTS (CLAT ALIET CUET)"),
    MapEntry("CLASS 12 SCIENCE", "CLASS 12 SCIENCE (IIT JEE NEET NDA)"),
    MapEntry("CLASS 12 COMMERCE", "CLASS 12 COMMERCE (CLAT ALIET CUET)"),
    MapEntry("CLASS 12 ARTS", "CLASS 12 ARTS (CLAT ALIET CUET)"),
    MapEntry("Dropper Batch Science", "After 12th Dropper Science"),
    MapEntry("Dropper Batch Commerce", "After 12th Dropper Commerce & Arts"),
  ];
  static const List<MapEntry<String,String>> class2Options = [
    MapEntry("NURSERY", "NURSERY"),
    MapEntry("LKG", "LKG"),
    MapEntry("UKG", "UKG"),
    MapEntry("CLASS 1", "CLASS 1"),
    MapEntry("CLASS 2", "CLASS 2"),
    MapEntry("CLASS 3", "CLASS 3"),
    MapEntry("CLASS 4", "CLASS 4"),
    MapEntry("CLASS 5", "CLASS 5"),
    MapEntry("CLASS 6", "CLASS 6"),
    MapEntry("CLASS 7", "CLASS 7"),
    MapEntry("CLASS 8", "CLASS 8"),
    MapEntry("CLASS 9", "CLASS 9"),
    MapEntry("CLASS 10", "CLASS 10"),
    MapEntry("CLASS 11 SCIENCE", "CLASS 11 SCIENCE"),
    MapEntry("CLASS 11 COMMERCE", "CLASS 11 COMMERCE"),
    MapEntry("CLASS 11 ARTS", "CLASS 11 ARTS"),
    MapEntry("CLASS 12 SCIENCE", "CLASS 12 SCIENCE"),
    MapEntry("CLASS 12 COMMERCE", "CLASS 12 COMMERCE"),
    MapEntry("CLASS 12 ARTS", "CLASS 12 ARTS"),
    MapEntry("Dropper Batch Science", "After 12th Dropper Science"),
    MapEntry("Dropper Batch Commerce", "After 12th Dropper Commerce & Arts"),
  ];
  static const List<MapEntry<String,String>> student_genderOptions = [
    MapEntry("male", "Male"),
    MapEntry("female", "Female"),
  ];
  static const List<MapEntry<String,String>> student_gender_2Options = [
    MapEntry("male", "Male"),
    MapEntry("female", "Female"),
  ];
  static const List<MapEntry<String,String>> batchOptions = [
    MapEntry("2026-2027", "Academic Session April 2026 - March 2027 (1 Year)"),
    MapEntry("2026-2028", "Academic Session April 2026 - March 2028 (2 Years)"),
    MapEntry("2026-2029", "Academic Session April 2026 - March 2029 (3 Years)"),
  ];
  static const List<MapEntry<String,String>> parent_typeOptions = [
    MapEntry("father_mother", "Parents Name"),
    MapEntry("single_mother", "Single Mother"),
    MapEntry("single_father", "Single Father"),
    MapEntry("guardian", "Guardian"),
  ];
  static const List<MapEntry<String,String>> father_occupationOptions = [
    MapEntry("Defence & Armed Forces", ">1. Defence (Army, Air Force, Navy) & Paramilitary Forces"),
    MapEntry("Central Govt Employees", ">2. Central Govt Employees"),
    MapEntry("State Govt Employees", ">3. State Government Employees"),
    MapEntry("Private Job", ">4. Private Job"),
    MapEntry("Business", ">5. Business"),
    MapEntry("Ex Defence Person", ">6. Ex Defence Person"),
    MapEntry("Farmers", ">7. Farmers"),
    MapEntry("Others", ">8. Others"),
  ];
  static const List<MapEntry<String,String>> family_incomeOptions = [
    MapEntry("Under 2 lakhs", "Under 2 lakhs (Guide Online Live Zoom Classes)"),
    MapEntry("2 lakhs to 4 Lakhs", "2 lakhs to 4 Lakhs"),
    MapEntry("4 lakhs to 6 lakhs", "4 lakhs to 6 lakhs"),
    MapEntry("6 lakhs to 8 lakhs", "6 lakhs to 8 lakhs"),
    MapEntry("More than 8 lakhs", "More than 8 lakhs"),
  ];
  static const List<MapEntry<String,String>> yearly_planOptions = [
    MapEntry("one_year", "One Year Admission Plan"),
    MapEntry("two_year", "Two Years Admission Plan"),
  ];
  String leadField(String key) => (widget.lead[key] ?? '').toString();

  @override
  void initState() {
    super.initState();
    for (final key in ['student_name','student_name_2','father_name','mother_name','guardian_name','contact_no','contact_no2','email','city2','custom_occupation','other_occupation','reference_admission','remarks','discount','received_amount','cibil_score','total_fees','one_time_fee','installment_1','installment_2','installment_3']) {
      inputs[key] = TextEditingController();
    }
    for (final key in ['appointment_type','visit_type','time_slot','interested','class','class2','student_gender','student_gender_2','batch','parent_type','father_occupation','family_income','yearly_plan','state','city','counsellor_id','junior_counsellor_id']) { choices[key]=''; }
    inputs['student_name']!.text = leadField('student_name');
    inputs['father_name']!.text = leadField('father_name');
    inputs['contact_no']!.text = leadField('mobile1');
    inputs['contact_no2']!.text = leadField('mobile2');
    inputs['city2']!.text = leadField('city');
    inputs['remarks']!.text = leadField('remark');
    choices['class'] = leadField('class_name').isNotEmpty ? leadField('class_name') : leadField('class');
    choices['father_occupation'] = leadField('father_occupation');
    choices['family_income'] = leadField('annual_family_income');
    choices['parent_type'] = 'father_mother';
    choices['state'] = leadField('state');
    choices['city'] = leadField('city');
    loadOptions();
  }

  @override
  void dispose() { for(final c in inputs.values){c.dispose();} super.dispose(); }
  String v(String key) => choices[key] ?? '';
  String t(String key) => inputs[key]?.text.trim() ?? '';

  Future<void> loadOptions() async {
    try {
      // Uses an added read-only API route; states also have an existing getAllStates API.
      final res = await ApiService.getMethod3('/getAppointmentDropdowns');
      final decoded = jsonDecode(res.body);
      if(decoded is Map) {
        List<MapEntry<String,String>> extract(String key, String valueKey, String labelKey) {
          final rows = decoded[key];
          if(rows is! List) return [];
          return rows.whereType<Map>().map((e)=>MapEntry((e[valueKey]??'').toString(),(e[labelKey]??'').toString())).where((e)=>e.key.isNotEmpty).toList();
        }
        stateOptions = extract('states','state_name','state_name');
        seniorOptions = [...extract('senior_counsellors','user_id','display_name'), const MapEntry('0','Individual')];
        juniorOptions = extract('counsellors','user_id','display_name');
      }
      if(v('state').isNotEmpty) await loadDistricts(v('state'));
    } catch (_) {
      // Fallback to existing state API; the form still displays a loading error for missing counselor data.
      try {
        final res = await ApiService.getMethod3('/getAllStates');
        final decoded = jsonDecode(res.body);
        final items = decoded is Map ? decoded['data'] : null;
        if(items is List) {
          stateOptions = items.whereType<Map>().map((e)=>MapEntry((e['state_name']??e['name']??'').toString(),(e['state_name']??e['name']??'').toString())).where((e)=>e.key.isNotEmpty).toList();
        }
      } catch (_) {}
    } finally { if(mounted) setState(()=>loadingOptions=false); }
  }

  Future<void> loadDistricts(String state) async {
    if(state.isEmpty){if(mounted)setState(()=>districtOptions=[]);return;}
    try {
      final uri = Uri(queryParameters: {'state':state}).query;
      final res = await ApiService.getMethod3('/getAppointmentDistricts?$uri');
      final data = jsonDecode(res.body);
      final rows = data is Map ? data['data'] : data;
      if(rows is List && mounted) {
        setState(() {districtOptions=rows.whereType<Map>().map((r)=>MapEntry((r['id']??'').toString(),(r['district_name']??'').toString())).where((r)=>r.key.isNotEmpty).toList();});
      }
    } catch (_) { if(mounted)setState(()=>districtOptions=[]); }
  }

  Widget selectField(String key,String label,List<MapEntry<String,String>> options,{bool required=false, ValueChanged<String>? after}) {
    final current=v(key);
    final list = [...options];
    if(current.isNotEmpty && !list.any((e)=>e.key==current)) list.insert(0,MapEntry(current,current));
    return Padding(padding:const EdgeInsets.only(bottom:12), child:DropdownButtonFormField<String>(
      value:current.isEmpty?null:current, isExpanded:true,
      decoration:InputDecoration(labelText:required?'$label *':label,border:const OutlineInputBorder(),isDense:true),
      items:list.map((e)=>DropdownMenuItem(value:e.key,child:Text(e.value,overflow:TextOverflow.ellipsis,maxLines:2))).toList(),
      validator:required?(x)=>(x==null||x.isEmpty)?'Please select $label':null:null,
      onChanged:(x){setState(()=>choices[key]=x??'');if(after!=null)after(x??'');},
    ));
  }
  Widget field(String key,String label,{bool required=false,TextInputType type=TextInputType.text,int lines=1,bool readonly=false}) =>
    Padding(padding:const EdgeInsets.only(bottom:12),child:TextFormField(
      controller:inputs[key],keyboardType:type,maxLines:lines,readOnly:readonly,
      decoration:InputDecoration(labelText:required?'$label *':label,border:const OutlineInputBorder(),isDense:true),
      validator:required?(x)=>x==null||x.trim().isEmpty?'$label is required':null:null));

  Widget heading(String s)=>Padding(padding:const EdgeInsets.fromLTRB(0,16,0,12),child:Text(s,style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold,color:primary)));
  Widget dateField(String label, DateTime? value, ValueChanged<DateTime> setValue) =>
    Padding(padding:const EdgeInsets.only(bottom:12),child:OutlinedButton.icon(icon:const Icon(Icons.calendar_today),label:Text(value==null?'Select $label': '$label: ${DateFormat('dd-MM-yyyy').format(value)}'),onPressed:()async{
      final d=await showDatePicker(context:context,firstDate:DateTime(2020),lastDate:DateTime(2040),initialDate:value??DateTime.now());
      if(d!=null&&mounted)setState(()=>setValue(d));
    }));
  String dateString(DateTime? d)=>d==null?'':DateFormat('yyyy-MM-dd').format(d);

  Future<void> save() async {
    if(!formKey.currentState!.validate())return;
    final typ=v('appointment_type');
    if((typ=='visit_only'||typ=='visit_dropping')&&visitDate==null ||
       (typ=='dropping_only'||typ=='visit_dropping')&&droppingDate==null || branches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Please select required date(s) and at least one branch')));return;
    }
    if(widget.staffId.isEmpty){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Staff login required')));return;}
    setState(()=>saving=true);
    try {
      final body=<String,dynamic>{...{for(final e in inputs.entries)e.key:e.value.text.trim()},...choices,
        'course':branches.join(', '),'visit_date':dateString(visitDate),'dropping_date':dateString(droppingDate),
        'followup_date':dateString(followupDate),'user_id':widget.staffId,'school_id':widget.schoolId,
        'lead_id':widget.lead['id']?.toString()??'', 'revisit':'No',
      };
      final response=await ApiService.postMethod3('/addAppointmentFromApp',jsonEncode(body));
      if(!mounted)return;
      if(response['success']==true || response['status'].toString()=='1'){
        Fluttertoast.showToast(msg:response['message']?.toString()??'Appointment saved');
        Navigator.pop(context,true);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(response['message']?.toString()??'Save failed')));
      }
    }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Save failed: $e')));}
    finally{if(mounted)setState(()=>saving=false);}
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(appBar:AppBar(title:const Text('Add Appointment'),backgroundColor:primary,foregroundColor:Colors.white),
      body:Form(key:formKey,child:ListView(padding:const EdgeInsets.all(16),children:[
        heading('Appointment Details'),
        selectField('appointment_type','Appointment Type',appointment_typeOptions,required:true),
        selectField('visit_type','Visit Type',visit_typeOptions),
        field('reference_admission','Reference Admission'),
        if(v('appointment_type')=='visit_only'||v('appointment_type')=='visit_dropping')dateField('Visit Date',visitDate,(d)=>visitDate=d),
        if(v('appointment_type')=='dropping_only'||v('appointment_type')=='visit_dropping')dateField('Dropping Date',droppingDate,(d)=>droppingDate=d),
        selectField('time_slot','Appointment Time Slot',time_slotOptions,required:true),
        selectField('interested','Parent/Student Interested For',interestedOptions,required:true),
        heading('Student Information'),
        field('student_name','Student Name',required:true),
        selectField('class','First Student Class',classOptions,required:true),
        selectField('student_gender','First Student Gender',student_genderOptions,required:true),
        field('student_name_2','Second Student Name (optional)'),
        selectField('class2','Second Student Class',class2Options),
        selectField('student_gender_2','Second Student Gender',student_gender_2Options),
        const Text('Interested Branch Visits *',style:TextStyle(fontWeight:FontWeight.w600)),
        for(final b in ['Ambala Branch','Patiala Branch','Yamunanagar Branch'])CheckboxListTile(
          dense:true,contentPadding:EdgeInsets.zero,title:Text(b),value:branches.contains(b),
          onChanged:(on)=>setState((){if(on==true){branches.add(b);}else{branches.remove(b);}})),
        selectField('batch','Academic Session',batchOptions,required:true),
        heading('Parent Information'),
        selectField('parent_type','Parent Type',parent_typeOptions,required:true),
        if(v('parent_type')=='father_mother'||v('parent_type')=='single_father')field('father_name','Father Name',required:true),
        if(v('parent_type')=='father_mother'||v('parent_type')=='single_mother')field('mother_name','Mother Name',required:true),
        if(v('parent_type')=='guardian')field('guardian_name','Guardian Name',required:true),
        selectField('father_occupation','Occupation',father_occupationOptions,required:true),
        field('custom_occupation','Occupation Sub Category'),
        if(v('father_occupation')=='Others')field('other_occupation','Other Occupation'),
        selectField('family_income','Family Budget / Income',family_incomeOptions,required:true),
        heading('Contact Information'),
        field('contact_no','Contact No. 1',required:true,type:TextInputType.phone),
        field('contact_no2','Contact No. 2',type:TextInputType.phone),
        field('email','Email',type:TextInputType.emailAddress),
        selectField('state','State',stateOptions,required:true,after:(x){choices['city']='';loadDistricts(x);}),
        selectField('city','District',districtOptions,required:true),
        field('city2','City'),
        heading('Counsellor Information'),
        if(loadingOptions)const LinearProgressIndicator(),
        selectField('counsellor_id','Senior Counsellor',seniorOptions,required:true),
        selectField('junior_counsellor_id','Counsellor Name',juniorOptions),
        heading('School Fees Details'),
        selectField('yearly_plan','Yearly Admission Plan',yearly_planOptions,required:true),
        field('discount','Discount',type:TextInputType.number),
        field('total_fees','Total Fees',type:TextInputType.number),
        field('one_time_fee','One Time Fees',type:TextInputType.number),
        field('installment_1','1st Installment',type:TextInputType.number),
        field('installment_2','2nd Installment',type:TextInputType.number),
        field('installment_3','3rd Installment',type:TextInputType.number),
        field('received_amount','Received Amount',type:TextInputType.number),
        field('cibil_score','CIBIL Score',type:TextInputType.number),
        heading('Additional Details'),
        dateField('Follow-up Date',followupDate,(d)=>followupDate=d),
        field('remarks','Remarks',lines:3),
        const SizedBox(height:18),
        ElevatedButton.icon(onPressed:saving?null:save,icon:saving?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.save),label:Text(saving?'Saving...':'Save Appointment')),
        const SizedBox(height:24),
      ])),
    );
  }
}
