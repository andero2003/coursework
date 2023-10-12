import 'package:cwflutter/classes/TokenValidator.dart';
import 'package:cwflutter/pages/authWebViewPage.dart';
import 'package:cwflutter/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

final clientId = '5605260986374250325';
final clientSecret = 'RBX-JaM0u4x_A0WMZledf3dOot1x81S8iP9BYZX3EkTM3NmYjfHflAa6XDhMQf8HMSE9';
final redirectUri = 'fluttertest://return';
final scope = 'openid+profile';
final responseType = 'code';

class LoginPage extends StatefulWidget {

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    bool _isLoading = false;

    final url = Uri.parse(
      'https://apis.roblox.com/oauth/v1/authorize'
      '?client_id=$clientId'
      '&redirect_uri=$redirectUri'
      '&scope=$scope'
      '&response_type=$responseType',
    );

    void _proceedWithToken(String accessToken) async {
        TokenValidator().write('accessToken', accessToken);
      
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

        setState(() {
          _isLoading = false;
        });
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => DashboardPage(username: username, avatarUrl: avatarUrl, userId: userId,))
        );
    }

    void _handleLogin(context) async {
      setState(() {
        _isLoading = true;  // show loading
      });

      String? validToken = await TokenValidator().validateToken();
      if (validToken != null) {
        _proceedWithToken(validToken);
        return null;
      }

      String? accessToken = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthWebView(
            url: url,
            redirectUri: 'fluttertest://return',
          ),
        ),
      );

      if (accessToken != null) {
        _proceedWithToken(accessToken);
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Login to continue',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleLogin(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SvgPicture.network(
                    'https://upload.wikimedia.org/wikipedia/commons/3/3a/Roblox_player_icon_black.svg',  // Replace with the path to your Roblox logo image file
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text('Login with Roblox', style:TextStyle(fontSize: 20),),
                ],
              ),
            ),
            SizedBox(height: 25),
            Opacity(opacity: _isLoading ? 1 : 0, child:  CircularProgressIndicator()),
          ],
        )
      ),
    );
  }
}
