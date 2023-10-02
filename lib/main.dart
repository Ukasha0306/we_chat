import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:we_chat/auth/auth.dart';
import 'package:we_chat/auth/profile_controller.dart';
import 'package:we_chat/screens/notification_service.dart';
import 'package:we_chat/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // for full screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController(),
      child: Consumer<ProfileController>(
        builder: (context, provider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Chat App',
            theme: ThemeData(
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                iconTheme: IconThemeData(color: Colors.black),
                backgroundColor: Colors.white,
                elevation: 1,
                centerTitle: true,
                titleTextStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black),
              ),
              iconTheme: const IconThemeData(color: Colors.black, size: 16),
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
