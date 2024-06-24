import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/firebase_options.dart';
import 'package:project/screen/navigations_screen.dart';
import 'package:project/screen/login_screen.dart';
import 'package:project/screen/signup_screen.dart'; // Pastikan jalur ini benar
import 'package:project/screen/detail_screen.dart';
import 'package:project/screen/detail_screen_arguments.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Zenzith Project',
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasData) {
                return const NavigationsScreen();
              } else {
                return const LoginScreen();
              }
            },
          ),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/navigation': (context) => const NavigationsScreen(),
            '/signup': (context) => const SignupScreen(), // Tambahkan rute untuk halaman signup
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/detail') {
              final args = settings.arguments as DetailScreenArguments;
              return MaterialPageRoute(
                builder: (context) {
                  return DetailScreen(
                    postId: args.postId,
                    username: args.username,
                    imageUrl: args.imageUrl,
                    text: args.text,
                    formattedDate: args.formattedDate,
                  );
                },
              );
            }
            return null;
          },
        );
      },
    );
  }
}
