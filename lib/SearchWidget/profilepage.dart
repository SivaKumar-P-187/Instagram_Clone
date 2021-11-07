import 'package:flutter/material.dart';

///firebase package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insta_clone/HomeScreen/Photo/SearchWidget.dart';
import 'package:insta_clone/HomeScreen/Story/StoryView/Story_page.dart';

///other class package
import 'package:insta_clone/Json/photoJson.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/Profile_Page/images.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/images.dart';

class ProfilePage extends StatefulWidget {
  final String? displayName;
  final String? userUid;
  final String? myUid;
  const ProfilePage({
    required this.displayName,
    this.userUid,
    this.myUid,
    Key? key,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String>? following = [];
  List<dynamic> followers = [];
  List<UserPhoto> userPhoto = [];
  bool isLoading = false;

  getValue() async {
    if (this.mounted) {
      following = await SharedPreferencesHelper().getUserFollowing();
      setState(() {});
    }
  }

  buildOnLaunch() async {
    await getValue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: BackButton(),
        title: widget.displayName != null
            ? Text(
                widget.displayName!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              )
            : Text(''),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.more_vert,
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userUid)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> tempMap =
                snapshot.data!.data() as Map<String, dynamic>;
            Users temp = Users.fromJson(tempMap);
            return ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      temp.story!.length > 0 &&
                              temp.followerUid!.contains(widget.myUid)
                          ? GestureDetector(
                              onTap: () {
                                List<Users> usersList = [temp];
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => StoryPageWidget(
                                        user: temp, usersList: usersList),
                                  ),
                                );
                              },
                              child: buildCircle(
                                child: buildCircle(
                                  child: imageWidget(
                                      image: temp.photoUrl!,
                                      height: 90.toDouble(),
                                      width: 90.toDouble()),
                                  all: 4,
                                  linear: LinearGradient(
                                    colors: [
                                      Theme.of(context).scaffoldBackgroundColor,
                                      Theme.of(context).scaffoldBackgroundColor,
                                    ],
                                  ),
                                ),
                                all: 2,
                                linear: LinearGradient(
                                  colors: [
                                    Colors.pinkAccent,
                                    Colors.deepOrange,
                                    Colors.deepOrangeAccent,
                                  ],
                                ),
                              ),
                            )
                          : imageWidget(
                              image: temp.photoUrl!,
                              height: 90.toDouble(),
                              width: 90.toDouble()),
                      buildNumberWidget(temp),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: temp.userName != null
                      ? Text(
                          temp.userName!,
                          style: Theme.of(context).textTheme.headline2,
                        )
                      : Text(''),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: temp.about != null
                      ? Text(
                          temp.about!,
                          maxLines: 5,
                          overflow: TextOverflow.clip,
                          style: Theme.of(context).textTheme.headline3,
                        )
                      : Text(''),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: isLoading
                      ? MaterialButton(
                          onPressed: () {},
                          padding: EdgeInsets.all(5),
                          color: Colors.redAccent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              const SizedBox(
                                width: 24,
                              ),
                              Text('Please Wait...')
                            ],
                          ),
                        )
                      : temp.followerUid!.contains(widget.myUid)
                          ? MaterialButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: BorderSide(color: Colors.grey, width: 2),
                              ),
                              padding: EdgeInsets.only(left: 120, right: 120),
                              onPressed: () async {
                                isLoading = true;
                                setState(() {});
                                following = await SharedPreferencesHelper()
                                    .getUserFollowing();
                                followers = temp.followerUid!;
                                following!.remove(widget.userUid.toString());
                                await SharedPreferencesHelper()
                                    .setUserFollowing(following);
                                await FirebaseApi().addFollowingList(
                                    widget.myUid!,
                                    following!,
                                    following!.length);
                                followers.remove(widget.myUid!.toString());
                                await FirebaseApi().addFollowersList(
                                    widget.userUid!,
                                    followers,
                                    followers.length);
                                following = await SharedPreferencesHelper()
                                    .getUserFollowing();
                                setState(() {});
                                isLoading = false;
                                setState(() {});
                              },
                              child: Text('UnFollow'),
                            )
                          : MaterialButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              color: Colors.blue,
                              padding: EdgeInsets.only(left: 120, right: 120),
                              onPressed: () async {
                                isLoading = true;
                                setState(() {});
                                following = await SharedPreferencesHelper()
                                    .getUserFollowing();
                                followers = temp.followerUid!;
                                following!.add(widget.userUid.toString());
                                await SharedPreferencesHelper()
                                    .setUserFollowing(following);
                                await FirebaseApi().addFollowingList(
                                    widget.myUid!,
                                    following!,
                                    following!.length);
                                followers.add(widget.myUid!.toString());
                                await FirebaseApi().addFollowersList(
                                    widget.userUid!,
                                    followers,
                                    followers.length);
                                following = await SharedPreferencesHelper()
                                    .getUserFollowing();
                                setState(() {});
                                isLoading = false;
                                setState(() {});
                              },
                              child: Text(
                                'Follow',
                              ),
                            ),
                ),
                Photos(
                  photo: userPhoto,
                  userUid: widget.userUid,
                ),
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  ///to display details like post,follower,following
  Widget buildNumberWidget(Users users) {
    return IntrinsicHeight(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: buildNumber(
                users.post.toString(),
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
                          usersUid: users.followerUid!,
                          title: "Followers Users"),
                    ),
                  );
                },
                child: buildNumber(
                  (users.followers).toString(),
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
                          usersUid: users.followingUid!,
                          title: "Following Users"),
                    ),
                  );
                },
                child: buildNumber(
                  users.following.toString(),
                  'Following',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///build the number and text field
  Widget buildNumber(String no, String name) {
    return Column(
      children: [
        Text(no, style: Theme.of(context).textTheme.headline2),
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

  Widget buildCircle({
    required Widget child,
    required double all,
    required LinearGradient linear,
  }) {
    return ClipRRect(
      child: Container(
        padding: EdgeInsets.all(all),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: linear,
        ),
        child: child,
      ),
    );
  }

  imageWidget({String? image, double? height, double? width}) {
    return ClipOval(
      child: ImagesWidget(image: image, width: width, height: height),
    );
  }
}
