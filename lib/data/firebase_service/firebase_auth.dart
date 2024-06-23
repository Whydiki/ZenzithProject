import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Jika Anda ingin menyimpan data ke Firestore
import 'package:firebase_storage/firebase_storage.dart'; // Jika Anda ingin menyimpan gambar ke Firebase Storage

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signup({
    required String email,
    required String password,
    required String passwordConfirme,
    required String username,
    required String bio,
    required File profile,
  }) async {
    try {
      // Buat akun pengguna baru dengan email dan password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Dapatkan UID pengguna yang baru dibuat
      String uid = userCredential.user!.uid;

      // Unggah gambar profil ke Firebase Storage
      String profileImageUrl = await _uploadProfileImage(uid, profile);

      // Simpan data tambahan ke Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'username': username,
        'bio': bio,
        'profileImageUrl': profileImageUrl,
      });
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<String> _uploadProfileImage(String uid, File profile) async {
    try {
      // Tentukan path untuk gambar profil di Firebase Storage
      Reference ref = FirebaseStorage.instance.ref().child('profile_images').child('$uid.jpg');

      // Unggah file ke path yang telah ditentukan
      UploadTask uploadTask = ref.putFile(profile);

      // Tunggu hingga unggahan selesai dan dapatkan URL gambar
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Gagal mengunggah gambar profil: $e');
    }
  }
}
