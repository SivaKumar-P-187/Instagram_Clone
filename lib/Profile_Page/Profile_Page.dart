import 'package:flutter/material.dart';

///firebase package
import 'package:cloud_firestore/cloud_firestore.dart';

///image
import 'package:insta_clone/HomeScreen/Photo/SearchWidget.dart';

///other class packages
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/Json/photoJson.dart';
import 'package:insta_clone/HomeScreen/Photo/AddPhoto/AddPhoto.dart';
import 'package:insta_clone/Profile_Page/images.dart';
import 'package:insta_clone/MainHomeScreen.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/Profile_Page/editing_profile.dart';
import 'package:insta_clone/images.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? userName;
  String? userUid;
  String? displayName;
  String? photoUrl;
  Users? users;
  String? userAbout;
  List<UserPhoto> userPhoto = [];
  Map<String, dynamic>? documentData;

  ///to get value of current user from shared preference
  getCurrentUserValue() async {
    if (this.mounted) {
      userName = await SharedPreferencesHelper().getUserName();
      displayName = await SharedPreferencesHelper().getUserDisplayName();
      userUid = await SharedPreferencesHelper().getUserUid();
      photoUrl = await SharedPreferencesHelper().getUserPhotoUrl();
      userAbout = await SharedPreferencesHelper().getUserAbout();
      setState(() {});
    }
  }

  getUserDetails() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userUid!)
        .get()
        .then((value) {
      if (value.exists) {
        documentData = value.data() as Map<String, dynamic>;
        users = Users.fromJson(documentData!);
        setState(() {});
      }
    });
    await FirebaseFirestore.instance
        .collection('usersPhoto')
        .doc(userUid)
        .collection('Photo')
        .get()
        .then((photo) {
      photo.docs.forEach((e) {
        Map<String, dynamic> document = e.data();
        userPhoto.add(UserPhoto.fromJson(document));
        setState(() {});
      });
    }).whenComplete(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    buildOnLaunch();
    setState(() {});
    super.initState();
  }

  ///build on launch on page launch
  buildOnLaunch() async {
    await getCurrentUserValue();
    await getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: BackButton(
          color: Theme.of(context).backgroundColor,
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MainHomeScreen(
                  pageControl: 3,
                ),
              ),
            );
          },
        ),
        title: displayName != null
            ? Text(
                displayName!,
                style: Theme.of(context).textTheme.headline2,
              )
            : Text(''),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => AddPhoto(
                    isProfile: false,
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.add_box_outlined,
              color: Theme.of(context).backgroundColor,
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        primary: false,
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                photoUrl != null
                    ? imageWidget(
                        image: photoUrl,
                        height: 100.toDouble(),
                        width: 100.toDouble(),
                      )
                    : CircleAvatar(
                        maxRadius: 40,
                        child: Container(
                          color: Colors.grey,
                        ),
                      ),
                buildNumberWidget(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: userName != null
                ? Text(
                    userName!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  )
                : Text(''),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: userAbout != null
                ? Text(
                    userAbout!,
                    maxLines: 5,
                    overflow: TextOverflow.clip,
                    style: TextStyle(fontSize: 20.0),
                  )
                : Text(''),
          ),
          SizedBox(
            height: 10.0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: MaterialButton(
              padding: EdgeInsets.only(left: 120, right: 120),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditProfile(),
                  ),
                );
              },
              color: Colors.blue,
              child: Text('Edit profile'),
            ),
          ),
          Photos(
            photo: userPhoto,
            userUid: userUid,
          ),
        ],
      ),
    );
  }

  ///to display profile photo of current user
  imageWidget({String? image, double? height, double? width}) {
    return ClipOval(
        child: ImagesWidget(image: image, width: width, height: height));
  }

  ///to display post,follower and following count
  Widget buildNumberWidget() {
    return IntrinsicHeight(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: users != null
            ? Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: buildNumber(
                      users!.post!.toString(),
                      'Posts',
                    ),
                  ),
                  Container(
                    height: 40,
                    child: VerticalDivider(
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TopScreen(
                                usersUid: users!.followerUid!,
                                title: "Followers Users"),
                          ),
                        );
                      },
                      child: buildNumber(
                        users!.followers!.toString(),
                        'Followers',
                      ),
                    ),
                  ),
                  Container(
                    height: 40,
                    child: VerticalDivider(
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TopScreen(
                                usersUid: users!.followingUid!,
                                title: "Following Users"),
                          ),
                        );
                      },
                      child: buildNumber(
                        users!.following!.toString(),
                        'Following',
                      ),
                    ),
                  ),
                ],
              )
            : Container(),
      ),
    );
  }

  ///to display value of post,followers,and following count
  Widget buildNumber(String no, String name) {
    return Column(
      children: [
        Text(
          no,
          style: Theme.of(context).textTheme.headline2,
        ),
        const SizedBox(
          height: 3.0,
        ),
        Text(
          name,
          style: Theme.of(context).textTheme.headline3,
        ),
      ],
    );
  }
}
