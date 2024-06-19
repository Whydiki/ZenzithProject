import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
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
              SizedBox(height: 40.0.h),
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
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20.0.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot your password?',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              SizedBox(height: 20.0.h),
              ElevatedButton(
                onPressed: () {},
                child: Text('Log in'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50.h),
                ),
              ),
              SizedBox(height: 20.0.h),
              Text("Don't have an account?"),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text('Sign up', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
