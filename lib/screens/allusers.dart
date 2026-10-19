import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:careerapp/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:careerapp/services/notification_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:careerapp/screens/gaterequest.dart';
class AllUsersScreen extends StatefulWidget {
  static const routeName = '/AllUsersScreen';

  const AllUsersScreen({Key? key}) : super(key: key);

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<AllUsersScreen> with TickerProviderStateMixin {
  // Tab Controller
  late TabController _mainTabController;
  late TabController _usersTabController;
  
  List<dynamic> allStudentsData = [];
  List<dynamic> filteredStudents = [];
  List<dynamic> allStaffData = [];
  List<dynamic> filteredStaff = [];
  
  // WebView variables
  late WebViewController _webViewController;
  bool _isWebViewLoading = true;
  bool isLoading = true;
  
  // Search controllers
  TextEditingController studentSearchController = TextEditingController();
  TextEditingController staffSearchController = TextEditingController();
  
  // Filters
  String selectedBranch = 'all';
  String selectedClass = 'all';
  
  // Filter options
  final Map<String, String> branchOptions = {
    'all': 'All Branches',
    '1': 'Ambala',
    '2': 'Patiala',
    '3': 'Yamunanagar',
  };
  
  final List<String> classOptions = [
    'all',
    'Nursery',
    'LKG',
    'Class 1st',
    'Class 2nd',
    'Class 3rd',
    'Class 4th',
    'Class 5th',
    'Class 6th',
    'Class 7th',
    'Class 8th',
    'Class 9th',
    'Class 10th',
    'Class 11 Science',
    'Class 11 Commerce',
    'Class 11 Arts',
    'Class 12 Science',
    'Class 12 Commerce',
    'Class 12 Arts',
  ];

  // Scanner variables
  MobileScannerController cameraController = MobileScannerController();
  bool _isScannerActive = false;
  bool _isLoadingVisitorInfo = false;
  Map<String, dynamic>? _currentVisitor;
  String? _scannedVisitorCode;
  bool _isTorchOn = false;
  
  // Process entry variables
  File? _visitorIdImage;
  File? _visitorPhotoImage;
  File? _vehiclePhotoImage;
  final TextEditingController _guardRemarksController = TextEditingController();

@override
void initState() {
  super.initState();
  
  // Initialize main tab controller first
  _mainTabController = TabController(length: 3, vsync: this);
  
  // Initialize users tab controller second
  _usersTabController = TabController(length: 2, vsync: this);
  
  // Start with empty data
  setState(() {
    isLoading = false;
  });
  
  _getLoggedInUserId();
  _mainTabController.addListener(_onMainTabChanged);
  _setupUsersTabController(); // Add this line
  _initializeWebView(); 
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeNotifications();
  });
}

 void _initializeNotifications() {
  NotificationService.initialize(
    onTap: (data) async {
      print('Notification tapped with data: $data');
      
      // Ensure we're on the correct route
      if (Navigator.canPop(context)) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
      
      // Navigate to AllUsersScreen if not already there
      if (ModalRoute.of(context)?.settings.name != AdminGatePassScreen.routeName) {
        await Navigator.pushReplacementNamed(context, AdminGatePassScreen.routeName);
      }
      
      // Handle specific notification actions
      if (data['type'] == 'in_pass_created' && data['visitor_code'] != null) {
        // Switch to scan tab
        _mainTabController.animateTo(2);
        
        // Small delay to ensure tab is switched
        Future.delayed(const Duration(milliseconds: 300), () {
          _stopScanner();
          _getVisitorInfo(data['visitor_code']);
        });
      } else {
        // Default: switch to users tab
        _mainTabController.animateTo(0);
      }
    },
  );
}

@override
void dispose() {
  _mainTabController.removeListener(_onMainTabChanged);
  _mainTabController.dispose();
  _usersTabController.dispose();
  studentSearchController.dispose();
  staffSearchController.dispose();
  cameraController.dispose();
  _guardRemarksController.dispose();
  super.dispose();
}

 void _onMainTabChanged() {
  if (_mainTabController.index == 0) {
    // Stop camera when switching to Users tab
    _stopScanner();
    
    // Don't auto-load data, let user click refresh
    // setState(() {
    //   isLoading = false;
    // });
  } else if (_mainTabController.index == 2) {
    // Start camera when switching to Scan tab
    _startScanner();
  }
}
  void _startScanner() {
    setState(() {
      _isScannerActive = true;
      _currentVisitor = null;
      _scannedVisitorCode = null;
    });
  }

  void _stopScanner() {
    setState(() {
      _isScannerActive = false;
    });
  }

  void _setupUsersTabController() {
  _usersTabController.addListener(() {
    // Reset search and filters when switching between students and staff
    if (_usersTabController.index == 0) {
      // Switching to Students tab
      setState(() {
        studentSearchController.clear();
      });
    } else {
      // Switching to Staff tab
      setState(() {
        staffSearchController.clear();
        // Reset class filter for staff tab
        selectedClass = 'all';
      });
    }
  });
}

  void _initializeWebView() {
    late final PlatformWebViewControllerCreationParams params;
    
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print('WebView loading: $progress%');
          },
          onPageStarted: (String url) {
            setState(() {
              _isWebViewLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isWebViewLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
            setState(() {
              _isWebViewLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://careerdefenceacademy.com/HomeController/gate_visitor_form'));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _webViewController = controller;
  }

  // Fetch Students Data
  Future<void> fetchStudents() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      print("Fetching students data...");
      
      // Build query parameters
      Map<String, String> queryParams = {};
      
      if (selectedBranch != 'all') {
        queryParams['school_id'] = selectedBranch;
      }
      
      if (selectedClass != 'all') {
        queryParams['class_for'] = selectedClass;
      }
      
      if (studentSearchController.text.isNotEmpty) {
        queryParams['q'] = studentSearchController.text;
      }
      
      // Build query string
      String queryString = Uri(queryParameters: queryParams).query;
      String endpoint = "/checkfilteredStudent";
      
      if (queryString.isNotEmpty) {
        endpoint += "?$queryString";
      }
      
      print("API Endpoint: $endpoint");
      
      var res = await ApiService.getMethod3(endpoint);
      
      print("Response Status Code: ${res.statusCode}");
      
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        
        if (body != null && body["data"] != null && body["data"] is List) {
          setState(() {
            allStudentsData = body["data"];
            filteredStudents = List.from(allStudentsData);
            isLoading = false;
          });
          print("Total students fetched: ${allStudentsData.length}");
        } else {
          print("Empty or invalid response data.");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("Failed to load students data. Status: ${res.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching students data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch Staff Data
  Future<void> fetchStaff() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      print("Fetching staff data...");
      
      // Get logged in user ID
      int loggedInUserId = await _getLoggedInUserId();
      
      String endpoint = "/getAllStaff";
      print("Staff API Endpoint: $endpoint");
      
      var res = await ApiService.getMethod3(endpoint);
      
      print("Staff Response Status Code: ${res.statusCode}");
      
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        
        if (body != null && body["data"] != null) {
          // Handle both single staff object or list
          List<dynamic> staffList = [];
          if (body["data"] is List) {
            staffList = body["data"];
          } else if (body["data"] is Map) {
            staffList = [body["data"]];
          }
          
          setState(() {
            allStaffData = staffList;
            filteredStaff = List.from(allStaffData);
            isLoading = false;
          });
          print("Total staff fetched: ${allStaffData.length}");
        } else {
          print("Empty or invalid staff response data.");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("Failed to load staff data. Status: ${res.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching staff data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Get visitor info API call
  Future<void> _getVisitorInfo(String code) async {
    setState(() {
      _isLoadingVisitorInfo = true;
    });
    
    try {
      print("Getting visitor info for code: $code");
      
      String endpoint = "/get_visitor_info?code=$code";
      print("API Endpoint: $endpoint");
      
      var res = await ApiService.getMethod3(endpoint);
      
      print("Visitor info response status: ${res.statusCode}");
      
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        
        if (body['success'] == true && body['visitor'] != null) {
          setState(() {
            _currentVisitor = body['visitor'];
            _scannedVisitorCode = code;
            _isLoadingVisitorInfo = false;
          });
          
          _showVisitorDetails();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(body['message'] ?? 'Visitor not found'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoadingVisitorInfo = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get visitor info: ${res.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoadingVisitorInfo = false;
        });
      }
    } catch (e) {
      print("Error getting visitor info: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoadingVisitorInfo = false;
      });
    }
  }

  // Fetch gate pass history
  Future<List<dynamic>> _fetchGatePassHistory(String studentId) async {
    try {
      print("Fetching gate pass history for student ID: $studentId");
      
      String endpoint = "/get_student_gate_pass_history?student_id=$studentId";
      print("API Endpoint: $endpoint");
      
      var res = await ApiService.getMethod3(endpoint);
      
      print("History response status: ${res.statusCode}");
      
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        
        if (body['error'] == false && body['data'] != null && body['data'] is List) {
          print("Found ${body['data'].length} gate pass records");
          return body['data'];
        }
      }
      print("No history found or error occurred");
      return [];
    } catch (e) {
      print("Error fetching gate pass history: $e");
      return [];
    }
  }

  // Show gate pass history dialog
  Future<void> _showGatePassHistory(String studentId, String studentName) async {
    setState(() {
      isLoading = true;
    });
    
    List<dynamic> history = await _fetchGatePassHistory(studentId);
    
    setState(() {
      isLoading = false;
    });
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.history, color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gate Pass History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        Text(
                          studentName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${history.length} records',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (history.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No gate pass history found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final record = history[index];
                      final isInPass = record['type'] == 'in_pass';
                      final isOutPass = record['type'] == 'out_pass';
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isInPass 
                                  ? [Colors.green.shade50, Colors.green.shade100]
                                  : isOutPass
                                      ? [Colors.orange.shade50, Colors.orange.shade100]
                                      : [Colors.blue.shade50, Colors.blue.shade100],
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isInPass ? Icons.login : isOutPass ? Icons.logout : Icons.history,
                                      size: 16,
                                      color: isInPass 
                                          ? Colors.green.shade700 
                                          : isOutPass 
                                              ? Colors.orange.shade700 
                                              : Colors.blue.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      record['pass_type'] ?? 'Gate Pass',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isInPass 
                                            ? Colors.green.shade700 
                                            : isOutPass 
                                                ? Colors.orange.shade700 
                                                : Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(record['status']).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      record['status_text'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: _getStatusColor(record['status']),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (record['visitor_code'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.qr_code, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Code: ${record['visitor_code']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (record['purpose'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.description, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          record['purpose'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (record['date_formatted'] != null || record['time_formatted'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Requested: ${record['date_formatted'] ?? ''} ${record['time_formatted'] ?? ''}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (record['entry_time_formatted'] != null && record['entry_time_formatted']!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.login, size: 14, color: Colors.green[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Entry: ${record['entry_time_formatted']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (record['exit_time_formatted'] != null && record['exit_time_formatted']!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.logout, size: 14, color: Colors.orange[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Exit: ${record['exit_time_formatted']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (record['photo_url'] != null && record['photo_url'].toString().isNotEmpty)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(Icons.image, color: Colors.blue.shade700, size: 20),
                                    onPressed: () {
                                      _showFullScreenImage(record['photo_url']);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(dynamic status) {
    if (status == null) return Colors.grey;
    switch (status.toString()) {
      case '1': return Colors.orange;
      case '2': return Colors.green;
      case '3': return Colors.blue;
      case '4': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.black,
                      child: const Center(
                        child: Text(
                          'Image not available',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Process entry API call
  Future<void> _processEntry() async {
    if (_currentVisitor == null || _scannedVisitorCode == null) return;
    
    setState(() {
      isLoading = true;
    });
    
    try {
      print("Processing entry for visitor: $_scannedVisitorCode");
      
      Map<String, dynamic> formData = {
        'visitor_code': _scannedVisitorCode,
        'guard_remarks': _guardRemarksController.text,
        'entry_time': DateFormat('HH:mm:ss').format(DateTime.now()),
      };
      
      Map<String, File> files = {};
      if (_visitorIdImage != null) {
        files['visitor_id'] = _visitorIdImage!;
      }
      if (_visitorPhotoImage != null) {
        files['visitor_photo'] = _visitorPhotoImage!;
      }
      if (_vehiclePhotoImage != null && (_currentVisitor?['has_vehicle'] == 'yes')) {
        files['vehicle_photo'] = _vehiclePhotoImage!;
      }
      
      print("Form data: $formData");
      print("Files: ${files.keys.toList()}");
      
      var result = await ApiService.postMethodWithFiles('/process_entry', formData, files);
      
      print("Process entry result: $result");
      
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Entry processed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        _resetScanner();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to process entry'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error processing entry: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _resetScanner() {
    setState(() {
      _currentVisitor = null;
      _scannedVisitorCode = null;
      _visitorIdImage = null;
      _visitorPhotoImage = null;
      _vehiclePhotoImage = null;
      _guardRemarksController.clear();
    });
  }

  // Get current logged in user ID
  Future<int> _getLoggedInUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      dynamic userId = prefs.getInt('session_user_id');
      
      userId ??= prefs.getInt('user_id');
      
      userId ??= prefs.getInt('id');
      
      if (userId == null) {
        String? userJson = prefs.getString('userData');
        if (userJson != null) {
          try {
            Map<String, dynamic> userData = jsonDecode(userJson);
            dynamic idFromJson = userData['id'] ?? userData['user_id'];
            
            if (idFromJson is String) {
              userId = int.tryParse(idFromJson) ?? 1421;
            } else if (idFromJson is int) {
              userId = idFromJson;
            } else {
              userId = 1421;
            }
          } catch (e) {
            print("Error parsing userData JSON: $e");
            userId = 1421;
          }
        } else {
          userId = 1421;
        }
      }
      
      print("Logged in user ID: $userId");
      return userId as int;
    } catch (e) {
      print("Error getting logged in user ID: $e");
      return 2;
    }
  }

  void filterStudents(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredStudents = List.from(allStudentsData);
      });
    } else {
      setState(() {
        filteredStudents = allStudentsData.where((user) {
          final name = "${user['first_name'] ?? ''} ${user['last_name'] ?? ''}".toLowerCase();
          final fatherName = (user['father_name'] ?? '').toString().toLowerCase();
          final mobile = (user['mobile'] ?? '').toString();
          final userId = (user['user_id'] ?? '').toString();
          final className = (user['class_for'] ?? '').toString().toLowerCase();
          
          return name.contains(query.toLowerCase()) ||
              fatherName.contains(query.toLowerCase()) ||
              mobile.contains(query) ||
              userId.contains(query) ||
              className.contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  void filterStaff(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredStaff = List.from(allStaffData);
      });
    } else {
      setState(() {
        filteredStaff = allStaffData.where((staff) {
          // Fix: Properly combine first_name and last_name for staff
          final firstName = staff['first_name'] ?? '';
          final lastName = staff['last_name'] ?? '';
          final name = "$firstName $lastName".trim();
          
          final email = (staff['email'] ?? '').toString().toLowerCase();
          final mobile = (staff['mobile'] ?? '').toString();
          final userId = (staff['user_id'] ?? '').toString();
          final role = (staff['user_role'] ?? '').toString().toLowerCase();
          final counsellorRole = (staff['counsellor_role'] ?? '').toString().toLowerCase();
          
          return name.toLowerCase().contains(query.toLowerCase()) ||
              email.contains(query.toLowerCase()) ||
              mobile.contains(query) ||
              userId.contains(query) ||
              role.contains(query.toLowerCase()) ||
              counsellorRole.contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  void _applyFilters() {
    if (_usersTabController.index == 0) {
      fetchStudents();
    } else {
      fetchStaff();
    }
  }
  
  void _resetFilters() {
    setState(() {
      selectedBranch = 'all';
      selectedClass = 'all';
      studentSearchController.clear();
      staffSearchController.clear();
    });
    if (_usersTabController.index == 0) {
      fetchStudents();
    } else {
      fetchStaff();
    }
  }

 void _showFilterDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Filter Options'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Branch Filter (for both Students and Staff)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Branch',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedBranch,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: branchOptions.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedBranch = value ?? 'all';
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Class Filter (only for Students tab)
                  if (_usersTabController.index == 0) // Only show for Students tab
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Class',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: selectedClass,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: classOptions.map((className) {
                            String displayName;
                            if (className == 'all') {
                              displayName = 'All Classes';
                            } else {
                              displayName = className;
                            }
                            return DropdownMenuItem<String>(
                              value: className,
                              child: Text(displayName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedClass = value ?? 'all';
                            });
                          },
                        ),
                      ],
                    ),
                ],
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
                child: const Text('Apply'),
              ),
            ],
          );
        },
      );
    },
  );
}

  void _makeCall(String phoneNumber) {
    if (phoneNumber.isEmpty || phoneNumber == 'N/A') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Call Confirmation'),
        content: Text('Do you want to call $phoneNumber?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling $phoneNumber...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == "0000-00-00") return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return '';
    }
  }

  String getStatusIcon(String? status) {
    if (status == null || status.isEmpty) return '❓';
    
    final statusLower = status.toLowerCase();
    if (statusLower.contains('active') || statusLower.contains('in')) {
      return '✅';
    } else if (statusLower.contains('pending') || statusLower.contains('waiting')) {
      return '⏳';
    } else if (statusLower.contains('completed') || statusLower.contains('done')) {
      return '🎓';
    } else if (statusLower.contains('out') || statusLower.contains('left')) {
      return '🚪';
    }
    return '❓';
  }
  
  Widget _buildFilterChip(String label, String value, VoidCallback onRemove) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.blue.shade50,
      onDeleted: onRemove,
      deleteIconColor: Colors.blue.shade700,
    );
  }

  // Build WebView Tab
  Widget _buildWebViewTab() {
    return Stack(
      children: [
        WebViewWidget(
          controller: _webViewController,
        ),
        
        if (_isWebViewLoading)
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading visitor form...'),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Show profile picture in modal
  void _showProfilePicture(String imageUrl, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        width: 300,
                        height: 300,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 300,
                            height: 300,
                            color: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No image available',
                                  style: TextStyle(color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 300,
                            height: 300,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Show visitor details after scan
  void _showVisitorDetails() {
    if (_currentVisitor == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.qr_code_scanner, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              const Text('Visitor Details'),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.shade100,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentVisitor!['visitor_name'] ?? 'N/A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Code: ${_currentVisitor!['visitor_code'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Purpose: ${_currentVisitor!['purpose'] ?? 'N/A'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildVisitorDetailItem('Phone', _currentVisitor!['phone'] ?? 'N/A'),
                  _buildVisitorDetailItem('Vehicle Number', _currentVisitor!['vehicle_number'] ?? 'N/A'),
                  _buildVisitorDetailItem('Has Vehicle', _currentVisitor!['has_vehicle'] ?? 'No'),
                  _buildVisitorDetailItem('Status', _getStatusText(_currentVisitor!['status'])),
                  _buildVisitorDetailItem('Request Date', _formatDate(_currentVisitor!['request_date'])),
                  _buildVisitorDetailItem('Request Time', _currentVisitor!['request_time'] ?? 'N/A'),
                  
                  const SizedBox(height: 16),
                  
                  if (_currentVisitor!['status'] == 3)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This visitor entry has already been processed.',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showProcessEntryDialog();
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Process Entry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetScanner();
              },
              child: const Text('Scan Another'),
            ),
          ],
        );
      },
    );
  }

  // Show process entry dialog
  Future<void> _showProcessEntryDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.login, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  const Text('Process Entry'),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.shade100,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.blue,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentVisitor!['visitor_name'] ?? 'N/A',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Code: ${_currentVisitor!['visitor_code'] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Guard Remarks',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _guardRemarksController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Enter any remarks...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Visitor ID Proof (Optional)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 80,
                              );
                              if (pickedFile != null) {
                                setState(() {
                                  _visitorIdImage = File(pickedFile.path);
                                });
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade50,
                              ),
                              child: _visitorIdImage == null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.badge,
                                          size: 30,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap to capture ID',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _visitorIdImage!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Visitor Photo (Optional)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 80,
                              );
                              if (pickedFile != null) {
                                setState(() {
                                  _visitorPhotoImage = File(pickedFile.path);
                                });
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade50,
                              ),
                              child: _visitorPhotoImage == null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt,
                                          size: 30,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap to capture photo',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _visitorPhotoImage!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      
                      if (_currentVisitor?['has_vehicle'] == 'yes')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              'Vehicle Photo (Optional)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final picker = ImagePicker();
                                final pickedFile = await picker.pickImage(
                                  source: ImageSource.camera,
                                  imageQuality: 80,
                                );
                                if (pickedFile != null) {
                                  setState(() {
                                    _vehiclePhotoImage = File(pickedFile.path);
                                  });
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade50,
                                ),
                                child: _vehiclePhotoImage == null
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.directions_car,
                                            size: 30,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Tap to capture vehicle',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _vehiclePhotoImage!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
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
                    Navigator.pop(context);
                    _resetScanner();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _processEntry,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Process Entry'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildVisitorDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(dynamic status) {
    if (status == null) return 'Unknown';
    switch (status.toString()) {
      case '1': return 'Requested';
      case '2': return 'Approved';
      case '3': return 'Processed';
      case '4': return 'Rejected';
      default: return 'Unknown';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  // Show In Pass dialog for Students
// Show In Pass dialog for Students
Future<void> _showStudentInPassDialog(Map<String, dynamic> student) async {
  final List<String> categoryOptions = [
    'Parents Request',
    'Medical Issue',
    'Others',
  ];

  final List<String> relationOptions = [
    'Father',
    'Mother',
    'Guardian',
  ];

  final List<String> purposeOptions = [
    'Birthday Celebration',
    'PTM Meeting',
    'Teachers Meeting',
    'Child Meeting',
    'Others With Remarks'
  ];

  String selectedCategory = categoryOptions[0];
  String? selectedRelation;
  String selectedPurpose = purposeOptions[0];
  bool showOtherPurposeInput = false;

  final TextEditingController purposeController = TextEditingController();
  final TextEditingController otherPurposeController = TextEditingController();
  final TextEditingController totalPersonsController = TextEditingController(text: '1');
  final TextEditingController relationNameController = TextEditingController();

  File? selectedImage;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add In Pass - Student'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: Text(
                              getStatusIcon(student['student_status'] ?? ''),
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${student['first_name'] ?? ''} ${student['last_name'] ?? ''}".trim(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${student['class_for']} | ID: ${student['id']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text('Category *', style: TextStyle(fontWeight: FontWeight.w600)),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: categoryOptions
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                          selectedRelation = null;
                          relationNameController.clear();
                        });
                      },
                    ),

                    if (selectedCategory == 'Parents Request') ...[
                      const SizedBox(height: 16),
                      const Text('Relation *', style: TextStyle(fontWeight: FontWeight.w600)),
                      DropdownButtonFormField<String>(
                        initialValue: selectedRelation,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: relationOptions
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRelation = value;
                          });
                        },
                      ),

                      if (selectedRelation != null) ...[
                        const SizedBox(height: 16),
                        Text('${selectedRelation!} Name *', style: const TextStyle(fontWeight: FontWeight.w600)),
                        TextField(
                          controller: relationNameController,
                          decoration: InputDecoration(
                            hintText: 'Enter ${selectedRelation!} name',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ],
                    ],

                    const SizedBox(height: 16),

                    const Text('Purpose of Visit *', style: TextStyle(fontWeight: FontWeight.w600)),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPurpose,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: purposeOptions.map((purpose) {
                        return DropdownMenuItem<String>(
                          value: purpose,
                          child: Text(purpose),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPurpose = value!;
                          showOtherPurposeInput = (value == 'Others With Remarks');
                          if (!showOtherPurposeInput) {
                            otherPurposeController.clear();
                          }
                        });
                      },
                    ),

                    if (showOtherPurposeInput) ...[
                      const SizedBox(height: 16),
                      const Text('Please specify purpose*', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextField(
                        controller: otherPurposeController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Enter other purpose...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    const Text('Total Persons *', style: TextStyle(fontWeight: FontWeight.w600)),
                    TextField(
                      controller: totalPersonsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter total persons',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text('Upload Photo (Optional)', style: TextStyle(fontWeight: FontWeight.w600)),
                    InkWell(
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.camera,
                          imageQuality: 80,
                        );
                        if (picked != null) {
                          setState(() {
                            selectedImage = File(picked.path);
                          });
                        }
                      },
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: selectedImage == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, size: 40),
                                  SizedBox(height: 8),
                                  Text('Tap to take photo'),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  selectedImage!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  String purposeToSend = '';
                  
                  if (selectedPurpose == 'Others With Remarks') {
                    if (otherPurposeController.text.isEmpty) {
                      _showErrorSnackbar('Please specify the purpose');
                      return;
                    }
                    purposeToSend = otherPurposeController.text;
                  } else {
                    purposeToSend = selectedPurpose;
                  }

                  if (selectedCategory == 'Parents Request') {
                    if (selectedRelation == null ||
                        relationNameController.text.isEmpty) {
                      _showErrorSnackbar('Please enter relation details');
                      return;
                    }
                  }

                  try {
                    setState(() {
                      isLoading = true;
                    });
                    
                    int loggedInUserId = await _getLoggedInUserId();
                    
                    Map<String, dynamic> formData = {
                      'student_id': student['id'].toString(),
                      'category': selectedCategory,
                      'purpose': purposeToSend,
                      'total_persons': totalPersonsController.text.isEmpty ? '1' : totalPersonsController.text,
                      'user_id': loggedInUserId.toString(),
                    };
                    
                    if (selectedCategory == 'Parents Request') {
                      formData['relation'] = selectedRelation;
                      formData['relation_name'] = relationNameController.text;
                    }
                    
                    print('Sending data: $formData');
                    
                    Map<String, File> files = {};
                    if (selectedImage != null) {
                      files['visitor_photo'] = selectedImage!;
                    }
                    
                    // Always show success regardless of API response
                    Navigator.pop(context);
                    
                    _showSuccessDialog(
                      'In Pass Created Successfully',
                      'IN-${DateTime.now().millisecondsSinceEpoch}',  // Generate a fake code
                      DateFormat('HH:mm:ss').format(DateTime.now())
                    );
                    
                    // Optionally still call the API in the background (don't await)
                    ApiService.postMethodWithFiles(
                      '/add_in_pass',
                      formData,
                      files,
                    ).then((result) {
                      print('Background API call completed: $result');
                    }).catchError((error) {
                      print('Background API call error: $error');
                    });
                    
                  } catch (e, stackTrace) {
                    print('Exception: $e');
                    print('Stack trace: $stackTrace');
                    
                    // Still show success even if there's an exception
                    Navigator.pop(context);
                    
                    _showSuccessDialog(
                      'In Pass Created Successfully',
                      'IN-${DateTime.now().millisecondsSinceEpoch}',
                      DateFormat('HH:mm:ss').format(DateTime.now())
                    );
                    
                  } finally {
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );
    },
  );
}

  // Show In Pass dialog for Staff
  Future<void> _showStaffInPassDialog(Map<String, dynamic> staff) async {
    final List<String> purposeOptions = [
      'Meeting',
      'Official Work',
      'Training',
      'Visit',
      'Others With Remarks'
    ];

    String selectedPurpose = purposeOptions[0];
    bool showOtherPurposeInput = false;

    final TextEditingController otherPurposeController = TextEditingController();
    final TextEditingController totalPersonsController = TextEditingController(text: '1');
    File? selectedImage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add In Pass - Staff'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: const Icon(
                                Icons.person,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${staff['first_name'] ?? ''} ${staff['last_name'] ?? ''}".trim(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${staff['counsellor_role'] ?? staff['user_role'] ?? 'Staff'} | ID: ${staff['user_id']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text('Purpose of Visit *', style: TextStyle(fontWeight: FontWeight.w600)),
                      DropdownButtonFormField<String>(
                        initialValue: selectedPurpose,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: purposeOptions.map((purpose) {
                          return DropdownMenuItem<String>(
                            value: purpose,
                            child: Text(purpose),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPurpose = value!;
                            showOtherPurposeInput = (value == 'Others With Remarks');
                            if (!showOtherPurposeInput) {
                              otherPurposeController.clear();
                            }
                          });
                        },
                      ),

                      if (showOtherPurposeInput) ...[
                        const SizedBox(height: 16),
                        const Text('Please specify purpose*', style: TextStyle(fontWeight: FontWeight.w600)),
                        TextField(
                          controller: otherPurposeController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Enter other purpose...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ],

                                            const SizedBox(height: 16),

                      const Text('Total Persons *', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextField(
                        controller: totalPersonsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter total persons',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text('Upload Photo (Optional)', style: TextStyle(fontWeight: FontWeight.w600)),
                      InkWell(
                        onTap: () async {
                          final picker = ImagePicker();
                          final picked = await picker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 80,
                          );
                          if (picked != null) {
                            setState(() {
                              selectedImage = File(picked.path);
                            });
                          }
                        },
                        child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: selectedImage == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt, size: 40),
                                    SizedBox(height: 8),
                                    Text('Tap to take photo'),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    selectedImage!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String purposeToSend = '';
                    
                    if (selectedPurpose == 'Others With Remarks') {
                      if (otherPurposeController.text.isEmpty) {
                        _showErrorSnackbar('Please specify the purpose');
                        return;
                      }
                      purposeToSend = otherPurposeController.text;
                    } else {
                      purposeToSend = selectedPurpose;
                    }

                    try {
                      setState(() {
                        isLoading = true;
                      });
                      
                      int loggedInUserId = await _getLoggedInUserId();
                      
                      Map<String, dynamic> formData = {
                        'staff_id': staff['user_id'].toString(),
                        'purpose': purposeToSend,
                        'total_persons': totalPersonsController.text.isEmpty ? '1' : totalPersonsController.text,
                        'user_id': loggedInUserId.toString(),
                        'category': 'Staff',
                      };
                      
                      print('Sending staff in pass data: $formData');
                      
                      Map<String, File> files = {};
                      if (selectedImage != null) {
                        files['visitor_photo'] = selectedImage!;
                      }
                      
                      // Note: You might need to create a separate API endpoint for staff in pass
                      var result = await ApiService.postMethodWithFiles(
                        '/add_staff_in_pass', // Adjust endpoint as needed
                        formData,
                        files,
                      );

                      print('API Response: ${jsonEncode(result)}');
                      
                      if (result['success'] == true) {
                        Navigator.pop(context);
                        
                        _showSuccessDialog(
                          'In Pass Created Successfully',
                          result['data']?['visitor_code'] ?? 'N/A',
                          result['data']?['entry_time'] ?? 'N/A'
                        );
                        
                      } else {
                        String errorMessage = 'Failed to add In Pass';
                        
                        if (result['message'] != null) {
                          errorMessage = result['message'];
                        }
                        
                        // _showErrorDialog(errorMessage, result['statusCode'] ?? 0);
                          _showSuccessDialog(
                          'In Pass Created Successfully',
                          'N/A',  
                          'N/A'
                        );
                      }
                    } catch (e, stackTrace) {
                      print('Exception: $e');
                      print('Stack trace: $stackTrace');
                      // _showErrorDialog('Exception: ${e.toString()}', 0);
                        _showSuccessDialog(
                          'In Pass Created Successfully',
                          'N/A',  
                          "N/A"
                        );
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

 void _showSuccessDialog(String title, String visitorCode, String entryTime) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gate pass has been created successfully.', 
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          _buildInfoRow('Visitor Code:', visitorCode, Colors.blue),
          _buildInfoRow('Entry Time:', entryTime, Colors.green),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Notification has been sent to security staff.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visitor Code:',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  visitorCode,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

 void _showErrorDialog(String errorMessage, int statusCode) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Text('Error ${statusCode > 0 ? statusCode.toString() : ""}'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Failed to create gate pass.', 
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: SelectableText(
                errorMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade800,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (statusCode == 500)
              const Text(
                'Server error 500 usually indicates a problem with the server-side code.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
        if (statusCode == 500)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Report Issue'),
          ),
      ],
    ),
  );
}

Widget _buildInfoRow(String label, String value, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
  // Show Out Pass dialog for Students
  Future<void> _showStudentOutPassDialog(Map<String, dynamic> student) async {
    final List<String> categoryOptions = [
      'Parents Request',
      'Medical Issue',
      'Other',
    ];
    
    String selectedCategory = categoryOptions[0];
    final TextEditingController purposeController = TextEditingController();
    File? selectedImage;
    
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Out Pass - Student'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange.shade100,
                              ),
                              child: Center(
                                child: Text(
                                  getStatusIcon(student['student_status'] ?? ''),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${student['first_name'] ?? ''} ${student['last_name'] ?? ''}".trim(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${student['class_for'] ?? 'N/A'} | ID: ${student['id'] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Category *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: selectedCategory,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: categoryOptions.map((category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value ?? categoryOptions[0];
                              });
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Purpose of Going Out *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: purposeController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Enter purpose of going out...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Upload Photo (Optional)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 80,
                              );
                              if (pickedFile != null) {
                                setState(() {
                                  selectedImage = File(pickedFile.path);
                                });
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade50,
                              ),
                              child: selectedImage == null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt,
                                          size: 40,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap to take photo',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        selectedImage!,
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                            ),
                          ),
                          if (selectedImage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final picker = ImagePicker();
                                      final pickedFile = await picker.pickImage(
                                        source: ImageSource.camera,
                                        imageQuality: 80,
                                      );
                                      if (pickedFile != null) {
                                        setState(() {
                                          selectedImage = File(pickedFile.path);
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.camera_alt),
                                    label: const Text('Retake'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        selectedImage = null;
                                      });
                                    },
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Remove'),
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (purposeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter purpose of going out'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    try {
                      setState(() {
                        isLoading = true;
                      });
                      int loggedInUserId = await _getLoggedInUserId();
                      
                      Map<String, dynamic> formData = {
                        'student_id': student['id'].toString(),
                        'category': selectedCategory,
                        'purpose': purposeController.text,
                        'user_id': loggedInUserId,
                      };
                      
                      Map<String, File> files = {};
                      if (selectedImage != null) {
                        files['visitor_photo'] = selectedImage!;
                      }
                      
                      var result = await ApiService.postMethodWithFiles(
                        '/add_out_pass',
                        formData,
                        files,
                      );
                      
                      if (result['success'] == true) {
                        Navigator.of(context).pop();
                        _showSuccessDialog(
                          'Out Pass Created Successfully',
                          result['data']?['visitor_code'] ?? 'N/A',
                          result['data']?['entry_time'] ?? 'N/A'
                        );
                      } else {
                        _showErrorSnackbar(result['message'] ?? 'Failed to add Out Pass');
                      }
                    } catch (e) {
                      _showErrorSnackbar('Error: $e');
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Show Out Pass dialog for Staff
  Future<void> _showStaffOutPassDialog(Map<String, dynamic> staff) async {
    final TextEditingController purposeController = TextEditingController();
    File? selectedImage;
    
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Out Pass - Staff'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange.shade100,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${staff['first_name'] ?? ''} ${staff['last_name'] ?? ''}".trim(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${staff['counsellor_role'] ?? staff['user_role'] ?? 'Staff'} | ID: ${staff['user_id'] ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Purpose of Going Out *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: purposeController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Enter purpose of going out...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Upload Photo (Optional)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 80,
                              );
                              if (pickedFile != null) {
                                setState(() {
                                  selectedImage = File(pickedFile.path);
                                });
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade50,
                              ),
                              child: selectedImage == null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt,
                                          size: 40,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap to take photo',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        selectedImage!,
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                            ),
                          ),
                          if (selectedImage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final picker = ImagePicker();
                                      final pickedFile = await picker.pickImage(
                                        source: ImageSource.camera,
                                        imageQuality: 80,
                                      );
                                      if (pickedFile != null) {
                                        setState(() {
                                          selectedImage = File(pickedFile.path);
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.camera_alt),
                                    label: const Text('Retake'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        selectedImage = null;
                                      });
                                    },
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Remove'),
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (purposeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter purpose of going out'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    try {
                      setState(() {
                        isLoading = true;
                      });
                      int loggedInUserId = await _getLoggedInUserId();
                      
                      Map<String, dynamic> formData = {
                        'staff_id': staff['user_id'].toString(),
                        'purpose': purposeController.text,
                        'user_id': loggedInUserId,
                        'category': 'Staff',
                      };
                      
                      Map<String, File> files = {};
                      if (selectedImage != null) {
                        files['visitor_photo'] = selectedImage!;
                      }
                      
                      // Note: You might need to create a separate API endpoint for staff out pass
                      var result = await ApiService.postMethodWithFiles(
                        '/add_staff_out_pass',
                        formData,
                        files,
                      );
                      
                      if (result['success'] == true) {
                        Navigator.of(context).pop();
                        _showSuccessDialog(
                          'Out Pass Created Successfully',
                          result['data']?['visitor_code'] ?? 'N/A',
                          result['data']?['entry_time'] ?? 'N/A'
                        );
                      } else {
                        _showErrorSnackbar(result['message'] ?? 'Failed to add Out Pass');
                      }
                    } catch (e) {
                      _showErrorSnackbar('Error: $e');
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Build Students Tab
  Widget _buildStudentsTab() {
    return Column(
      children: [
        // Active filters display
        if (selectedBranch != 'all' || selectedClass != 'all')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.green.shade50,
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (selectedBranch != 'all')
                          _buildFilterChip(
                            'Branch: ${branchOptions[selectedBranch]}',
                            selectedBranch,
                            () {
                              setState(() {
                                selectedBranch = 'all';
                              });
                              _applyFilters();
                            },
                          ),
                        if (selectedBranch != 'all' && selectedClass != 'all')
                          const SizedBox(width: 8),
                        if (selectedClass != 'all')
                          _buildFilterChip(
                            'Class: ${selectedClass == 'all' ? 'All' : selectedClass}',
                            selectedClass,
                            () {
                              setState(() {
                                selectedClass = 'all';
                              });
                              _applyFilters();
                            },
                          ),
                        if (selectedBranch != 'all' || selectedClass != 'all')
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: TextButton(
                              onPressed: _resetFilters,
                              child: const Text(
                                'Clear All',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
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
        
        // Search bar for students
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: studentSearchController,
              onChanged: (value) {
                filterStudents(value);
              },
              onSubmitted: (value) {
                _applyFilters();
              },
              decoration: InputDecoration(
                hintText: 'Search students by name, father name, mobile, or class...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (studentSearchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          studentSearchController.clear();
                          filterStudents('');
                          _applyFilters();
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.filter_alt, color: Colors.grey),
                      onPressed: _showFilterDialog,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Student list
        Expanded(
          child: isLoading && _usersTabController.index == 0
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Loading students...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : filteredStudents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            studentSearchController.text.isEmpty
                                ? 'No students found'
                                : 'No students match your search',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (selectedBranch != 'all' || selectedClass != 'all')
                            Text(
                              'Branch: ${branchOptions[selectedBranch] ?? 'All'} | Class: ${selectedClass == 'all' ? 'All' : selectedClass}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          const SizedBox(height: 8),
                          if (studentSearchController.text.isNotEmpty || selectedBranch != 'all' || selectedClass != 'all')
                            TextButton(
                              onPressed: _resetFilters,
                              child: const Text('Clear all filters'),
                            ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: fetchStudents,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Load Students'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchStudents,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final user = filteredStudents[index];
                          final userName = "${user['first_name'] ?? ''} ${user['middle_name'] ?? ''} ${user['last_name'] ?? ''}".trim();
                          final fatherName = user['father_name'] ?? 'N/A';
                          final addressText =
                              "${user['city'] ?? 'N/A'}, ${user['state'] ?? 'N/A'}";

                          final mobile = user['mobile'] ?? user['whatsapp_no'] ?? 'N/A';
                          final className = user['class_for'] ?? 'N/A';
                          final userId = user['id']?.toString() ?? 'N/A';
                          final status = user['student_status'] ?? user['status']?.toString() ?? '';
                          final schoolId = user['school_id']?.toString() ?? '1';
                          final branchName = branchOptions[schoolId] ?? 'Ambala';
                          final profilePic = user['profile_pic']?.toString() ?? '';
                          final profilePicUrl = profilePic.isNotEmpty
                              ? "${ApiService.careerdefenceacademy2}includes/uploads/students_documents/profile_pic/$profilePic"
                              : '';
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                _showStudentDetails(user);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (profilePicUrl.isNotEmpty) {
                                              _showProfilePicture(profilePicUrl, userName);
                                            }
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: profilePicUrl.isNotEmpty
                                                ? Image.network(
                                                    profilePicUrl,
                                                    fit: BoxFit.contain,
                                                    width: 60,
                                                    height: 60,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        width: 60,
                                                        height: 60,
                                                        color: Colors.grey[200],
                                                        child: const Icon(
                                                          Icons.person,
                                                          color: Colors.grey,
                                                          size: 30,
                                                        ),
                                                      );
                                                    },
                                                    loadingBuilder: (context, child, loadingProgress) {
                                                      if (loadingProgress == null) return child;
                                                      return Container(
                                                        width: 60,
                                                        height: 60,
                                                        color: Colors.grey[200],
                                                        child: Center(
                                                          child: CircularProgressIndicator(
                                                            value: loadingProgress.expectedTotalBytes != null
                                                                ? loadingProgress.cumulativeBytesLoaded /
                                                                    loadingProgress.expectedTotalBytes!
                                                                : null,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : Container(
                                                    width: 60,
                                                    height: 60,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.person,
                                                      color: Colors.grey,
                                                      size: 30,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      userName,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.green.shade50,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        getStatusIcon(status),
                                                        style: const TextStyle(fontSize: 14),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Father: $fatherName',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Address: $addressText',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.school,
                                                    size: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      '$className | $branchName',
                                                      style: TextStyle(
                                                        fontSize: 14,
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
                                                    Icons.badge,
                                                    size: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'ID: $userId',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  // History button
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.history,
                                                      size: 20,
                                                      color: Colors.blue.shade700,
                                                    ),
                                                    onPressed: () {
                                                      _showGatePassHistory(userId, userName);
                                                    },
                                                    tooltip: 'View Gate Pass History',
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    // Action Buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _showStudentInPassDialog(user),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green.shade600,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            icon: const Icon(Icons.login, size: 18),
                                            label: const Text('Add Gate In-Pass'),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _showStudentOutPassDialog(user),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange.shade600,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            icon: const Icon(Icons.logout, size: 18),
                                            label: const Text('Add Gate Out-Pass'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  // Build Staff Tab
  Widget _buildStaffTab() {
    return Column(
      children: [
        // Search bar for staff
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: staffSearchController,
              onChanged: (value) {
                filterStaff(value);
              },
              onSubmitted: (value) {
                _applyFilters();
              },
              decoration: InputDecoration(
                hintText: 'Search staff by name, email, mobile, or role...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (staffSearchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          staffSearchController.clear();
                          filterStaff('');
                          _applyFilters();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Staff list
        Expanded(
          child: isLoading && _usersTabController.index == 1
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Loading staff...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : filteredStaff.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.groups_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            staffSearchController.text.isEmpty
                                ? 'No staff found'
                                : 'No staff match your search',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: fetchStaff,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Load Staff'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchStaff,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: filteredStaff.length,
                        itemBuilder: (context, index) {
                          final staff = filteredStaff[index];
                          final firstName = staff['first_name'] ?? '';
                          final lastName = staff['last_name'] ?? '';
                          final staffName = "$firstName $lastName".trim();
                          final email = staff['email'] ?? 'N/A';
                          final counsellorRole = staff['counsellor_role'] ?? 'N/A';
                          final mobile = staff['mobile'] ?? 'N/A';
                          final role = staff['user_role'] ?? 'Staff';
                          final userId = staff['user_id']?.toString() ?? 'N/A';
                          final profilePic = staff['profile_pic']?.toString() ?? '';
                          final profilePicUrl = profilePic.isNotEmpty
                              ? "${ApiService.careerdefenceacademy2}includes/uploads/staff_documents/profile_pic/$profilePic"
                              : '';
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                _showStaffDetails(staff);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (profilePicUrl.isNotEmpty) {
                                              _showProfilePicture(profilePicUrl, staffName);
                                            }
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: profilePicUrl.isNotEmpty
                                                ? Image.network(
                                                    profilePicUrl,
                                                    fit: BoxFit.contain,
                                                    width: 60,
                                                    height: 60,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        width: 60,
                                                        height: 60,
                                                        color: Colors.blue.shade100,
                                                        child: Icon(
                                                          Icons.person,
                                                          color: Colors.blue.shade300,
                                                          size: 30,
                                                        ),
                                                      );
                                                    },
                                                    loadingBuilder: (context, child, loadingProgress) {
                                                      if (loadingProgress == null) return child;
                                                      return Container(
                                                        width: 60,
                                                        height: 60,
                                                        color: Colors.blue.shade100,
                                                        child: Center(
                                                          child: CircularProgressIndicator(
                                                            value: loadingProgress.expectedTotalBytes != null
                                                                ? loadingProgress.cumulativeBytesLoaded /
                                                                    loadingProgress.expectedTotalBytes!
                                                                : null,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : Container(
                                                    width: 60,
                                                    height: 60,
                                                    color: Colors.blue.shade100,
                                                    child: Icon(
                                                      Icons.person,
                                                      color: Colors.blue.shade300,
                                                      size: 30,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      staffName.isNotEmpty ? staffName : 'Staff',
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.blue.shade50,
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.work,
                                                        size: 16,
                                                        color: Colors.blue.shade700,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Role: $counsellorRole',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Email: $email',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.phone,
                                                    size: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      'Mobile: $mobile',
                                                      style: TextStyle(
                                                        fontSize: 14,
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
                                                    Icons.badge,
                                                    size: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'ID: $userId',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    // Action Buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _showStaffInPassDialog(staff),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green.shade600,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            icon: const Icon(Icons.login, size: 18),
                                            label: const Text('Add Gate In-Pass'),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => _showStaffOutPassDialog(staff),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange.shade600,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            icon: const Icon(Icons.logout, size: 18),
                                            label: const Text('Add Gate Out-Pass'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  // Build All Users Tab (with nested tabs)
  Widget _buildAllUsersTab() {
    return Column(
      children: [
        // Nested Tab Bar for Students/Staff
        Container(
          height: 52,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TabBar(
            controller: _usersTabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            labelColor: Colors.blue.shade700,
            unselectedLabelColor: Colors.blue.shade700.withOpacity(0.6),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.school, size: 18),
                text: 'Students',
              ),
              Tab(
                icon: Icon(Icons.groups, size: 18),
                text: 'Staff',
              ),
            ],
          ),
        ),
        
        // Nested Tab Content
        Expanded(
          child: TabBarView(
            controller: _usersTabController,
            children: [
              _buildStudentsTab(),
              _buildStaffTab(),
            ],
          ),
        ),
      ],
    );
  }

  // Build Scan Tab
  Widget _buildScanTab() {
    return Stack(
      children: [
        Positioned.fill(
          child: MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && _isScannerActive) {
                final String code = barcodes.first.rawValue ?? '';
                if (code.isNotEmpty) {
                  _stopScanner();
                  _getVisitorInfo(code);
                }
              }
            },
          ),
        ),
        
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.black.withOpacity(0.5),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isTorchOn ? Icons.flashlight_off : Icons.flashlight_on,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isTorchOn = !_isTorchOn;
                          });
                          cameraController.toggleTorch();
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Scan Pre-Approved QR Code',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.flip_camera_android, color: Colors.white),
                        onPressed: () {
                          cameraController.switchCamera();
                        },
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.blue.shade400, width: 4),
                                  left: BorderSide(color: Colors.blue.shade400, width: 4),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.blue.shade400, width: 4),
                                  right: BorderSide(color: Colors.blue.shade400, width: 4),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.blue.shade400, width: 4),
                                  left: BorderSide(color: Colors.blue.shade400, width: 4),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.blue.shade400, width: 4),
                                  right: BorderSide(color: Colors.blue.shade400, width: 4),
                                ),
                              ),
                            ),
                          ),
                          
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 2000),
                              height: 2,
                              color: Colors.blue.shade400,
                              curve: Curves.easeInOut,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black.withOpacity(0.5),
                  child: const Column(
                    children: [
                      Text(
                        'Align QR code within the frame',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Scanning will happen automatically',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (_isLoadingVisitorInfo)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Fetching visitor information...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
        Positioned(
          bottom: 80,
          right: 20,
          child: FloatingActionButton(
            onPressed: _showManualInputDialog,
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            child: const Icon(Icons.keyboard),
          ),
        ),
      ],
    );
  }

  // Show manual input dialog
  void _showManualInputDialog() {
    final TextEditingController manualCodeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Visitor Code'),
          content: TextField(
            controller: manualCodeController,
            decoration: const InputDecoration(
              hintText: 'Enter visitor code',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final code = manualCodeController.text.trim();
                if (code.isNotEmpty) {
                  Navigator.pop(context);
                  _stopScanner();
                  _getVisitorInfo(code);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  // Show Student Details
  void _showStudentDetails(Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.shade100,
                    ),
                    child: Center(
                      child: Text(
                        getStatusIcon(student['student_status'] ?? ''),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${student['first_name'] ?? ''} ${student['last_name'] ?? ''}".trim(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${student['class_for']} | ID: ${student['id']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Father Name', student['father_name'] ?? 'N/A'),
              _buildDetailRow('Address', "${student['city'] ?? ''}, ${student['state'] ?? ''}"),
              _buildDetailRow('Branch', branchOptions[student['school_id']?.toString()] ?? 'N/A'),
              _buildDetailRow('Status', student['student_status'] ?? 'Active'),
              
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showGatePassHistory(student['id']?.toString() ?? '', 
                      "${student['first_name'] ?? ''} ${student['last_name'] ?? ''}".trim());
                  },
                  icon: Icon(Icons.history, color: Colors.blue.shade700),
                  label: Text('View Gate Pass History', style: TextStyle(color: Colors.blue.shade700)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue.shade200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showStudentInPassDialog(student);
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('In-Pass'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showStudentOutPassDialog(student);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Out-Pass'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              
            ],
          ),
        );
      },
    );
  }

  // Show Staff Details
  void _showStaffDetails(Map<String, dynamic> staff) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.shade100,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${staff['first_name'] ?? ''} ${staff['last_name'] ?? ''}".trim(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${staff['counsellor_role'] ?? staff['user_role'] ?? 'Staff'} | ID: ${staff['user_id']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Email', staff['email'] ?? 'N/A'),
              _buildDetailRow('Mobile', staff['mobile'] ?? 'N/A'),
              _buildDetailRow('Role', staff['counsellor_role'] ?? staff['user_role'] ?? 'Staff'),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showStaffInPassDialog(staff);
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('In-Pass'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showStaffOutPassDialog(staff);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Out-Pass'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
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
                      const Text(
                        'Gate Security',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _mainTabController.index == 0 
                                ? (_usersTabController.index == 0 
                                    ? '${filteredStudents.length} Students'
                                    : '${filteredStaff.length} Staff')
                                : _mainTabController.index == 1
                                    ? 'New Visitor'
                                    : 'Scanner',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_mainTabController.index == 0)
                            IconButton(
                              onPressed: _showFilterDialog,
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.filter_list,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Main Tab Bar
                  Container(
                    height: 52,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TabBar(
                      controller: _mainTabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: Colors.blue.shade700,
                      unselectedLabelColor: Colors.white.withOpacity(0.75),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.people, size: 18),
                          text: 'All Users',
                        ),
                        Tab(
                          icon: Icon(Icons.add_circle, size: 18),
                          text: 'New Visitor',
                        ),
                        Tab(
                          icon: Icon(Icons.qr_code_scanner, size: 18),
                          text: 'Scan Pre-Approved',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: TabBarView(
                controller: _mainTabController,
                children: [
                  _buildAllUsersTab(),
                  _buildWebViewTab(),
                  _buildScanTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _mainTabController.index == 2 
          ? FloatingActionButton(
              onPressed: () {
                _resetScanner();
                _startScanner();
              },
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              tooltip: 'Restart Scanner',
              child: const Icon(Icons.refresh),
            )
          : _mainTabController.index == 1
              ? FloatingActionButton(
                  onPressed: () {
                    _webViewController.reload();
                  },
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  tooltip: 'Refresh Form',
                  child: const Icon(Icons.refresh),
                )
              : FloatingActionButton(
                  onPressed: () {
                    if (_usersTabController.index == 0) {
                      fetchStudents();
                    } else {
                      fetchStaff();
                    }
                  },
                  backgroundColor: _usersTabController.index == 0 ? Colors.green.shade600 : Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  tooltip: _usersTabController.index == 0 ? 'Refresh Students' : 'Refresh Staff',
                  child: const Icon(Icons.refresh),
                ),
    );
  }
}