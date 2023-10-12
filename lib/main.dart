import 'package:cwflutter/pages/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: GoogleFonts.montserratTextTheme()
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: Typography().white.apply(fontFamily: GoogleFonts.montserrat().fontFamily)
      ),
      home: Builder(
        builder: (context) {
          return LoginPage();  //DashboardPage(username: 'DevAndero', avatarUrl: 'https://tr.rbxcdn.com/15DAY-AvatarHeadshot-CE7D8D582277E5C8F658DD07D85AF642-Png/150/150/AvatarHeadshot/Png/noFilter');
        }
      )
    );
  }
}