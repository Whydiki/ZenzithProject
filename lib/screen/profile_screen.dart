import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/data/firebase_service/firestore.dart';
import 'package:project/data/model/usermodel.dart';
import 'package:project/screen/post_screen.dart';
import 'package:project/util/image_cached.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int postLength = 0;
  bool isYourself = false;
  List following = [];
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    getData();
    if (widget.uid == _auth.currentUser!.uid) {
      setState(() {
        isYourself = true;
      });
    }
  }

  getData() async {
    DocumentSnapshot snap = await _firebaseFirestore.collection('users').doc(widget.uid).get();
    following = (snap.data() as dynamic)['following'];
    if (following.contains(widget.uid)) {
      setState(() {
        isFollowing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: FutureBuilder<Usermodel>(
                  future: Firebase_Firestore().getUser(UID: widget.uid),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ProfileHeader(snapshot.data!);
                  },
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firebaseFirestore.collection('posts').where('uid', isEqualTo: widget.uid).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SliverToBoxAdapter(
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  postLength = snapshot.data!.docs.length;
                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final snap = snapshot.data!.docs[index];
                      final postData = snap.data() as Map<String, dynamic>;
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PostScreen(postData: postData),
                            ),
                          );
                        },
                        child: CachedImage(
                          postData['postImage'],
                        ),
                      );
                    }, childCount: postLength),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget ProfileHeader(Usermodel user) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
                child: ClipOval(
                  child: SizedBox(
                    width: 80.w,
                    height: 80.h,
                    child: CachedImage(user.profile),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 35.w),
                      Text(
                        postLength.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(width: 53.w),
                      Text(
                        user.followers.length.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(width: 70.w),
                      Text(
                        user.following.length.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 30.w),
                      Text(
                        'Posts',
                        style: TextStyle(
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(width: 25.w),
                      Text(
                        'Followers',
                        style: TextStyle(
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(width: 19.w),
                      Text(
                        'Following',
                        style: TextStyle(
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  user.bio,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Visibility(
            visible: !isFollowing,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 13.w),
              child: GestureDetector(
                onTap: () {
                  if (!isYourself) {
                    Firebase_Firestore().toggleFollow(userId: widget.uid);
                    setState(() {
                      isFollowing = true;
                    });
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 30.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isYourself ? Colors.white : Colors.blue,
                    borderRadius: BorderRadius.circular(5.r),
                    border: Border.all(color: isYourself ? Colors.grey.shade400 : Colors.blue),
                  ),
                  child: isYourself
                      ? Text('Edit Your Profile')
                      : Text(
                    'Follow',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: isFollowing,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 13.w),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Firebase_Firestore().toggleFollow(userId: widget.uid);
                        setState(() {
                          isFollowing = false;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 30.h,
                        width: 100.w,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(5.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text('Unfollow'),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      height: 30.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(5.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        'Message',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5.h),
          SizedBox(
            width: double.infinity,
            height: 30.h,
            child: const TabBar(
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              tabs: [
                Icon(Icons.grid_on),
                Icon(Icons.video_collection),
                Icon(Icons.person),
              ],
            ),
          ),
          SizedBox(height: 5.h),
        ],
      ),
    );
  }
}
