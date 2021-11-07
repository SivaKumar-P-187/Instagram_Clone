import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///firebase package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

///font package
import 'package:google_fonts/google_fonts.dart';
import 'package:insta_clone/Json/userJson.dart';

///other class packages
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/HomeScreen/Photo/DisplayImage.dart';
import 'package:insta_clone/HomeScreen/Photo/AddPhoto/AddPhoto.dart';
import 'package:insta_clone/HomeScreen/Story/MainStoryPage.dart';
import 'package:insta_clone/Json/photoJson.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? photoUrl;
  List<String> followingUid = [];
  List<UserPhoto> userPhoto = [];
  List<String> muteUser = [];
  Users? users;
  bool inProcess = false;
  String? myUid;
  RefreshController _refreshController =
      new RefreshController(initialRefresh: false);
  getValue() async {
    if (this.mounted) {
      photoUrl = await SharedPreferencesHelper().getUserPhotoUrl();
      followingUid = (await SharedPreferencesHelper().getUserFollowing())!;
      myUid = await SharedPreferencesHelper().getUserUid();
      muteUser = (await SharedPreferencesHelper().getUserMute())!;
      setState(() {});
      if (followingUid.length > 0) {
        await getFollowingUsersPhotoFireStore();
      }
      setState(() {});
    }
  }

  buildOnLaunch() async {
    await getValue();
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use Load No data()
    await await getFollowingUsersPhotoFireStore();
    if (this.mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    // TODO: implement initState
    buildOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Instagram',
          style: GoogleFonts.satisfy(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).backgroundColor,
            fontSize: 30,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => AddPhoto(
                    isProfile: true,
                  ),
                ),
              );
            },
            child: Icon(
              Icons.add_box_outlined,
              size: 30,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
        ],
      ),
      body: SmartRefresher(
        enablePullDown: true,
        onLoading: _onLoading,
        onRefresh: _onRefresh,
        header: ClassicHeader(),
        controller: _refreshController,
        child: ListView(
          primary: true,
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          children: [
            StoryHomePage(
              followingUid: followingUid,
            ),
            followingUid.length > 0
                ? inProcess == true
                    ? Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : userPhoto.length > 0
                        ? displayPhotoFromFollowingUser()
                        : Container(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                : Container(
                    height: MediaQuery.of(context).size.height / 2,
                    child: Center(
                      child: Text(
                        "Your are not Following any users..",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  displayPhotoFromFollowingUser() {
    return followingUid.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemCount: userPhoto.length,
            itemBuilder: (context, int index) {
              return DisplayImage(
                userPhoto: userPhoto[index],
                state: true,
              );
            },
          )
        : Center(
            child: Container(),
          );
  }

  getFollowingUsersPhotoFireStore() async {
    if (followingUid.length > 0) {
      inProcess = true;
    }
    setState(() {});
    await FirebaseFirestore.instance
        .collection('usersPhoto')
        .where('uid', whereIn: followingUid)
        .get()
        .then((value) {
      userPhoto = [];
      value.docs.forEach(
        (element) async {
          if (!muteUser.contains(element.id)) {
            await FirebaseFirestore.instance
                .collection('usersPhoto')
                .doc(element.id)
                .collection('Photo')
                .get()
                .then((photo) {
              if (mounted) {
                photo.docs.forEach((e) {
                  Map<String, dynamic> document = e.data();
                  userPhoto.add(UserPhoto.fromJson(document));
                  setState(() {});
                });
              }
            }).whenComplete(() async {
              if (mounted) {
                if (userPhoto.length > 0) {
                  userPhoto.shuffle();
                  inProcess = false;
                  setState(() {});
                }
              }
            });
          }
        },
      );
    });
    inProcess = false;
    setState(() {});
  }
}
