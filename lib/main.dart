import 'package:cwflutter/classes/User.dart';
import 'package:cwflutter/pages/dashboard.dart';
import 'package:cwflutter/pages/loginPage.dart';
import 'package:cwflutter/services/AuthService.dart';
import 'package:cwflutter/services/DatabaseService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  AuthService authService = AuthService();
  DatabaseService databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        ChangeNotifierProvider(create: (_) => databaseService)
      ],
      child: MaterialApp(
          title: 'App',
          themeMode: ThemeMode.light,
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            textTheme: GoogleFonts.montserratTextTheme()
          ),
          darkTheme: ThemeData.dark().copyWith(
            textTheme: Typography().white.apply(fontFamily: GoogleFonts.montserrat().fontFamily)
          ),
          home: Consumer<AuthService>(
            builder: (context, authService, _) {
              if (authService.loggedUser != null) {
                return DashboardPage(user: authService.loggedUser!);
              } else {
                return LoginPage(authService: authService,);
              }              
            }
          )
        )
    );
  }
}