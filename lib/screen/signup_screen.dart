import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project/data/firebase_service/firebase_auth.dart';
import 'package:project/util/dialog.dart';
import 'package:project/util/imagepicker.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback show;
  const SignupScreen(this.show, {Key? key}) : super(key: key);

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
                      ? AssetImage('images/person.png')
                      : FileImage(profileImage!) as ImageProvider,
                ),
              ),
              SizedBox(height: 20.h),
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
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: TextField(
                  controller: username,
                  focusNode: usernameFocus,
                  decoration: InputDecoration(
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
                  decoration: InputDecoration(
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
                  decoration: InputDecoration(
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
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () async {
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
                child: Text('Sign up'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
                ),
              ),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: widget.show,
                child: Text(
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
