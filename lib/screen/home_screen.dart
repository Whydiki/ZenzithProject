import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/widgets/post_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: SizedBox(
          width: 105.w,
          height: 28.h,
          child: Image.asset('images/zenzith.png'),
        ),
        leading: Image.asset('images/camera.jpg'),
        actions: [
          const Icon(
            Icons.favorite_border_outlined,
            color: Colors.black,
            size: 25,
          ),
          Image.asset('images/send.jpg'),
        ],
        backgroundColor: const Color(0xffFAFAFA),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            sliver: StreamBuilder<QuerySnapshot>(
              stream: _firebaseFirestore
                  .collection('posts')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(child: Text('No posts found.')),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      var postData = snapshot.data!.docs[index].data();
                      return PostWidget(postData);
                    },
                    childCount: snapshot.data!.docs.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
