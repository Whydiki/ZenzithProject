import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatefulWidget {
  final String postId;
  final String username;
  final String imageUrl;
  final String text;
  final String formattedDate;

  const DetailScreen({
    Key? key,
    required this.postId,
    required this.username,
    required this.imageUrl,
    required this.text,
    required this.formattedDate,
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool showComments = true;
  bool isFavorite = false;
  GeoPoint? _location;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _checkFavorite().then((isFavorite) {
      setState(() {
        this.isFavorite = isFavorite;
      });
    });
  }

  Future<void> _fetchLocation() async {
    DocumentSnapshot doc = await _firestore.collection('posts').doc(widget.postId).get();
    setState(() {
      _location = doc['location'];
    });
  }

  Future<void> _toggleFavorite() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String userId = user.uid;

      DocumentSnapshot favoriteDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(widget.postId)
          .get();

      if (favoriteDoc.exists) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(widget.postId)
            .delete();
        setState(() {
          isFavorite = false;
        });
      } else {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(widget.postId)
            .set({
          'username': widget.username,
          'imageUrl': widget.imageUrl,
          'text': widget.text,
          'formattedDate': widget.formattedDate,
        });
        setState(() {
          isFavorite = true;
        });
      }
    }
  }

  Future<bool> _checkFavorite() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String userId = user.uid;

      DocumentSnapshot favoriteDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(widget.postId)
          .get();

      return favoriteDoc.exists;
    }
    return false;
  }

  Future<void> _addComment(String text) async {
    User? user = _auth.currentUser;
    if (user != null) {
      String username = user.email ?? 'Anonymous';
      await _firestore
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'username': username,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _commentController.clear();
      });
    }
  }

  void _launchURL() async {
    if (_location != null) {
      final url = 'https://www.google.com/maps/search/?api=1&query=${_location!.latitude},${_location!.longitude}';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postingan'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.imageUrl.isNotEmpty)
                Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Gagal memuat gambar'));
                  },
                )
              else
                const Center(child: Text('Gambar tidak tersedia')),
              const SizedBox(height: 8),
              Text(
                widget.username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(widget.formattedDate),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.text,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_location != null)
                GestureDetector(
                  onTap: _launchURL,
                  child: const Text(
                    'Lihat Lokasi ',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Komentar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: Icon(showComments ? Icons.expand_less : Icons.expand_more),
                    onPressed: () {
                      setState(() {
                        showComments = !showComments;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (showComments)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('posts')
                          .doc(widget.postId)
                          .collection('comments')
                          .orderBy('timestamp')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('Belum ada komentar'));
                        }

                        List<Widget> commentWidgets = snapshot.data!.docs.map((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(data['username']),
                            subtitle: Text(data['text']),
                            trailing: Text(
                              '${(data['timestamp'] as Timestamp).toDate().day}/${(data['timestamp'] as Timestamp).toDate().month}/${(data['timestamp'] as Timestamp).toDate().year} ${(data['timestamp'] as Timestamp).toDate().hour}:${(data['timestamp'] as Timestamp).toDate().minute}',
                            ),
                          );
                        }).toList();

                        return ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: commentWidgets,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              labelText: 'Tambahkan komentar',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            if (_commentController.text.isNotEmpty) {
                              _addComment(_commentController.text);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
