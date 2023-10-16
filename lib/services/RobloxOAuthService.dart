import 'package:cwflutter/classes/User.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cwflutter/services/AuthService.dart';
import 'dart:convert';

class RobloxAuth {
  static const String clientId = '5605260986374250325';
  static const String clientSecret = 'RBX-JaM0u4x_A0WMZledf3dOot1x81S8iP9BYZX3EkTM3NmYjfHflAa6XDhMQf8HMSE9';
  static const String redirectUri = 'fluttertest://redirect';

  final FlutterAppAuth appAuth = FlutterAppAuth();

  Future<void> authenticate(AuthService authService) async {
    //String? existingAccessToken = await authService.getAccessToken();
    //print(existingAccessToken);
    //if (existingAccessToken != null) {
    //  authService.login(existingAccessToken, null);
    //  return null;
    //}

    try {
      final AuthorizationTokenResponse? result = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUri,
          discoveryUrl: 'https://apis.roblox.com/oauth/.well-known/openid-configuration',
          scopes: ['openid', 'profile']
        ),
      );
      authService.login(result!.accessToken!, result.refreshToken!);
    } catch(e) {
      print(e);
    };
  }
}