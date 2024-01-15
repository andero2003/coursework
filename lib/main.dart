import 'package:cwflutter/src/services/AuthService.dart';
import 'package:cwflutter/src/services/FirestoreService.dart';
import 'package:cwflutter/src/services/ProjectService.dart';
import 'package:cwflutter/src/services/ThemeService.dart';
import 'package:cwflutter/src/views/dashboard.dart';
import 'package:cwflutter/src/views/LoginPage.dart';
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
  late ThemeService themeService;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialiseServices();
  }

  Future<void> _initialiseServices() async {
    authService = AuthService();
    firestoreService = FirestoreService();
    projectService = ProjectService(authService, firestoreService);
    themeService = await ThemeService.init();

    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => authService),
      ChangeNotifierProvider(create: (_) => firestoreService),
      ChangeNotifierProvider(create: (_) => projectService),
      ChangeNotifierProvider(create: (_) => themeService)
    ], child: ThemedApp());
  }
}

class ThemedApp extends StatelessWidget {
  const ThemedApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    return MaterialApp(
        title: 'App',
        themeMode: themeService.getThemeMode(),
        theme: ThemeData(primarySwatch: Colors.lightBlue, fontFamily: "Gotham"
            //textTheme: GoogleFonts.montserratTextTheme()
            ),
        darkTheme: ThemeData.dark().copyWith(textTheme: Typography().white.apply(fontFamily: GoogleFonts.montserrat().fontFamily)),
        home: Consumer<AuthService>(builder: (context, authService, _) {
          if (authService.loggedUser != null) {
            return DashboardPage(user: authService.loggedUser!);
          } else {
            return const LoginPage();
          }
        }));
  }
}
