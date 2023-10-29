// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:cwflutter/src/models/FetchResult.dart';
import 'package:cwflutter/src/models/User.dart';
import 'package:cwflutter/src/services/RobloxAPIService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cwflutter/main.dart';

void main() async {
  final user = User(user_id: 13863572, username: 'DevAndero', avatar_image: "https://tr.rbxcdn.com/30DAY-AvatarHeadshot-CE7D8D582277E5C8F658DD07D85AF642-Png/150/150/AvatarHeadshot/Png/noFilter");
  final int universeId = 4791277194;
  final FetchResult awaited = await RobloxAPIService().fetchGameThumbnailById(universeId);
  print(awaited.data);
}
