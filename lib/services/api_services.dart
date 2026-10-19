import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // ADD THIS IMPORT
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // static final baseUrl = "http://www.tipr.com.au:41000";
  static const baseUrl = "https://careerinstitute.co/app/Api";
  static const websiteUrl = "https://careerinstitute.co/app/";
  static const websiteUrl2 = "https://careerinstitute.co/myapp/";

  static const weeklytest = "https://careerinstitute.co/weeklytest/Api";
  static const weeklytest2 = "https://careerinstitute.co/weeklytest/";

  static const careerdefenceacademy =
      "https://www.careerdefenceacademy.com/Api";
  static const careerdefenceacademy2 = "https://www.careerdefenceacademy.com/";

  static headerObjFunc() {
    return {
      "Content-Type": "application/json",
      'Accept': 'application/json',
    };
  }

  static getMethod(url) async {
    return Future(() async {
      try {
        var result = await http.get(
          Uri.parse(ApiService.baseUrl + url),
          headers: headerObjFunc(),
        );
//        var response = json.decode(result.body);
        return result;
      } catch (err) {
        print(err);
        return err;
      }
    });
  }

  static postMethod(url, body) async {
    return Future(() async {
      var result = await http.post(
        Uri.parse(ApiService.baseUrl + url),
        body: body,
        headers: headerObjFunc(),
      );

      var response = json.decode(result.body);

      return response;
    });
  }

  // Add to ApiService class
// Add to ApiService class
  static Future<Map<String, dynamic>> sendNotificationToUser(
      int userId, Map<String, dynamic> notificationData) async {
    try {
      // Construct the full URL dynamically
      String url =
          '/send_notification'; // This can be adjusted as needed for different endpoints

      var response = await http.post(
        Uri.parse(
            ApiService.careerdefenceacademy + url), // Using the dynamic URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'notification': notificationData,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Failed to send notification'};
      }
    } catch (e) {
      print('Error sending notification: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static getMethod2(url) async {
    return Future(() async {
      try {
        var result = await http.get(
          Uri.parse(ApiService.weeklytest + url),
          headers: headerObjFunc(),
        );
//        var response = json.decode(result.body);
        return result;
      } catch (err) {
        print(err);
        return err;
      }
    });
  }

  static postMethod2(url, body) async {
    return Future(() async {
      var result = await http.post(
        Uri.parse(ApiService.weeklytest + url),
        body: body,
        headers: headerObjFunc(),
      );

      var response = json.decode(result.body);

      return response;
    });
  }

  static getMethod3(url) async {
    return Future(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final headers = Map<String, String>.from(headerObjFunc());
        final cookie = prefs.getString('session_cookie');
        if (cookie != null && cookie.isNotEmpty) headers['cookie'] = cookie;
        var result = await http.get(
          Uri.parse(ApiService.careerdefenceacademy + url),
          headers: headers,
        );
        await _saveSessionCookie(prefs, result.headers['set-cookie']);
//        var response = json.decode(result.body);
        return result;
      } catch (err) {
        print(err);
        return err;
      }
    });
  }

  static postMethod3(url, body) async {
    return Future(() async {
      final prefs = await SharedPreferences.getInstance();
      final headers = Map<String, String>.from(headerObjFunc());
      final cookie = prefs.getString('session_cookie');
      if (cookie != null && cookie.isNotEmpty) headers['cookie'] = cookie;
      var result = await http.post(
        Uri.parse(ApiService.careerdefenceacademy + url),
        body: body,
        headers: headers,
      );
      await _saveSessionCookie(prefs, result.headers['set-cookie']);

      var response = json.decode(result.body); // 👈 returning MAP
      return response; // 👈 NOT result
    });
  }

  static Future<void> _saveSessionCookie(
      SharedPreferences prefs, String? header) async {
    if (header == null || header.isEmpty) return;
    final cookie = header.split(';').first.trim();
    if (cookie.isNotEmpty) await prefs.setString('session_cookie', cookie);
  }

  static Future<Map<String, dynamic>> postMethodWithFiles(
    String url,
    Map<String, dynamic> body,
    Map<String, File> files,
  ) async {
    try {
      var uri = Uri.parse(careerdefenceacademy + url);

      print('📤 Making POST request to: $uri');
      print('📦 Request body: $body');
      print('📎 Files to upload: ${files.keys.toList()}');

      var request = http.MultipartRequest('POST', uri);

      // ✅ Headers
      var headers = await headerObjFunc();
      request.headers.addAll(headers);
      print('🔤 Headers added: ${headers.keys}');

      // ✅ ADD SESSION COOKIE
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cookie = prefs.getString("session_cookie");
      if (cookie != null) {
        request.headers['cookie'] = cookie;
        print('🍪 Session cookie added');
      }

      // ✅ Add fields
      body.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      print('📝 Form fields: ${request.fields}');

      // ✅ Add files - WITHOUT compression for now
      for (var entry in files.entries) {
        var file = entry.value;
        var fieldName = entry.key;

        if (await file.exists()) {
          var fileSize = file.lengthSync();
          var filename =
              '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

          print(
              '📊 File info: $fieldName -> $filename (${(fileSize / 1024).toStringAsFixed(2)} KB)');

          var multipartFile = await http.MultipartFile.fromPath(
            fieldName,
            file.path,
            filename: filename,
          );
          request.files.add(multipartFile);
          print('📸 Added file: $fieldName');
        } else {
          print('⚠️ File does not exist: ${file.path}');
        }
      }

      // Send request with timeout
      print('🚀 Sending request...');
      var startTime = DateTime.now();

      // Use a shorter timeout for debugging
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 15), // Shorter timeout for debugging
        onTimeout: () {
          var elapsed = DateTime.now().difference(startTime);
          throw TimeoutException(
              'Request timeout after ${elapsed.inSeconds} seconds');
        },
      );

      var elapsed = DateTime.now().difference(startTime);
      print('⏱️ Request sent in ${elapsed.inMilliseconds}ms');

      var response = await http.Response.fromStream(streamedResponse).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Response timeout after 10 seconds');
        },
      );

      var totalTime = DateTime.now().difference(startTime);
      print('📥 Total response time: ${totalTime.inSeconds}s');
      print('📥 Response status: ${response.statusCode}');

      // Try to parse response body
      Map<String, dynamic>? responseBody;
      try {
        if (response.body.isNotEmpty) {
          responseBody = json.decode(response.body);
          print('✅ Response body parsed successfully');
          if (responseBody != null && responseBody.containsKey('success')) {
            print('   Success: ${responseBody['success']}');
          }
        } else {
          print('⚠️ Empty response body');
        }
      } catch (e) {
        print('❌ Failed to parse JSON: $e');
        print(
            'Raw response preview: ${response.body.length > 200 ? "${response.body.substring(0, 200)}..." : response.body}');
      }

      if (response.statusCode == 200) {
        if (responseBody != null) {
          return responseBody;
        } else {
          return {
            'success': false,
            'message': 'Invalid response format',
            'statusCode': 200
          };
        }
      } else {
        print('❌ Server error ${response.statusCode}');

        Map<String, dynamic> errorResponse = {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
          'statusCode': response.statusCode,
        };

        if (response.body.isNotEmpty) {
          errorResponse['serverMessage'] = response.body.length > 200
              ? "${response.body.substring(0, 200)}..."
              : response.body;
        }

        if (responseBody != null) {
          errorResponse.addAll(responseBody);
        }

        return errorResponse;
      }
    } catch (e) {
      print('💥 Error in postMethodWithFiles: $e');

      return {
        'success': false,
        'message':
            'Request error: ${e.toString().replaceAll('TimeoutException: ', '')}',
        'error': e.toString(),
        'statusCode': 0
      };
    }
  }

  /// Sends complaint fields and optional photo/video proofs as multipart data.
  /// Do not set Content-Type manually here: MultipartRequest supplies its boundary.
  static Future<Map<String, dynamic>> postComplaintWithFiles(
    Map<String, String> fields,
    Map<String, File> files,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$careerdefenceacademy/postComplaintWithFiles'),
      );
      request.headers['Accept'] = 'application/json';
      final prefs = await SharedPreferences.getInstance();
      final cookie = prefs.getString('session_cookie');
      if (cookie != null && cookie.isNotEmpty) {
        request.headers['cookie'] = cookie;
      }
      request.fields.addAll(fields);
      for (final entry in files.entries) {
        if (await entry.value.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
            entry.key,
            entry.value.path,
          ));
        }
      }
      final streamed =
          await request.send().timeout(const Duration(seconds: 120));
      final response = await http.Response.fromStream(streamed);
      await _saveSessionCookie(prefs, response.headers['set-cookie']);
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {
        'success': false,
        'message':
            'Invalid response from complaint API (${response.statusCode})',
      };
    } catch (error) {
      return {'success': false, 'message': 'Complaint request failed: $error'};
    }
  }

  static Future<http.Response> getComplaintTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final headers = <String, String>{'Accept': 'application/json'};
    final cookie = prefs.getString('session_cookie');
    if (cookie != null && cookie.isNotEmpty) headers['cookie'] = cookie;
    final response = await http
        .get(Uri.parse('$careerdefenceacademy/getMyComplaints'),
            headers: headers)
        .timeout(const Duration(seconds: 30));
    await _saveSessionCookie(prefs, response.headers['set-cookie']);
    return response;
  }

  static postMethod4(url, body) async {
    return Future(() async {
      var result = await http.post(
        Uri.parse(ApiService.websiteUrl + url),
        body: body,
        headers: headerObjFunc(),
      );

      var response = json.decode(result.body);

      return response;
    });
  }
}
