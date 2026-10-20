import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/link_model.dart';

class LinkService {
  static const String _storageKey = 'links';
  static const MethodChannel _platform = MethodChannel('com.zurl.app/widget');

  static Future<List<LinkModel>> loadLinks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded.map((e) => LinkModel.fromJson(e)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading links: $e');
      }
    }
    return [];
  }

  static Future<void> saveLinks(List<LinkModel> links) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonString = jsonEncode(links.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);

      // Notify native Android widget channel if on Android
      if (!kIsWeb && Platform.isAndroid) {
        try {
          await _platform.invokeMethod('saveLinks', {'data': jsonString});
        } catch (e) {
          if (kDebugMode) {
            print('MethodChannel call error: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving links: $e');
      }
    }
  }
}
