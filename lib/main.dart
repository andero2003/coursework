import 'package:cwflutter/src/services/AuthService.dart';
import 'package:cwflutter/src/services/FirestoreService.dart';
import 'package:cwflutter/src/services/ProjectService.dart';
import 'package:cwflutter/src/views/dashboard.dart';
import 'package:cwflutter/src/views/loginPage.dart';
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
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  late AuthService authService;
  late FirestoreService firestoreService;
  late ProjectService projectService;

  @override
  void initState() {
    authService = AuthService();
    firestoreService = FirestoreService();
    projectService = ProjectService(authService, firestoreService);
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        ChangeNotifierProvider(create: (_) => firestoreService),
        ChangeNotifierProvider(create: (_) => projectService)
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
                return const LoginPage();
              }              
            }
          )
        )
    );
  }
}