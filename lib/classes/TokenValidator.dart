import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TokenValidator {
  final storage = new FlutterSecureStorage();

  Future<String?> get(String key) async {
    return await storage.read(key: key);
  }

  Future<void> write(String key, String value) async {
    return await storage.write(key: key, value: value);
  }

  Future<bool> isAccessTokenValid(String accessToken) async {
    final response = await http.get(
      Uri.parse('https://apis.roblox.com/oauth/v1/userinfo'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    return response.statusCode == 200;
  }

  Future<String?> validateToken() async {
    final accessToken = await get('accessToken');
    if (accessToken != null) {
      final isValid = await isAccessTokenValid(accessToken);
      if (isValid) {
        return accessToken;
      }
    }
    return null;
  }
}