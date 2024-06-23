import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/data/firebase_service/firestore.dart';
import 'package:project/data/model/usermodel.dart';
import 'package:project/screen/post_screen.dart';
import 'package:project/util/image_cached.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Usermodel? userModel;
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

  Future<void> getData() async {
    try {
      DocumentSnapshot snap = await _firebaseFirestore.collection('users').doc(widget.uid).get();
      if (snap.exists) {
        setState(() {
          userModel = Usermodel.fromDocument(snap);
          following = (snap.data() as Map<String, dynamic>)['following'] ?? [];
          isFollowing = following.contains(_auth.currentUser!.uid);
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
        ),
        body: userModel == null
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ProfileHeader(userModel!),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firebaseFirestore
                    .collection('posts')
                    .where('uid', isEqualTo: widget.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverToBoxAdapter(
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return SliverToBoxAdapter(
                      child: const Center(child: Text('No posts available')),
                    );
                  }
                  postLength = snapshot.data!.docs.length;
                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final snap = snapshot.data!.docs[index];
                      final postData = snap.data() as Map<String, dynamic>;
                      if (!postData.containsKey('postImage')) {
                        return Container(
                          color: Colors.grey,
                          child: const Center(child: Text('No Image')),
                        );
                      }
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
                      Column(
                        children: [
                          Text(
                            postLength.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                          Text(
                            'Posts',
                            style: TextStyle(
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 30.w),
                      Column(
                        children: [
                          Text(
                            user.followers.length.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                          Text(
                            'Followers',
                            style: TextStyle(
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 30.w),
                      Column(
                        children: [
                          Text(
                            user.following.length.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                          Text(
                            'Following',
                            style: TextStyle(
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
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
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  user.bio,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          if (!isYourself) ...[
            Visibility(
              visible: !isFollowing,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                child: GestureDetector(
                  onTap: () {
                    Firebase_Firestore().toggleFollow(userId: widget.uid);
                    setState(() {
                      isFollowing = true;
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 30.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(5.r),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: const Text(
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
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(5.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Text('Unfollow'),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        height: 30.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(5.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Text(
                          'Message',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 13.w),
              child: GestureDetector(
                onTap: () {
                  // Navigate to Edit Profile screen or handle edit profile
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 30.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.r),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: const Text('Edit Your Profile'),
                ),
              ),
            ),
          ],
          SizedBox(height: 10.h),
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
