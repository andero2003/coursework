import 'package:cwflutter/pages/dashboard.dart';
import 'package:cwflutter/services/AuthService.dart';
import 'package:cwflutter/services/RobloxOAuthService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

final clientId = '5605260986374250325';
final clientSecret = 'RBX-JaM0u4x_A0WMZledf3dOot1x81S8iP9BYZX3EkTM3NmYjfHflAa6XDhMQf8HMSE9';
final redirectUri = 'fluttertest://return';
final scope = 'openid+profile';
final responseType = 'code';

class LoginPage extends StatefulWidget {
  late AuthService authService;
  LoginPage({required this.authService});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    bool _isLoading = false;

    void _handleLogin(context) async {
      setState(() {
        _isLoading = true;  // show loading
      });

      await RobloxAuth().authenticate(widget.authService);

      setState(() {
        _isLoading = false;  // show loading
      });
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
