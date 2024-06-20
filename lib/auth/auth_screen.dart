import 'package:flutter/material.dart';
import 'package:project/screen/login_screen.dart';
import 'package:project/screen/signup_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLoginSelected = true;

  void toggleScreen() {
    setState(() {
      isLoginSelected = !isLoginSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: isLoginSelected ? LoginScreen(toggleScreen) : SignupScreen(toggleScreen),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: toggleScreen,
                child: Text(
                  isLoginSelected ? 'Don\'t have an account? Sign up' : 'Already have an account? Login',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
