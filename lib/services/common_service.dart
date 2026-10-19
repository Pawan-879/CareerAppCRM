import 'dart:convert';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommonService {
  static var registerValues = {
    'countryId': '',
    'userName': '',
    'email': '',
    'confirmEmail': '',
    'firstName': '',
    'lastName': '',
    'deviceId': ''
  };

  static emptyContainer() {
    return Container();
  }

  static isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    for (final key in ['userData', 'staffData', 'consulData']) {
      final raw = prefs.getString(key);
      if (raw == null || raw.trim().isEmpty) continue;
      try {
        final decoded = json.decode(raw);
        if (decoded is Map<String, dynamic>) {
          return decoded['active'] == '1' || decoded['active'] == 1;
        }
        await prefs.remove(key);
      } on FormatException {
        // A stale or partial session value should not block the login screen.
        await prefs.remove(key);
      }
    }

    return false;
  }

  static showLoading() {
    return BotToast.showLoading();
  }

  static closeLoading() {
    return BotToast.closeAllLoading();
  }

  static logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userData', '');
    prefs.setString('staffData', '');
    prefs.setString('consulData', '');
  }
}
