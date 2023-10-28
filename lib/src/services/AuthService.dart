import 'dart:async';
import 'package:cwflutter/src/models/User.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const clientId = '5605260986374250325';
const clientSecret = 'RBX-JaM0u4x_A0WMZledf3dOot1x81S8iP9BYZX3EkTM3NmYjfHflAa6XDhMQf8HMSE9';
const redirectUri = 'fluttertest://redirect';
const scope = 'openid+profile';
const responseType = 'code';

class AuthService extends ChangeNotifier {
  final _secureStorage = const FlutterSecureStorage();
  final _appAuth = const FlutterAppAuth();

  User? _loggedUser;

  User? get loggedUser => _loggedUser;

  set loggedUser(User? value) {
    _loggedUser = value;
    notifyListeners();
  }

  Future<void> login(String accessToken, String? refreshToken) async {
    await _secureStorage.write(key: 'access_token', value: accessToken);
    String expiryTime = DateTime.now().add(const Duration(minutes: 15)).toString();
    await _secureStorage.write(key: 'access_token_expiry', value: expiryTime);
    if (refreshToken != null) {
      await _secureStorage.write(key: 'refresh_token', value: refreshToken);
    }

    User? user = await getUserData(accessToken);
    loggedUser = user;
  }
  
  Future<void> logout() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'user_id');
    loggedUser = null;
  }

  Future<String?> getAccessToken() async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    String? expiry = await _secureStorage.read(key: 'access_token_expiry');
    
    if (accessToken != null && expiry != null) {
      DateTime expiryDate = DateTime.tryParse(expiry) ?? DateTime.now();
      if (expiryDate.isBefore(DateTime.now())) {
        // Token is expired
        String? refreshToken = await _secureStorage.read(key: 'refresh_token');
        
        if (refreshToken != null) {
          // If refresh token exists, try to refresh the access token silently
          try {
            final response = await http.post(
              Uri.parse('https://apis.roblox.com/oauth/v1/token'),
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
              },
              body: {
                'grant-type': 'refresh_token',
                'refresh_token': refreshToken,
                'client_id': clientId,
                'client_secret': clientSecret,
              }
            );
            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              print(data);
            } 
          } catch (error) {
            // Handle error (for example, force the user to log in again)
            await logout();
          }
        } else {
          // If no refresh token exists, force a logout.
          await logout();
        }
      }
    }
    
    return accessToken;
  }
  
  Future<User?> getUserData(String accessToken) async {
    final userInfoResponse = await http.get(
      Uri.parse('https://apis.roblox.com/oauth/v1/userinfo'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    final Map<String, dynamic> userData = json.decode(userInfoResponse.body);
    final username = userData['preferred_username'];
    final avatarUrl = userData['picture'];
    final userId = int.parse(userData['sub']);
    return User(
      user_id: userId, 
      username: username, 
      avatar_image: avatarUrl
    );
  }

  Future<void> oauthAuthenticate() async {
    //String? existingAccessToken = await authService.getAccessToken();
    //print(existingAccessToken);
    //if (existingAccessToken != null) {
    //  authService.login(existingAccessToken, null);
    //  return null;
    //}

    try {
      final AuthorizationTokenResponse? result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUri,
          discoveryUrl: 'https://apis.roblox.com/oauth/.well-known/openid-configuration',
          scopes: ['openid', 'profile']
        ),
      );
      login(result!.accessToken!, result.refreshToken!);
    } catch(e) {
      //error handle
    };
  }
}
