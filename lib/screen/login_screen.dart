import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/data/firebase_service/firebase_auth.dart';
import 'package:project/util/dialog.dart';
import 'package:project/util/exceptions.dart';
import 'package:project/screen/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback show;
  const LoginScreen(this.show, {Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController email = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final TextEditingController password = TextEditingController();
  final FocusNode passwordFocus = FocusNode();

  @override
  void dispose() {
    email.dispose();
    emailFocus.dispose();
    password.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 100.h),
            Image.asset(
              'images/logo.png',
              width: 200.w,
            ),
            SizedBox(height: 60.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TextField(
                controller: email,
                focusNode: emailFocus,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: TextField(
                controller: password,
                focusNode: passwordFocus,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () async {
                try {
                  await Authentication().login(
                    email: email.text,
                    password: password.text,
                  );
                  // Navigate to main page or dashboard
                } catch (e) {
                  dialogBuilder(context, e.toString());
                }
              },
              child: Text('Login'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
              ),
            ),
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: widget.show,
              child: Text(
                'Don\'t have an account? Sign up',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
