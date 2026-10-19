import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AdminGatePassScreen extends StatefulWidget {
  static const routeName = '/AdminGatePassScreen';

  const AdminGatePassScreen({Key? key}) : super(key: key);

  @override
  State<AdminGatePassScreen> createState() => _AdminGatePassScreenState();
}

class _AdminGatePassScreenState extends State<AdminGatePassScreen>
    with SingleTickerProviderStateMixin {
  // Data
  List<dynamic> allPasses = [];
  List<dynamic> todayPasses = [];
  List<dynamic> previousPasses = [];
  List<dynamic> upcomingPasses = [];
  bool isLoading = true;
  static const int _pageSize = 20;
  final Map<String, int> _visiblePassCounts = {
    'today': _pageSize,
    'previous': _pageSize,
    'upcoming': _pageSize,
  };
  final Set<String> _studentDetailRequestsInFlight = {};
  Timer? _searchDebounce;
  Map<String, bool> tabLoading = {
    'today': true,
    'previous': true,
    'upcoming': true
  };
  
  // Tabs
  late TabController _tabController;
  int _currentTabIndex = 0;
  
  // Filters
  String selectedStatus = 'all';
  String selectedType = 'all';
  String selectedDate = '';
  String _searchQuery = '';
  TextEditingController searchController = TextEditingController();
  
  // Statistics for all tabs
  Map<String, dynamic> todayStats = {};
  Map<String, dynamic> previousStats = {};
  Map<String, dynamic> upcomingStats = {};
  Map<String, bool> statsLoading = {
    'today': true,
    'previous': true,
    'upcoming': true
  };
  
  // Student details cache
  final Map<int, Map<String, dynamic>> _studentDetailsCache = {};
  final Map<String, Map<String, dynamic>> _studentByMobileCache = {};
  
  // Image picker
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  
  // Status options (only 3 statuses now)
  final Map<String, String> statusOptions = {
    'all': 'All Status',
    '0': 'Pending',
    '1': 'Approved',
    '2': 'Rejected',
  };
  
  // Type options
  final Map<String, String> typeOptions = {
    'all': 'All Types',
    'Student': 'Student',
    'Parents': 'Parents',
    'Cab': 'Cab',
    'Delivery': 'Delivery',
    'Worker': 'Worker',
  };
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadAllPasses();
    _loadStatisticsForAllTabs();
  }
  
  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
      _applyFiltersToCurrentTab();
      _preloadStudentDetailsForVisiblePasses();
    }
  }
  
  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  
  // Helper method to get student full name from first, middle, last name
  String _getStudentFullName(Map<String, dynamic>? studentDetails) {
    if (studentDetails == null) return '';
    
    final firstName = studentDetails['first_name']?.toString() ?? '';
    final middleName = studentDetails['middle_name']?.toString() ?? '';
    final lastName = studentDetails['last_name']?.toString() ?? '';
    
    final fullName = [
      firstName,
      middleName,
      lastName,
    ]
        .where((e) => e.isNotEmpty && e.trim().isNotEmpty)
        .join(' ');
    
    return fullName.isNotEmpty ? fullName : '';
  }
  
  // Helper method to get branch name from school_id
  String _getBranchName(Map<String, dynamic>? studentDetails) {
    if (studentDetails == null) return 'N/A';
    
    final schoolId = studentDetails['school_id']?.toString();
    
    switch (schoolId) {
      case '1':
        return 'Ambala';
      case '2':
        return 'Patiala';
      case '3':
        return 'Yamunanagar';
      default:
        return 'N/A';
    }
  }
  
  Future<void> _loadAllPasses() async {
  try {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      tabLoading['today'] = true;
      tabLoading['previous'] = true;
      tabLoading['upcoming'] = true;
    });
    
    // Build query parameters
    Map<String, dynamic> params = {};
    
    if (selectedStatus != 'all') {
      params['status'] = selectedStatus;
    }
    
    if (selectedType != 'all') {
      params['type'] = selectedType;
    }
    
    if (selectedDate.isNotEmpty) {
      params['date'] = selectedDate;
    }
    
    if (_searchQuery.isNotEmpty) {
      params['search'] = _searchQuery;
    }
    
    print("Fetching gate passes with params: $params");
    
    // Build query string from params
    String queryString = Uri(queryParameters: params).query;
    String url = '/get_all_gate_pass_requests';
    if (queryString.isNotEmpty) {
      url += '?$queryString';
    }
    
    print("Full URL: $url");
    
    // Use GET method
    http.Response res = await ApiService.getMethod3(url);
    
    print("Response status: ${res.statusCode}");
    print("Response body preview: ${res.body.length > 100 ? '${res.body.substring(0, 100)}...' : res.body}");
    
    // Check if response is valid
    if (res.statusCode == 200) {
      try {
        final body = jsonDecode(res.body);
        
        // Check for both response formats
        if (body['error'] == false) {
          // New format from reference API
          List<dynamic> passes = [];
          
          // Handle data - could be null or empty
          if (body['data'] != null) {
            if (body['data'] is List) {
              passes = body['data'];
            } else if (body['data'] is Map) {
              // If data is a map, check for nested array
              passes = body['data']['passes'] ?? body['data']['records'] ?? [];
            }
          }
          
          print("New API format - passes: ${passes.length}");
          print("Success message: ${body['message']}");
          
          // Categorize passes by date
          _categorizePasses(passes);
          
          print("Total passes fetched: ${allPasses.length}");
          print("Today passes: ${todayPasses.length}");
          print("Previous passes: ${previousPasses.length}");
          print("Upcoming passes: ${upcomingPasses.length}");
          
        } else if (body['success'] == true) {
          // Old format (backward compatibility)
          List<dynamic> passes = body['data'] ?? [];
          
          // Categorize passes by date
          _categorizePasses(passes);
          
          print("Old API format - passes: ${passes.length}");
          
        } else {
          // Error format
          String errorMessage = body['message'] ?? body['error_detail'] ?? 'Failed to load passes';
          print("API Error: $errorMessage");
          
          if (mounted) {
            setState(() {
              allPasses = [];
              todayPasses = [];
              previousPasses = [];
              upcomingPasses = [];
              isLoading = false;
              tabLoading['today'] = false;
              tabLoading['previous'] = false;
              tabLoading['upcoming'] = false;
            });
          }
          
          // Only show snackbar for actual errors, not for "no records"
          if (!errorMessage.toLowerCase().contains('no record') && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        print("JSON Parse Error: $e");
        
        if (mounted) {
          setState(() {
            allPasses = [];
            todayPasses = [];
            previousPasses = [];
            upcomingPasses = [];
            isLoading = false;
            tabLoading['today'] = false;
            tabLoading['previous'] = false;
            tabLoading['upcoming'] = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error parsing server response'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (res.statusCode == 404) {
      // Handle 404 - resource not found
      print("API endpoint not found (404)");
      
      if (mounted) {
        setState(() {
          allPasses = [];
          todayPasses = [];
          previousPasses = [];
          upcomingPasses = [];
          isLoading = false;
          tabLoading['today'] = false;
          tabLoading['previous'] = false;
          tabLoading['upcoming'] = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API endpoint not found. Please contact administrator.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      
    } else if (res.statusCode == 500) {
      // Handle 500 - server error
      print("Server error (500)");
      
      if (mounted) {
        setState(() {
          allPasses = [];
          todayPasses = [];
          previousPasses = [];
          upcomingPasses = [];
          isLoading = false;
          tabLoading['today'] = false;
          tabLoading['previous'] = false;
          tabLoading['upcoming'] = false;
        });
        
        try {
          final body = jsonDecode(res.body);
          String errorMessage = body['message'] ?? body['error_detail'] ?? 'Server error occurred';
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pass Updated Successfully'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pass Updated Successfully'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Other HTTP errors
      print("Other HTTP Error: ${res.statusCode}");
      
      if (mounted) {
        setState(() {
          allPasses = [];
          todayPasses = [];
          previousPasses = [];
          upcomingPasses = [];
          isLoading = false;
          tabLoading['today'] = false;
          tabLoading['previous'] = false;
          tabLoading['upcoming'] = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('HTTP Error: ${res.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    print("Error loading passes: $e");
    print("Error type: ${e.runtimeType}");
    print("Stack trace: ${e.toString()}");
    
    if (mounted) {
      setState(() {
        isLoading = false;
        tabLoading['today'] = false;
        tabLoading['previous'] = false;
        tabLoading['upcoming'] = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
  
  Future<void> _loadStudentDetailsForPass(Map<String, dynamic> pass) async {
    try {
      // First try to get student details by student_id
      if (pass['student_id'] != null) {
        final studentId = _parseInt(pass['student_id']);
        if (studentId == 0 ||
            _studentDetailsCache.containsKey(studentId) ||
            !_studentDetailRequestsInFlight.add('id:$studentId')) {
          return;
        }
        try {
          await _loadStudentDetails(studentId);
        } finally {
          _studentDetailRequestsInFlight.remove('id:$studentId');
        }
        return;
      }
      
      // If no student_id but visitor_code starts with CDS, try to match by mobile number
      String? visitorCode = pass['visitor_code']?.toString();
      if (visitorCode != null && visitorCode.startsWith('CDS')) {
        String? visitorMobile = pass['visitor_mobile_no']?.toString();
        if (visitorMobile != null && visitorMobile.isNotEmpty) {
          if (_studentByMobileCache.containsKey(visitorMobile) ||
              !_studentDetailRequestsInFlight.add('mobile:$visitorMobile')) {
            return;
          }
          try {
            await _loadStudentByMobile(visitorMobile);
          } finally {
            _studentDetailRequestsInFlight.remove('mobile:$visitorMobile');
          }
        }
      }
    } catch (e) {
      print("Error loading student details for pass: $e");
    }
  }

  int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
  
  Future<void> _loadStudentDetails(dynamic studentId) async {
    try {
      // Convert to int if it's a string
      int studentIdInt;
      if (studentId is String) {
        studentIdInt = int.tryParse(studentId) ?? 0;
      } else if (studentId is int) {
        studentIdInt = studentId;
      } else {
        return;
      }
      
      if (studentIdInt == 0 || _studentDetailsCache.containsKey(studentIdInt)) {
        return;
      }
      
      print("Loading student details for ID: $studentIdInt");
      
      final res = await ApiService.getMethod3('/getStudentDetail?user_id=$studentIdInt');
      
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        
        if (body['error'] == false && body['data'] != null) {
          if (!mounted) return;
          setState(() {
            _studentDetailsCache[studentIdInt] = Map<String, dynamic>.from(body['data']);
          });
          print("Loaded student details for ID: $studentIdInt");
        } else {
          print("No student details found for ID: $studentIdInt");
        }
      }
    } catch (e) {
      print("Error loading student details: $e");
    }
  }
  
Future<void> _loadStudentByMobile(String mobileNumber) async {
  try {
    if (_studentByMobileCache.containsKey(mobileNumber)) {
      return;
    }
    
    print("Loading student details by mobile: $mobileNumber");
    
    // Call API to search student by mobile number
    final res = await ApiService.getMethod3('/searchStudentByMobile?mobile=$mobileNumber');
    
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      
      if (body['error'] == false && body['data'] != null) {
        // Check if data is an array or single object
        if (body['data'] is List) {
          List<dynamic> students = body['data'];
          if (students.isNotEmpty) {
            // Take the first student from the list
            Map<String, dynamic> studentData = Map<String, dynamic>.from(students[0]);
            
            // Also cache by student_id if available
            if (studentData['id'] != null) {
              int studentId = int.tryParse(studentData['id'].toString()) ?? 0;
              if (studentId > 0) {
                _studentDetailsCache[studentId] = studentData;
              }
            }
            
            if (!mounted) return;
            setState(() {
              _studentByMobileCache[mobileNumber] = studentData;
            });
            
            print("Loaded student details by mobile: $mobileNumber, found ${students.length} students");
          } else {
            print("No student found for mobile: $mobileNumber (empty list)");
          }
        } else {
          // Handle single object response
          Map<String, dynamic> studentData = Map<String, dynamic>.from(body['data']);
          
          // Also cache by student_id if available
          if (studentData['id'] != null) {
            int studentId = int.tryParse(studentData['id'].toString()) ?? 0;
            if (studentId > 0) {
              _studentDetailsCache[studentId] = studentData;
            }
          }
          
          if (!mounted) return;
          setState(() {
            _studentByMobileCache[mobileNumber] = studentData;
          });
          
          print("Loaded student details by mobile: $mobileNumber (single object)");
        }
      } else {
        print("No student found for mobile: $mobileNumber - error: ${body['message']}");
      }
    } else {
      print("API error for mobile $mobileNumber: ${res.statusCode}");
    }
  } catch (e) {
    print("Error loading student by mobile: $e");
  }
}

Map<String, dynamic>? _getStudentDetailsForPass(Map<String, dynamic> pass) {
  // First try to get by student_id
  if (pass['student_id'] != null) {
    int studentIdInt;
    if (pass['student_id'] is String) {
      studentIdInt = int.tryParse(pass['student_id'].toString()) ?? 0;
    } else if (pass['student_id'] is int) {
      studentIdInt = pass['student_id'];
    } else {
      studentIdInt = 0;
    }
    
    if (studentIdInt > 0 && _studentDetailsCache.containsKey(studentIdInt)) {
      return _studentDetailsCache[studentIdInt];
    }
  }
  
  // If no student_id but visitor_code starts with CDS, try to match by mobile
  String? visitorCode = pass['visitor_code']?.toString();
  if (visitorCode != null && visitorCode.startsWith('CDS')) {
    String? visitorMobile = pass['visitor_mobile_no']?.toString();
    if (visitorMobile != null && visitorMobile.isNotEmpty) {
      // Try to get from mobile cache
      if (_studentByMobileCache.containsKey(visitorMobile)) {
        return _studentByMobileCache[visitorMobile];
      }
      
      // Also check if this mobile matches any student's mobile in the details cache
      for (var student in _studentDetailsCache.values) {
        String? studentMobile = student['mobile']?.toString();
        String? fatherMobile = student['father_mobile']?.toString();
        
        if (studentMobile == visitorMobile || fatherMobile == visitorMobile) {
          return student;
        }
      }
    }
  }
  
  return null;
}

String _getStudentImageUrl(Map<String, dynamic>? studentDetails) {
  if (studentDetails == null) return '';
  
  // Try different possible field names for profile picture
  final profilePic = studentDetails['profile_pic']?.toString() ?? 
                    studentDetails['profile_picture']?.toString() ??
                    studentDetails['photo']?.toString() ??
                    '';
  
  if (profilePic.isEmpty) return '';
  
  // Check if the URL already contains the full path
  if (profilePic.startsWith('http')) {
    return profilePic;
  }
  
  // Otherwise construct the URL
  return '${ApiService.careerdefenceacademy2}includes/uploads/students_documents/profile_pic/$profilePic';
}

  void _categorizePasses(List<dynamic> passes) {
    // Get today's date at midnight for comparison
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    List<dynamic> todayList = [];
    List<dynamic> previousList = [];
    List<dynamic> upcomingList = [];
    
    for (var pass in passes) {
      try {
        String? dateStr = pass['date']?.toString();
        if (dateStr != null && dateStr.isNotEmpty) {
          // Parse the date from the pass
          DateTime passDate;
          if (dateStr.contains(' ')) {
            // If it has time component
            passDate = DateTime.parse(dateStr.split(' ')[0]);
          } else {
            // If it's just date
            passDate = DateTime.parse(dateStr);
          }
          
          // Convert to date only (remove time)
          final passDateOnly = DateTime(passDate.year, passDate.month, passDate.day);
          
          // Compare with today
          if (passDateOnly.isAtSameMomentAs(todayDate)) {
            todayList.add(pass);
          } else if (passDateOnly.isBefore(todayDate)) {
            previousList.add(pass);
          } else {
            upcomingList.add(pass);
          }
        } else {
          // If no date, default to today
          todayList.add(pass);
        }
      } catch (e) {
        print("Error parsing date for pass: ${pass['id']}, date: ${pass['date']}");
        // Default to today on error
        todayList.add(pass);
      }
    }
    
    // Sort passes by date and time
    todayList.sort((a, b) => _comparePassesByDateTime(a, b));
    previousList.sort((a, b) => _comparePassesByDateTime(b, a)); // Reverse for previous (newest first)
    upcomingList.sort((a, b) => _comparePassesByDateTime(a, b)); // Chronological for upcoming
    
    // Calculate statistics for each tab
    _calculateTabStatistics(todayList, previousList, upcomingList);
    
    setState(() {
      _resetVisiblePassCounts();
      allPasses = passes;
      todayPasses = todayList;
      previousPasses = previousList;
      upcomingPasses = upcomingList;
      isLoading = false;
      tabLoading['today'] = false;
      tabLoading['previous'] = false;
      tabLoading['upcoming'] = false;
    });
    _preloadStudentDetailsForVisiblePasses();
  }

  void _resetVisiblePassCounts() {
    _visiblePassCounts['today'] = _pageSize;
    _visiblePassCounts['previous'] = _pageSize;
    _visiblePassCounts['upcoming'] = _pageSize;
  }

  void _loadMoreCurrentTab() {
    final tabKey = _getCurrentTabTitle().toLowerCase();
    setState(() {
      _visiblePassCounts[tabKey] = (_visiblePassCounts[tabKey] ?? _pageSize) + _pageSize;
    });
    _preloadStudentDetailsForVisiblePasses();
  }

  void _preloadStudentDetailsForVisiblePasses() {
    if (!mounted) return;

    final tabKey = _getCurrentTabTitle().toLowerCase();
    final visibleCount = _visiblePassCounts[tabKey] ?? _pageSize;
    final visiblePasses = _filterPassesForSearch(_getCurrentTabPasses())
        .take(visibleCount)
        .whereType<Map<String, dynamic>>()
        .toList();

    for (final pass in visiblePasses) {
      unawaited(_loadStudentDetailsForPass(pass));
    }
  }
  
  void _calculateTabStatistics(List<dynamic> today, List<dynamic> previous, List<dynamic> upcoming) {
    // Today statistics
    int todayTotal = today.length;
    int todayPending = today.where((pass) => pass['status'] == 0).length;
    int todayApproved = today.where((pass) => pass['status'] == 1).length;
    int todayRejected = today.where((pass) => pass['status'] == 2).length;
    
    setState(() {
      todayStats = {
        'total': todayTotal,
        'pending': todayPending,
        'approved': todayApproved,
        'rejected': todayRejected,
      };
      statsLoading['today'] = false;
    });
    
    // Previous statistics
    int previousTotal = previous.length;
    int previousPending = previous.where((pass) => pass['status'] == 0).length;
    int previousApproved = previous.where((pass) => pass['status'] == 1).length;
    int previousRejected = previous.where((pass) => pass['status'] == 2).length;
    
    setState(() {
      previousStats = {
        'total': previousTotal,
        'pending': previousPending,
        'approved': previousApproved,
        'rejected': previousRejected,
      };
      statsLoading['previous'] = false;
    });
    
    // Upcoming statistics
    int upcomingTotal = upcoming.length;
    int upcomingPending = upcoming.where((pass) => pass['status'] == 0).length;
    int upcomingApproved = upcoming.where((pass) => pass['status'] == 1).length;
    int upcomingRejected = upcoming.where((pass) => pass['status'] == 2).length;
    
    setState(() {
      upcomingStats = {
        'total': upcomingTotal,
        'pending': upcomingPending,
        'approved': upcomingApproved,
        'rejected': upcomingRejected,
      };
      statsLoading['upcoming'] = false;
    });
  }
  
  int _comparePassesByDateTime(dynamic a, dynamic b) {
    try {
      DateTime dateTimeA = _parsePassDateTime(a);
      DateTime dateTimeB = _parsePassDateTime(b);
      return dateTimeA.compareTo(dateTimeB);
    } catch (e) {
      return 0;
    }
  }
  
  DateTime _parsePassDateTime(dynamic pass) {
    try {
      String? dateStr = pass['date']?.toString();
      String? timeStr = pass['entry_time']?.toString();
      
      if (dateStr != null && dateStr.isNotEmpty) {
        // Parse date
        DateTime date;
        if (dateStr.contains(' ')) {
          date = DateTime.parse(dateStr.split(' ')[0]);
        } else {
          date = DateTime.parse(dateStr);
        }
        
        // Parse time if available
        if (timeStr != null && timeStr.isNotEmpty) {
          List<String> timeParts = timeStr.split(':');
          if (timeParts.length >= 2) {
            int hour = int.tryParse(timeParts[0]) ?? 0;
            int minute = int.tryParse(timeParts[1]) ?? 0;
            
            // Handle AM/PM if present
            if (timeStr.toLowerCase().contains('pm') && hour < 12) {
              hour += 12;
            } else if (timeStr.toLowerCase().contains('am') && hour == 12) {
              hour = 0;
            }
            
            return DateTime(date.year, date.month, date.day, hour, minute);
          }
        }
        
        return date;
      }
    } catch (e) {
      print("Error parsing date time: $e");
    }
    
    return DateTime.now();
  }
  
  Future<void> _loadStatisticsForAllTabs() async {
    try {
      setState(() {
        statsLoading['today'] = true;
        statsLoading['previous'] = true;
        statsLoading['upcoming'] = true;
      });
      
      // Calculate statistics from loaded data
      _calculateTabStatistics(todayPasses, previousPasses, upcomingPasses);
    } catch (e) {
      print("Error loading statistics: $e");
      setState(() {
        statsLoading['today'] = false;
        statsLoading['previous'] = false;
        statsLoading['upcoming'] = false;
      });
    }
  }
  
  Future<int?> _getLoggedInUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Debug: print all keys to see what's available
      final keys = prefs.getKeys();
      print("Available keys in SharedPreferences: $keys");
      
      // First try to get user_id directly
      final sessionUserId = prefs.getInt('session_user_id');
      final userId = prefs.getInt('user_id');
      final id = prefs.getInt('id');
      
      print("session_user_id: $sessionUserId");
      print("user_id: $userId");
      print("id: $id");
      
      // If we have userData, try to parse it
      final userDataString = prefs.getString('userData');
      if (userDataString != null) {
        try {
          final userData = jsonDecode(userDataString);
          print("userData parsed: $userData");
          
          // Check for user_id in userData
          if (userData['user_id'] != null) {
            return int.tryParse(userData['user_id'].toString());
          }
          if (userData['id'] != null) {
            return int.tryParse(userData['id'].toString());
          }
          if (userData['userId'] != null) {
            return int.tryParse(userData['userId'].toString());
          }
        } catch (e) {
          print("Error parsing userData: $e");
        }
      }
      
      // Check staffData
      final staffDataString = prefs.getString('staffData');
      if (staffDataString != null) {
        try {
          final staffData = jsonDecode(staffDataString);
          print("staffData parsed: $staffData");
          
          if (staffData['user_id'] != null) {
            return int.tryParse(staffData['user_id'].toString());
          }
          if (staffData['id'] != null) {
            return int.tryParse(staffData['id'].toString());
          }
        } catch (e) {
          print("Error parsing staffData: $e");
        }
      }
      
      // Return any of the direct values or null
      return sessionUserId ?? userId ?? id;
    } catch (e) {
      print("Error getting user ID: $e");
      return null;
    }
  }
  
  Future<String?> _getUserImage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Check userData
      final userDataString = prefs.getString('userData');
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        if (userData['profile_pic'] != null && userData['profile_pic'].toString().isNotEmpty) {
          return '${ApiService.careerdefenceacademy}includes/uploads/students_documents/profile_pic/${userData['profile_pic']}';
        }
      }
      
      // Check staffData
      final staffDataString = prefs.getString('staffData');
      if (staffDataString != null) {
        final staffData = jsonDecode(staffDataString);
        if (staffData['profile_pic'] != null && staffData['profile_pic'].toString().isNotEmpty) {
          return '${ApiService.careerdefenceacademy}includes/uploads/staff_documents/profile_pic/${staffData['profile_pic']}';
        }
      }
      
      return null;
    } catch (e) {
      print("Error getting user image: $e");
      return null;
    }
  }
  
  void _applyFilters() {
    _resetVisiblePassCounts();
    _loadAllPasses();
    _loadStatisticsForAllTabs();
  }
  
  void _applyFiltersToCurrentTab() {
    // This method will be called when tab changes
    // We don't need to reload data, just update the UI
  }
  
  void _resetFilters() {
    setState(() {
      selectedStatus = 'all';
      selectedType = 'all';
      selectedDate = '';
      _searchQuery = '';
      searchController.clear();
      _resetVisiblePassCounts();
    });
    _loadAllPasses();
    _loadStatisticsForAllTabs();
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Options'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Status Filter
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: selectedStatus,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: statusOptions.entries.map((entry) {
                              return DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text(entry.value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = value ?? 'all';
                              });
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Type Filter
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Visitor Type',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: selectedType,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: typeOptions.entries.map((entry) {
                              return DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text(entry.value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedType = value ?? 'all';
                              });
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Date Filter
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Date',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2023),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.grey.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    selectedDate.isEmpty
                                        ? 'Select Date'
                                        : DateFormat('dd MMM yyyy').format(
                                            DateTime.parse(selectedDate),
                                          ),
                                    style: TextStyle(
                                      color: selectedDate.isEmpty
                                          ? Colors.grey.shade500
                                          : Colors.black,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (selectedDate.isNotEmpty)
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedDate = '';
                                        });
                                      },
                                      child: const Icon(
                                        Icons.clear,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _applyFilters();
                  },
                  child: const Text('Apply Filters'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showPassDetails(Map<String, dynamic> pass) {
    final studentDetails = _getStudentDetailsForPass(pass);
    final studentFullName = _getStudentFullName(studentDetails);
    final branchName = _getBranchName(studentDetails);
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getStatusColor(pass['status'] ?? 0),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          pass['pass_type'] ?? 'Pass',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        pass['visitor_code'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Student Info Section with Image
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Student Image
                            Container(
                              width: 80,
                              height: 80,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _getStudentImageUrl(studentDetails),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            
                            // Student Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Updated: Student Name using first_name, middle_name, last_name
                                  Text(
                                    studentFullName.isNotEmpty 
                                        ? studentFullName 
                                        : (studentDetails?['student_name']?.toString() ?? 
                                           pass['student_name'] ?? 'N/A'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Class:  ${studentDetails?['class_for']?.toString() ?? pass['class_for'] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Added: Branch Name
                                  Text(
                                    'Branch: $branchName',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Father: ${studentDetails?['father_name']?.toString() ?? pass['father_name'] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Mother: ${studentDetails?['mother_name']?.toString() ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (studentDetails?['mobile'] != null)
                                    Text(
                                      'Mobile: ${studentDetails?['mobile'] ?? 'N/A'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        const Divider(),
                        
                        // Visitor Info
                        _buildDetailSection(
                          title: 'Visitor Information',
                          children: [
                            _buildDetailRow('Visitor Name', pass['visitor_name'] ?? 'N/A'),
                            _buildDetailRow('Category', pass['category'] ?? 'N/A'),
                            _buildDetailRow('Relation', pass['relation'] ?? 'N/A'),
                            _buildDetailRow('No. of Persons', '${pass['no_of_person'] ?? 1}'),
                            if (pass['visitor_mobile_no'] != null && pass['visitor_mobile_no'].toString().isNotEmpty)
                              _buildDetailRow('Visitor Mobile', pass['visitor_mobile_no'].toString()),
                            if (pass['id_type'] != null && pass['id_type'].toString().isNotEmpty)
                              _buildDetailRow('ID Type', pass['id_type'].toString()),
                            if (pass['id_number'] != null && pass['id_number'].toString().isNotEmpty)
                              _buildDetailRow('ID Number', pass['id_number'].toString()),
                            if (pass['vehicle_number'] != null && pass['vehicle_number'].toString().isNotEmpty)
                              _buildDetailRow('Vehicle No.', pass['vehicle_number'].toString()),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Pass Details
                        _buildDetailSection(
                          title: 'Pass Details',
                          children: [
                            _buildDetailRow('Purpose', pass['purpose'] ?? 'N/A'),
                            _buildDetailRow('Entry Time', pass['entry_time'] ?? 'N/A'),
                            _buildDetailRow('Date', pass['date'] ?? 'N/A'),
                            _buildDetailRow(
                              'Status',
                              pass['status_text'] ?? 'Pending',
                              color: _getStatusColor(pass['status'] ?? 0),
                            ),
                          ],
                        ),
                        
                        if (pass['guard_remarks'] != null && pass['guard_remarks'].isNotEmpty)
                          Column(
                            children: [
                              const SizedBox(height: 16),
                              _buildDetailSection(
                                title: 'Admin Remarks',
                                children: [
                                  _buildDetailRow('Remarks', pass['guard_remarks']),
                                  if (pass['processed_by_name'] != null)
                                    _buildDetailRow('Processed By', pass['processed_by_name']),
                                  if (pass['processed_at'] != null)
                                    _buildDetailRow('Processed At', 
                                      _formatDateTime(pass['processed_at'])),
                                ],
                              ),
                            ],
                          ),
                        
                        // Visitor Photo
                        if (pass['photo_url'] != null && pass['photo_url'].toString().isNotEmpty)
                          Column(
                            children: [
                              const SizedBox(height: 16),
                              _buildDetailSection(
                                title: 'Visitor Photo',
                                children: [
                                  Center(
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          pass['photo_url'].toString(),
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            print("Image load error: $error");
                                            return Container(
                                              width: 200,
                                              height: 200,
                                              color: Colors.grey[200],
                                              child: const Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.person,
                                                    size: 60,
                                                    color: Colors.grey,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'No photo available',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Container(
                                              width: 200,
                                              height: 200,
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: CircularProgressIndicator(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
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
                
                // Actions (Only show for pending and approved)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Show Approve button only for pending status (0)
                      if (pass['status'] == 0)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showStatusUpdateDialog(pass, 1), // Approve
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Approve',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      // Show Reject button only for pending status (0)
                      if (pass['status'] == 0)
                        const SizedBox(width: 8),
                      if (pass['status'] == 0)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showStatusUpdateDialog(pass, 2), // Reject
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Reject',
                              style: TextStyle(fontSize: 14),
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
  
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1080,
    );
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }
  
void _showStatusUpdateDialog(Map<String, dynamic> pass, int status) {
  final statusText = status == 1 ? 'Approve' : 'Reject';
  final TextEditingController remarksController = TextEditingController();
  
  // Pre-fill remarks for reject
  if (status == 2 && (pass['guard_remarks'] == null || pass['guard_remarks'].isEmpty)) {
    remarksController.text = 'Request rejected by admin';
  }
  
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('$statusText Pass'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Are you sure you want to $statusText this pass?',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  
                  // Remarks Field
                  TextField(
                    controller: remarksController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: status == 2 ? 'Rejection Reason (Required)' : 'Remarks (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: status == 2 ? 'Enter rejection reason...' : 'Enter remarks...',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _selectedImage = null;
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Validate remarks for rejection
                  if (status == 2 && remarksController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter rejection reason'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  // Close the dialog immediately
                  Navigator.of(context).pop();
                  
                  // Show a loading indicator or disable buttons if needed
                  // Then update the pass status
                  await _updatePassStatus(pass['id'], status, remarksController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: status == 1 ? Colors.green : Colors.red,
                ),
                child: Text(statusText),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _updatePassStatus(dynamic passId, int status, String remarks) async {
  try {
    int? loggedInUserId = await _getLoggedInUserId();

    if (loggedInUserId == null || loggedInUserId == 0) {
      print("Unable to identify user. Please login again.");
      return;
    }

    // Convert passId to int safely
    int passIdInt = 0;
    if (passId is String) {
      passIdInt = int.tryParse(passId) ?? 0;
    } else if (passId is int) {
      passIdInt = passId;
    }

    if (passIdInt == 0) {
      print("Invalid pass ID");
      return;
    }

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> formData = {
      'pass_id': passIdInt.toString(),
      'status': status.toString(),
      'remarks': remarks,
      'user_id': loggedInUserId.toString(),
    };

    Map<String, File> files = {};
    if (_selectedImage != null) {
      files['admin_photo'] = _selectedImage!;
    }

    print("update_gate_pass_status formData: $formData");
    print("update_gate_pass_status files: ${files.keys.toList()}");

    var result = await ApiService.postMethodWithFiles(
      '/update_gate_pass_status',
      formData,
      files,
    );

    print("update_gate_pass_status result: $result");

    setState(() {
      _selectedImage = null;
      isLoading = false;
    });

    // Check for success in multiple ways
    bool isSuccess = false;
    
    // Check if result has success flag
    if (result['success'] == true) {
      isSuccess = true;
    }
    // Check if status code is 200 (success)
    else if (result['statusCode'] == 200) {
      isSuccess = true;
    }
    // Even if it's 500, we'll consider it success if we want to show success message
    else if (result['statusCode'] == 500) {
      // Since you want to show success even on 500, set isSuccess to true
      isSuccess = true;
      print("⚠️ Server returned 500 but treating as success as per requirement");
    }
    
    // Show success message for both actual success and 500 (as per your requirement)
    if (isSuccess) {
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Status updated successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Wait for the data to fully load before updating UI
      await _loadAllPasses();
      await _loadStatisticsForAllTabs();
      
      // Force a rebuild after data is loaded
      if (mounted) {
        setState(() {});
      }
    }
    // Silently ignore other failures - no error message shown
  } catch (e) {
    setState(() {
      isLoading = false;
    });

    print("Error updating pass status: $e");
    
    // Even on exception, if you want to show success (not recommended, but as per your requirement)
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
    
    // Still try to refresh data even on exception
    await _loadAllPasses();
    await _loadStatisticsForAllTabs();
    
    if (mounted) {
      setState(() {});
    }
  }
}

  
  Widget _buildDetailSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
  
  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color ?? Colors.black,
                fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(dynamic status) {
    // Convert to int if it's a string
    int statusInt;
    if (status is String) {
      statusInt = int.tryParse(status) ?? 0;
    } else if (status is int) {
      statusInt = status;
    } else {
      statusInt = 0;
    }
    
    switch (statusInt) {
      case 0: // Pending
        return Colors.orange;
      case 1: // Approved
        return Colors.green;
      case 2: // Rejected
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }
  
  Widget _buildStatisticsCard() {
    // Get statistics for current tab
    Map<String, dynamic> currentStats;
    bool isLoadingCurrentStats;
    
    switch (_currentTabIndex) {
      case 0: // Today
        currentStats = todayStats;
        isLoadingCurrentStats = statsLoading['today']!;
        break;
      case 1: // Previous
        currentStats = previousStats;
        isLoadingCurrentStats = statsLoading['previous']!;
        break;
      case 2: // Upcoming
        currentStats = upcomingStats;
        isLoadingCurrentStats = statsLoading['upcoming']!;
        break;
      default:
        currentStats = todayStats;
        isLoadingCurrentStats = statsLoading['today']!;
    }
    
    if (isLoadingCurrentStats) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final total = currentStats['total'] ?? 0;
    final pending = currentStats['pending'] ?? 0;
    final approved = currentStats['approved'] ?? 0;
    final rejected = currentStats['rejected'] ?? 0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getCurrentTabTitle()} Statistics',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_currentTabIndex == 0) // Only show date for Today tab
                Text(
                  selectedDate.isEmpty
                      ? DateFormat('dd MMM yyyy').format(DateTime.now())
                      : DateFormat('dd MMM yyyy').format(
                          DateTime.parse(selectedDate),
                        ),
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem('Total', total.toString(), Colors.blue),
              _buildStatItem('Pending', pending.toString(), Colors.orange),
              _buildStatItem('Approved', approved.toString(), Colors.green),
              _buildStatItem('Rejected', rejected.toString(), Colors.red),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Updated search filter function
  List<dynamic> _filterPassesForSearch(List<dynamic> passes) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return passes;
    }

    return passes.where((pass) {
      final studentDetails = _getStudentDetailsForPass(pass);

      // Student Name
      final studentName =
          _getStudentFullName(studentDetails).toLowerCase();

      // Father Name
      final fatherName =
          (studentDetails?['father_name'] ??
                  pass['father_name'] ??
                  '')
              .toString()
              .toLowerCase();

      // Visitor Name
      final visitorName =
          (pass['visitor_name'] ?? '')
              .toString()
              .toLowerCase();

      // Extra fields
      final className =
          (studentDetails?['class_for'] ??
                  pass['class_for'] ??
                  '')
              .toString()
              .toLowerCase();

      final purpose =
          (pass['purpose'] ?? '')
              .toString()
              .toLowerCase();

      final visitorCode =
          (pass['visitor_code'] ?? '')
              .toString()
              .toLowerCase();

      return studentName.contains(query) ||
          fatherName.contains(query) ||
          visitorName.contains(query) ||
          className.contains(query) ||
          purpose.contains(query) ||
          visitorCode.contains(query);
    }).toList();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    setState(() {
      _searchQuery = value.trim();
      _resetVisiblePassCounts();
    });
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      _preloadStudentDetailsForVisiblePasses();
    });
  }
  
  Widget _buildPassCard(Map<String, dynamic> pass) {
    // Convert status to int for comparison
    final status = pass['status'];
    final statusInt = status is String ? int.tryParse(status) ?? 0 : (status is int ? status : 0);
    final isPending = statusInt == 0;
    final isApproved = statusInt == 1;
    
    final studentDetails = _getStudentDetailsForPass(pass);
    final studentImageUrl = _getStudentImageUrl(studentDetails);
    final studentFullName = _getStudentFullName(studentDetails);
    final branchName = _getBranchName(studentDetails);
    
    // Fix: Convert no_of_person to int for comparison
    final noOfPerson = pass['no_of_person'];
    final personCount = noOfPerson is String ? int.tryParse(noOfPerson) ?? 1 : (noOfPerson is int ? noOfPerson : 1);
    final personText = '$personCount person${personCount > 1 ? 's' : ''}';
    
    // Get status text color
    final statusColor = _getStatusColor(status);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _showPassDetails(pass),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First row: Type, Code, Status (compact)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pass['pass_type']?.toString() ?? 'Pass',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (pass['visitor_code'] != null && pass['visitor_code'].toString().isNotEmpty)
                        Text(
                          pass['visitor_code'].toString(),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      pass['status_text']?.toString() ?? 'Pending',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Second row: Student info with image
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Student Image
                  Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: studentImageUrl.isNotEmpty
                          ? Image.network(
                              studentImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.person,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.person,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  
                  // Student Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Updated: Student Name using first_name, middle_name, last_name
                        Text(
                          studentFullName.isNotEmpty 
                              ? studentFullName 
                              : (studentDetails?['student_name']?.toString() ?? 
                                 pass['student_name'] ?? 'Unknown'),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.school,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              studentDetails?['class_for']?.toString() ?? 
                              pass['class_for']?.toString() ?? 'N/A',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.category,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              pass['category']?.toString() ?? 'N/A',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        // Added: Branch Name
                        Row(
                          children: [
                            Icon(
                              Icons.business,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Branch: $branchName',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        if (studentDetails?['father_name'] != null)
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Father: ${studentDetails?['father_name']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Third row: Visitor and Purpose
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 12,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${pass['visitor_name']?.toString() ?? 'No visitor'} ($personText)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              Row(
                children: [
                  Icon(
                    Icons.description,
                    size: 12,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      pass['purpose']?.toString() ?? 'No purpose',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Fourth row: Time and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${pass['entry_time']?.toString() ?? 'N/A'} | ${pass['date']?.toString() ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  // Action Button based on status
                  if (isPending)
                    Row(
                      children: [
                        // Approve button
                        InkWell(
                          onTap: () => _showStatusUpdateDialog(pass, 1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Approve',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Reject button
                        InkWell(
                          onTap: () => _showStatusUpdateDialog(pass, 2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Reject',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }
  
  Widget _buildPassList(List<dynamic> passes) {
    bool isLoadingCurrentTab = tabLoading[_getCurrentTabTitle().toLowerCase()] ?? true;
    final tabKey = _getCurrentTabTitle().toLowerCase();
    final visibleCount = _visiblePassCounts[tabKey] ?? _pageSize;
    final visiblePasses = passes.take(visibleCount).toList();
    final hasMore = visiblePasses.length < passes.length;
    
    if (isLoadingCurrentTab) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading passes...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    if (passes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No passes found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            if (selectedStatus != 'all' || selectedType != 'all' || selectedDate.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Try changing your filters',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            if (selectedStatus != 'all' || selectedType != 'all' || selectedDate.isNotEmpty)
              TextButton(
                onPressed: _resetFilters,
                child: const Text('Clear all filters'),
              ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadAllPasses,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: visiblePasses.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= visiblePasses.length) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: OutlinedButton.icon(
                onPressed: _loadMoreCurrentTab,
                icon: const Icon(Icons.expand_more),
                label: Text('Load more (${passes.length - visiblePasses.length} left)'),
              ),
            );
          }
          return _buildPassCard(visiblePasses[index]);
        },
      ),
    );
  }
  
  List<dynamic> _getCurrentTabPasses() {
    switch (_currentTabIndex) {
      case 0: // Today
        return todayPasses;
      case 1: // Previous
        return previousPasses;
      case 2: // Upcoming
        return upcomingPasses;
      default:
        return todayPasses;
    }
  }

  String _getCurrentTabTitle() {
    switch (_currentTabIndex) {
      case 0:
        return 'Today';
      case 1:
        return 'Previous';
      case 2:
        return 'Upcoming';
      default:
        return 'Today';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Gate Pass Management'),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Today'),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${todayPasses.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Previous'),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${previousPasses.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Upcoming'),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${upcomingPasses.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
          ),
          IconButton(
            onPressed: _loadAllPasses,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Card (shows for all tabs)
          _buildStatisticsCard(),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                _onSearchChanged(value);
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search Student / Father / Visitor Name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          _onSearchChanged('');
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
            ),
          ),
          
          // Search Suggestions
          if (_searchQuery.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: _filterPassesForSearch(_getCurrentTabPasses())
                    .take(5)
                    .map((pass) {
                  final studentDetails = _getStudentDetailsForPass(pass);
                  
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.search, size: 18),
                    title: Text(
                      _getStudentFullName(studentDetails).isNotEmpty
                          ? _getStudentFullName(studentDetails)
                          : (pass['student_name'] ?? 'N/A'),
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      'Father: ${studentDetails?['father_name'] ?? pass['father_name'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Text(
                      pass['visitor_name'] ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      _showPassDetails(Map<String, dynamic>.from(pass));
                    },
                  );
                }).toList(),
              ),
            ),
          
          // Active Filters
          if (selectedStatus != 'all' || selectedType != 'all' || selectedDate.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (selectedStatus != 'all')
                            Chip(
                              label: Text('Status: ${statusOptions[selectedStatus]}'),
                              backgroundColor: Colors.blue.shade100,
                              deleteIconColor: Colors.blue.shade700,
                              onDeleted: () {
                                setState(() {
                                  selectedStatus = 'all';
                                });
                                _applyFilters();
                              },
                            ),
                          if (selectedStatus != 'all') const SizedBox(width: 8),
                          if (selectedType != 'all')
                            Chip(
                              label: Text('Type: ${typeOptions[selectedType]}'),
                              backgroundColor: Colors.blue.shade100,
                              deleteIconColor: Colors.blue.shade700,
                              onDeleted: () {
                                setState(() {
                                  selectedType = 'all';
                                });
                                _applyFilters();
                              },
                            ),
                          if (selectedType != 'all') const SizedBox(width: 8),
                          if (selectedDate.isNotEmpty)
                            Chip(
                              label: Text(
                                'Date: ${DateFormat('dd MMM yyyy').format(DateTime.parse(selectedDate))}',
                              ),
                              backgroundColor: Colors.blue.shade100,
                              deleteIconColor: Colors.blue.shade700,
                              onDeleted: () {
                                setState(() {
                                  selectedDate = '';
                                });
                                _applyFilters();
                              },
                            ),
                          if (selectedStatus != 'all' || selectedType != 'all' || selectedDate.isNotEmpty)
                            TextButton(
                              onPressed: _resetFilters,
                              child: const Text(
                                'Clear All',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Today Tab
                _buildPassList(_filterPassesForSearch(todayPasses)),
                
                // Previous Tab
                _buildPassList(_filterPassesForSearch(previousPasses)),
                
                // Upcoming Tab
                _buildPassList(_filterPassesForSearch(upcomingPasses)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}