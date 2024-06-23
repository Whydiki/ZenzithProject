import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/screen/detail_screen.dart';
import 'package:project/screen/detail_screen_arguments.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Posts'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .where('userId', isEqualTo: _auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No favorite posts available'));
          }

          var favorites = snapshot.data!.docs;

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              var favorite = favorites[index];
              var data = favorite.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['username'] ?? 'No Title'),
                subtitle: Text(data['text'] ?? 'No Description'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/detail',
                    arguments: DetailScreenArguments(
                      postId: data['postId'],
                      username: data['username'],
                      imageUrl: data['imageUrl'],
                      text: data['text'],
                      formattedDate: data['formattedDate'],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
