import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/screen/detail_screen.dart';
import 'package:project/screen/detail_screen_arguments.dart';
import 'package:project/screen/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Building HomeScreen'); // Debug print
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda Zenzith'),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
              },
              icon: const Icon(Icons.clear),
              color: Colors.black,
            ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cari Postingan'),
                  content: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: const InputDecoration(
                      hintText: 'Masukkan kata kunci',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cari'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.search),
            color: Colors.black,
          ),
          IconButton(
            onPressed: () => signOut(context),
            icon: const Icon(Icons.logout),
            color: Colors.black,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada postingan tersedia'));
          }

          var posts = snapshot.data!.docs;
          var filteredPosts = posts.where((post) {
            var data = post.data() as Map<String, dynamic>;
            var username = data['username']?.toString().toLowerCase() ?? '';
            var text = data['text']?.toString().toLowerCase() ?? '';
            return username.contains(_searchController.text.toLowerCase()) ||
                text.contains(_searchController.text.toLowerCase());
          }).toList();

          return ListView.builder(
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) {
              var post = filteredPosts[index];
              var data = post.data() as Map<String, dynamic>;
              var postTime = data['timestamp'] as Timestamp;
              var date = postTime.toDate();
              var formattedDate = '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';

              var username = data.containsKey('username') ? data['username'] : 'Anonim';
              var imageUrl = data.containsKey('image_url') ? data['image_url'] : '';
              var text = data.containsKey('text') ? data['text'] : '';

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/detail',
                    arguments: DetailScreenArguments(
                      postId: post.id,
                      username: username,
                      imageUrl: imageUrl,
                      text: text,
                      formattedDate: formattedDate,
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      if (imageUrl.isNotEmpty)
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Text('Gagal memuat gambar'));
                          },
                        )
                      else
                        const SizedBox(
                          width: 100,
                          height: 100,
                          child: Center(child: Text('Gambar tidak tersedia')),
                        ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  color: Colors.lightBlueAccent,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                text,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()), // Pastikan LoginScreen diimpor dengan benar
    );
  }
}
