import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/data/firebase_service/firebase_auth.dart'; // Pastikan jalur ini benar
import 'package:project/util/dialog.dart'; // Pastikan jalur ini benar
import 'package:project/util/imagepicker.dart'; // Pastikan jalur ini benar
import 'package:project/screen/login_screen.dart'; // Pastikan jalur ini benar

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController email = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final TextEditingController password = TextEditingController();
  final FocusNode passwordFocus = FocusNode();
  final TextEditingController passwordConfirm = TextEditingController();
  final FocusNode passwordConfirmFocus = FocusNode();
  final TextEditingController username = TextEditingController();
  final FocusNode usernameFocus = FocusNode();
  final TextEditingController bio = TextEditingController();
  final FocusNode bioFocus = FocusNode();
  File? profileImage;

  @override
  void dispose() {
    email.dispose();
    emailFocus.dispose();
    password.dispose();
    passwordFocus.dispose();
    passwordConfirm.dispose();
    passwordConfirmFocus.dispose();
    username.dispose();
    usernameFocus.dispose();
    bio.dispose();
    bioFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 100.h),
              InkWell(
                onTap: () async {
                  File? image = await ImagePickerr().uploadImage('gallery');
                  if (image != null) {
                    setState(() {
                      profileImage = image;
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 50.r,
                  backgroundColor: Colors.grey,
                  backgroundImage: profileImage == null
                      ? const AssetImage('images/person.png')
                      : FileImage(profileImage!) as ImageProvider,
                ),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: TextField(
                  controller: email,
                  focusNode: emailFocus,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: TextField(
                  controller: username,
                  focusNode: usernameFocus,
                  decoration: const InputDecoration(
                    hintText: 'Username',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: TextField(
                  controller: bio,
                  focusNode: bioFocus,
                  decoration: const InputDecoration(
                    hintText: 'Bio',
                    prefixIcon: Icon(Icons.info),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: TextField(
                  controller: password,
                  focusNode: passwordFocus,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: TextField(
                  controller: passwordConfirm,
                  focusNode: passwordConfirmFocus,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () async {
                  if (password.text != passwordConfirm.text) {
                    dialogBuilder(context, 'Passwords do not match');
                    return;
                  }

                  try {
                    await Authentication().signup(
                      email: email.text,
                      password: password.text,
                      passwordConfirme: passwordConfirm.text,
                      username: username.text,
                      bio: bio.text,
                      profile: profileImage ?? File(''),
                    );
                    // Navigate to main page or dashboard
                  } catch (e) {
                    dialogBuilder(context, e.toString());
                  }
                },
                child: const Text('Sign up'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
                ),
              ),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
