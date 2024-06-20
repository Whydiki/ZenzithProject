import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/data/firebase_service/firestore.dart';
import 'package:project/data/firebase_service/storage.dart';
import 'package:project/util/exceptions.dart';

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw Exceptions(e.message.toString());
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String passwordConfirme,
    required String username,
    required String bio,
    required File profile,
  }) async {
    String url;
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        if (password == passwordConfirme) {
          // Create user with email and password
          await _auth.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

          // Upload profile image to storage
          if (profile != File('')) {
            url = await StorageMethod().uploadImageToStorage('Profile', profile);
          } else {
            url = '';
          }

          // Create user information in Firestore
          await Firebase_Firestore().createUser(
            email: email,
            username: username,
            bio: bio,
            profile: url.isEmpty
                ? 'https://firebasestorage.googleapis.com/v0/b/zenzith-a4145.appspot.com/o/person.png?alt=media&token=828ec7fc-1e64-49d4-9d56-ed989988ec79'
                : url,
          );
        } else {
          throw Exceptions('Password and confirm password should be the same');
        }
      } else {
        throw Exceptions('Please enter all the fields');
      }
    } on FirebaseAuthException catch (e) {
      throw Exceptions(e.message.toString());
    }
  }
}
