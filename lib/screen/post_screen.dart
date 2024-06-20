import 'package:flutter/material.dart';
import 'package:project/widgets/post_widget.dart';

class PostScreen extends StatelessWidget {
  final snapshot;
  PostScreen(this.snapshot, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: PostWidget(snapshot)),
    );
  }
}
