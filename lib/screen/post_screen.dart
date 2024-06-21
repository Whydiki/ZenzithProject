import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  final Map<String, dynamic> postData;

  const PostScreen({Key? key, required this.postData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
      ),
      body: Center(
        child: Text(postData['postText'] ?? 'No data available'),
      ),
    );
  }
}
