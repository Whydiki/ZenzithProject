import 'package:cloud_firestore/cloud_firestore.dart';

class Usermodel {
  final String uid;
  final String username;
  final String profile;
  final String bio;
  final List followers;
  final List following;

  Usermodel({
    required this.uid,
    required this.username,
    required this.profile,
    required this.bio,
    required this.followers,
    required this.following,
  });

  factory Usermodel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Usermodel(
      uid: data['uid'] ?? '',
      username: data['username'] ?? '',
      profile: data['profile'] ?? '',
      bio: data['bio'] ?? '',
      followers: data['followers'] ?? [],
      following: data['following'] ?? [],
    );
  }
}
