import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static const String guestKey = 'guest_id';

  Future<String> getOrCreateGuestUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? guestId = prefs.getString(guestKey);

    if (guestId == null) {
      guestId = const Uuid().v4(); // Generate a unique ID
      await prefs.setString(guestKey, guestId);
      
      // Store guest in the database
      await saveGuestToDB(guestId);
    }

    return guestId;
  }

 Future<void> saveGuestToDB(String guestId) async {
  const String apiUrl = 'https://careerdefenceacademy.com/saveGuestLogin'; 
  
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"uuid": guestId}),
    );

    if (response.statusCode == 200) {
      print("Guest login saved successfully.");
    } else {
      print("Failed to save guest login: ${response.body}");
    }
  } catch (e) {
    print("Error saving guest login: $e");
  }
}

}