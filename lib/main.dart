// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/settings_page.dart';
import 'package:flutter_application_1/timer_model.dart';
import 'package:flutter_application_1/timer_page.dart';
import 'package:flutter_application_1/data_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import 'more_icons_app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    // Attempt to sign in anonymously. If already signed in (e.g., from a previous session),
    // it will reuse the existing anonymous user.
    UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
    print("Signed in anonymously with UID: ${userCredential.user?.uid}");
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'operation-not-allowed':
        print("Anonymous sign-in hasn't been enabled for this project.");
        // This is the error if you haven't enabled it in Firebase Console!
        break;
      default:
        print("Unknown error during anonymous sign-in: $e");
    }
  }

  await initNotifications();

  if (Platform.isWindows || Platform.isLinux) {
    setWindowTitle('Focus App');
    setWindowMinSize(const Size(1280, 800));
    setWindowMaxSize(const Size(1280, 800));
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => TimerModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: const Color(0xFF90CAF9),      // light blue for highlights
          onPrimary: Colors.black,               // text/icons on primary
          secondary: const Color(0xFF80CBC4),    // teal for accents
          onSecondary: Colors.black,
          error: const Color(0xFFEF5350),        // softer red
          onError: Colors.black,
          surface: const Color.fromARGB(255, 49, 49, 49),      // slightly lighter gray for cards
          onSurface: Colors.white,               // text/icons on surface
        ),
      ),
      home: const FocusTimer(),
    );
  }
}

class FocusTimer extends StatefulWidget {
  const FocusTimer({super.key});

  @override
  _FocusTimerState createState() => _FocusTimerState();
}

class _FocusTimerState extends State<FocusTimer> {
  
  @override
  Widget build(BuildContext context) {
    final timerModel = Provider.of<TimerModel>(context);
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NavigationRail(
            indicatorColor: timerModel.interactableColor,
            selectedIndex: timerModel.selectedIndex,
            leading: SizedBox(
              height: 225,
            ),
            onDestinationSelected: (int index) {
              setState(() {
                timerModel.selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: const Icon(MoreIconsApp.clock),
                label: const Text('Timer'),
              ),
              NavigationRailDestination(
                icon: const Icon(MoreIconsApp.sliders),
                label: const Text('Settings'),
              ),
              NavigationRailDestination(
                icon: const Icon(MoreIconsApp.chart_bar),
                label: const Text('Data'),
              ),
            ],
          ),
          const VerticalDivider(
              width: 1,
              thickness: 1,
              color: Color.fromARGB(255, 85, 85, 85),
          ),
          // Selected Page
          Expanded(
            child: IndexedStack(
              index: timerModel.selectedIndex,
              children: const [
                TimerPage(),
                SettingsPage(),
                DataPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}