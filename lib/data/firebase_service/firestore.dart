import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:project/data/model/usermodel.dart';

class Firebase_Firestore {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> createUser({
    required String email,
    required String username,
    required String bio,
    required String profile,
  }) async {
    try {
      await _firebaseFirestore.collection('users').doc(_auth.currentUser!.uid).set({
        'email': email,
        'username': username,
        'bio': bio,
        'profile': profile,
        'followers': [],
        'following': [],
      });
      return true;
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  Future<Usermodel> getUser({String? UID}) async {
    try {
      final userDoc = await _firebaseFirestore.collection('users').doc(UID ?? _auth.currentUser!.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        return Usermodel.fromDocument(userDoc);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  Future<bool> createPost({
    required String postImage,
    required String caption,
    required String location,
  }) async {
    try {
      var uid = Uuid().v4();
      DateTime timestamp = DateTime.now();
      Usermodel user = await getUser();
      await _firebaseFirestore.collection('posts').doc(uid).set({
        'postImage': postImage,
        'username': user.username,
        'profileImage': user.profile,
        'caption': caption,
        'location': location,
        'uid': _auth.currentUser!.uid,
        'postId': uid,
        'like': [],
        'time': timestamp,
      });
      return true;
    } catch (e) {
      throw Exception('Failed to create post: ${e.toString()}');
    }
  }

  Future<bool> addComment({
    required String comment,
    required String type,
    required String postId,
  }) async {
    try {
      var uid = Uuid().v4();
      Usermodel user = await getUser();
      await _firebaseFirestore.collection(type).doc(postId).collection('comments').doc(uid).set({
        'comment': comment,
        'username': user.username,
        'profileImage': user.profile,
        'commentUid': uid,
      });
      return true;
    } catch (e) {
      throw Exception('Failed to add comment: ${e.toString()}');
    }
  }

  Future<String> toggleLike({
    required List likes,
    required String type,
    required String postId,
  }) async {
    try {
      if (likes.contains(_auth.currentUser!.uid)) {
        await _firebaseFirestore.collection(type).doc(postId).update({
          'like': FieldValue.arrayRemove([_auth.currentUser!.uid]),
        });
      } else {
        await _firebaseFirestore.collection(type).doc(postId).update({
          'like': FieldValue.arrayUnion([_auth.currentUser!.uid]),
        });
      }
      return 'Success';
    } catch (e) {
      return 'Failed: ${e.toString()}';
    }
  }

  Future<void> toggleFollow({
    required String userId,
  }) async {
    try {
      DocumentSnapshot userSnapshot = await _firebaseFirestore.collection('users').doc(_auth.currentUser!.uid).get();
      Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        List<dynamic> following = userData['following'];

        if (following.contains(userId)) {
          await _firebaseFirestore.collection('users').doc(_auth.currentUser!.uid).update({
            'following': FieldValue.arrayRemove([userId]),
          });
          await _firebaseFirestore.collection('users').doc(userId).update({
            'followers': FieldValue.arrayRemove([_auth.currentUser!.uid]),
          });
        } else {
          await _firebaseFirestore.collection('users').doc(_auth.currentUser!.uid).update({
            'following': FieldValue.arrayUnion([userId]),
          });
          await _firebaseFirestore.collection('users').doc(userId).update({
            'followers': FieldValue.arrayUnion([_auth.currentUser!.uid]),
          });
        }
      } else {
        throw Exception('Error: User data is null.');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
