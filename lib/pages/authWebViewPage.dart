import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final clientId = '5605260986374250325';
final clientSecret = 'RBX-JaM0u4x_A0WMZledf3dOot1x81S8iP9BYZX3EkTM3NmYjfHflAa6XDhMQf8HMSE9';
final redirectUri = 'fluttertest://return';

class AuthWebView extends StatelessWidget {
  final Uri url;
  final String redirectUri;

  AuthWebView({required this.url, required this.redirectUri});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(url)
    ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) async {
          print(request.url);
          if (request.url.startsWith(redirectUri)) {
            // Handle OAuth response
            final authCode = Uri.parse(request.url).queryParameters['code'];
            print('Authorization Code: $authCode');

            final response = await http.post(
              Uri.parse('https://apis.roblox.com/oauth/v1/token'),  // Replace with the correct token endpoint
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
              },
              body: {
                'grant_type': 'authorization_code',
                'code': authCode,
                'redirect_uri': redirectUri,
                'client_id': clientId,
                'client_secret': clientSecret,
              },
            );
            if (response.statusCode == 200) {
              final Map<String, dynamic> data = json.decode(response.body);
              final accessToken = data['access_token'];
              final refreshToken = data['refresh_token'];
              print('Access Token: $accessToken');
              print('Refresh Token: $refreshToken');
              // Store the access token and refresh token securely

              final userInfoResponse = await http.get(
                Uri.parse('https://apis.roblox.com/oauth/v1/userinfo'),  // Replace with the correct token endpoint
                headers: {
                  'Authorization': 'Bearer $accessToken',
                },
              );

              if (userInfoResponse.statusCode == 200) {

                // Close the WebView and return to the main UI
                Navigator.pop(context, accessToken);  // Pass the tokens back to the main UI
                return NavigationDecision.prevent;
              }
            }
          }
          return NavigationDecision.navigate;
        },  
    ));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('OAuth Authorization'),
      ),
      body: WebViewWidget(
              controller: controller,
            )
    );
  }
}