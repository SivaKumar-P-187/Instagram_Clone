import 'package:flutter/material.dart';

///image
import 'package:insta_clone/images.dart';

///story
import 'StoryView/Story_page.dart';

///firebase package
import 'package:cloud_firestore/cloud_firestore.dart';

///other class package
import 'package:insta_clone/HomeScreen/Story/AddStoryPages/StoryPage.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/Profile_Page/ProfileWidget.dart';

class StoryHomePage extends StatefulWidget {
  final List<String>? followingUid;
  const StoryHomePage({@required this.followingUid, Key? key})
      : super(key: key);

  @override
  _StoryHomePageState createState() => _StoryHomePageState();
}

class _StoryHomePageState extends State<StoryHomePage> {
  List<Users>? users1;
  String? myUid;
  List<Users> users2 = [];
  List<String>? muteUser = [];
  String? photoUrl;

  getValue() async {
    if (this.mounted) {
      photoUrl = await SharedPreferencesHelper().getUserPhotoUrl();
      myUid = await SharedPreferencesHelper().getUserUid();
      muteUser = await SharedPreferencesHelper().getUserMute();
      setState(() {});
    }
  }

  buildOnLaunch() async {
    await getValue();
  }

  @override
  void initState() {
    super.initState();
    buildOnLaunch();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.followingUid!.length != 0) {
      return Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        child: displayFollowersStory1(myUid),
      );
    } else {
      return emptyStoryWidget();
    }
  }

  addStatusWidget(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StoryPage(),
                ),
              );
            },
            child: buildCircle(
              child: buildCircle(
                child: Container(
                  height: 70,
                  width: 70,
                  child:
                      photoUrl != null ? imageWidget(photoUrl!) : Container(),
                ),
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
          ),
          Positioned(
              bottom: 0,
              right: 0,
              child: ProfileWidget(
                editingState: false,
                onClicked: () {},
              ).buildEditIcon(context)),
        ],
      ),
    );
  }

  statusViewer(Users users) {
    return buildCircle(
      linear: LinearGradient(colors: [
        Colors.pinkAccent,
        Colors.deepOrange,
        Colors.deepOrangeAccent,
      ]),
      child: buildCircle(
        linear: LinearGradient(colors: [
          Theme.of(context).scaffoldBackgroundColor,
          Theme.of(context).scaffoldBackgroundColor,
        ]),
        child: Container(
          height: 70,
          width: 70,
          child: imageWidget(users.photoUrl),
        ),
        all: 4,
      ),
      all: 2,
    );
  }

  displayFollowersStory1(String? myUid) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('users').doc(myUid).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          final Map<String, dynamic> doc =
              snapshot.data!.data() as Map<String, dynamic>;
          Users users = Users.fromJson(doc);
          return users.followingUid!.isNotEmpty
              ? StreamBuilder<List<Users>>(
                  stream: FirebaseApi().getFollowingStory(users.followingUid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      users1 = snapshot.data;
                      users2 = [];
                      for (var temp in users1!.reversed) {
                        if (!muteUser!.contains(temp.userUid)) {
                          users2.add(temp);
                        }
                      }
                      if (users2.isEmpty) {
                        return emptyStoryWidget();
                      }
                      return users2.length != 0
                          ? ListView.builder(
                              itemCount: users2.length,
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, int index) {
                                return index == 0
                                    ? Row(
                                        children: [
                                          addStatusWidget(context),
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8,
                                                bottom: 8,
                                                left: 2,
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          StoryPageWidget(
                                                        user: users2[index],
                                                        usersList: users2,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child:
                                                    statusViewer(users2[index]),
                                              )),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                              bottom: 8,
                                              left: 2,
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        StoryPageWidget(
                                                      user: users2[index],
                                                      usersList: users2,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child:
                                                  statusViewer(users2[index]),
                                            ),
                                          ),
                                        ],
                                      );
                              },
                            )
                          : emptyStoryWidget();
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                )
              : emptyStoryWidget();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  emptyStoryWidget() {
    return Container(
      width: 70,
      child: Row(
        children: [
          addStatusWidget(context),
          SizedBox(
            width: 25,
          ),
          Expanded(
            child: Container(
              child: Center(
                child: Text(
                  "YOUR FOLLOWING USERS NOT ADDED STORIES",
                  style: Theme.of(context).textTheme.headline3,
                ),
              ),
            ),
          )
        ],
      ),
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

  imageWidget(String? image) {
    return ClipOval(
      child: ImagesWidget(image: image, width: 50.0, height: 50.0),
    );
  }
}
