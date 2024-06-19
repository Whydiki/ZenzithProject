import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'ZenZith',
                style: TextStyle(
                  fontFamily: 'Billabong',
                  fontSize: 50.0.sp,
                ),
              ),
              SizedBox(height: 20.0.h),
              CircleAvatar(
                radius: 40.0.r,
                child: Icon(
                  Icons.person,
                  size: 40.0.r,
                ),
              ),
              SizedBox(height: 20.0.h),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 20.0.h),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 20.0.h),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Bio',
                  prefixIcon: Icon(Icons.info),
                ),
              ),
              SizedBox(height: 20.0.h),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20.0.h),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password Confirm',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20.0.h),
              ElevatedButton(
                onPressed: () {},
                child: Text('Sign up'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50.h),
                ),
              ),
              SizedBox(height: 20.0.h),
              Text("Don't you have an account?"),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Login', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
