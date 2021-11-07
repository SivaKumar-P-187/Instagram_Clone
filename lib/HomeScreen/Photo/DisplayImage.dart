///To display image

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///image
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:insta_clone/HomeScreen/Photo/SearchWidget.dart';
import 'package:insta_clone/HomeScreen/Story/StoryView/Story_page.dart';
import 'package:insta_clone/Json/SaveImageJson.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/SearchWidget/profilepage.dart';

///provider
import 'package:path_provider/path_provider.dart';

///font
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

///share
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

///other class package
import 'package:insta_clone/Json/photoJson.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/HomeScreen/Photo/Heart_animating_widget.dart';
import 'package:insta_clone/HomeScreen/Photo/CommentPages/CommentPage.dart';
import 'package:insta_clone/handlers/ErrorHandler.dart';

class DisplayImage extends StatefulWidget {
  final UserPhoto userPhoto;
  final bool state;
  const DisplayImage({
    required this.userPhoto,
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  _DisplayImageState createState() => _DisplayImageState();
}

class _DisplayImageState extends State<DisplayImage>
    with SingleTickerProviderStateMixin {
  String? myUid;
  String? myName;
  FocusNode focusNode = FocusNode();
  UserPhoto? userPhoto;
  Users? users;
  Users? photoUser;
  bool isSaved = false;
  List<String>? following = [];
  bool isLiked = false;
  List<String> likeFollow = [];
  List<String>? muteUser = [];
  List<SaveImageJson>? savedImage = [];
  bool isHeartAnimating = false;
  late TransformationController controller;
  late AnimationController animationController;
  double scale = 1;
  Animation<Matrix4>? animation;
  final double minScale = 1;
  final double maxScale = 4;
  OverlayEntry? entry;
  var len = 0;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  static final customCacheManager = CacheManager(
    Config(
      'customCacheKey',
      stalePeriod: Duration(
        days: 15,
      ),
      maxNrOfCacheObjects: 100,
    ),
  );
  getValue() async {
    if (this.mounted) {
      userPhoto = widget.userPhoto;
      myUid = await SharedPreferencesHelper().getUserUid();
      myName = await SharedPreferencesHelper().getUserDisplayName();
      following = await SharedPreferencesHelper().getUserFollowing();
      muteUser = await SharedPreferencesHelper().getUserMute();
      isLiked = userPhoto!.likeUsers!.contains(myUid) ? true : false;
      savedImage = await SharedPreferencesHelper().getSaveImage();
      isSaved = userPhoto!.savedUser!.contains(myUid) ? true : false;
      setState(() {});
      List<String> likeFollow = [];
      following!.forEach((element) {
        if (userPhoto!.likeUsers!.contains(element)) {
          likeFollow.add(element);
        }
      });
      String? ran;
      if (likeFollow.length > 0) {
        ran = likeFollow[Random().nextInt(likeFollow.length)];
        var tempVar =
            await FirebaseFirestore.instance.collection('users').doc(ran).get();
        Map<String, dynamic>? tempMap = tempVar.data();
        users = Users.fromJson(tempMap!);
        setState(() {});
      }
      var temp = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userPhoto.userUid)
          .get();
      Map<String, dynamic>? tempMap = temp.data();
      photoUser = Users.fromJson(tempMap!);
      len = photoUser?.story?.length ?? 0;
      setState(() {});
    }
  }

  buildOnLaunch() async {
    await getValue();
  }

  @override
  void initState() {
    // TODO: implement initState
    buildOnLaunch();
    super.initState();
    controller = TransformationController();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    )
      ..addListener(() => controller.value = animation!.value)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          removeOverlay();
        }
      });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return following!.contains(userPhoto!.userUid.toString())
        ? Column(
            children: [
              displayProfileDisplay(userPhoto!),
              displayImage(),
              buttonsWidget(userPhoto!),
            ],
          )
        : SizedBox.shrink();
  }

  ///To display main image
  imageRect({String? image, double? height, width}) {
    return ClipRRect(
      child: finalImage(
          image: image, height: height, width: width, isLoading: true),
    );
  }

  ///To display main image
  displayImage() {
    return GestureDetector(
      onDoubleTap: () async {
        setState(() {
          isHeartAnimating = true;
          isLiked = true;
        });
        if (!userPhoto!.likeUsers!.contains(myUid)) {
          userPhoto!.likeUsers!.add(myUid);
          setState(() {});
          await FirebaseApi().updateLikeList(
            userPhoto!.userUid!,
            userPhoto!.docId!,
            userPhoto!.likeUsers!,
          );
        }
      },
      child: buildImage(),
    );
  }

  ///to display with animation
  buildImage() {
    return Builder(builder: (context) {
      return InteractiveViewer(
        transformationController: controller,
        clipBehavior: Clip.none,
        panEnabled: false,
        minScale: minScale,
        maxScale: maxScale,
        onInteractionStart: (details) {
          if (details.pointerCount < 2) return;
          showOverlay(context);
        },
        onInteractionUpdate: (details) {
          if (entry != null) {
            this.scale = details.scale;
            entry!.markNeedsBuild();
          }
        },
        onInteractionEnd: (details) {
          resetAnimation();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: imageRect(
                  image: userPhoto!.imagePhotoUrl,
                  height: 300.toDouble(),
                  width: MediaQuery.of(context).size.width),
            ),
            Opacity(
              opacity: isHeartAnimating ? 1 : 0,
              child: HeartAnimatingWidget(
                child: Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 100,
                ),
                isAnimating: isHeartAnimating,
                duration: Duration(milliseconds: 700),
                onEnd: () => setState(() => isHeartAnimating = false),
              ),
            ),
          ],
        ),
      );
    });
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

  ///to display profile widget of photo
  displayProfileDisplay(UserPhoto? userPhoto) {
    if (userPhoto != null) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProfilePage(
                displayName: userPhoto.userName,
                userUid: userPhoto.userUid,
                myUid: myUid!,
              ),
            ),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    len > 0
                        ? GestureDetector(
                            onTap: () {
                              List<Users> usersList = [photoUser!];
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => StoryPageWidget(
                                      user: photoUser, usersList: usersList),
                                ),
                              );
                            },
                            child: buildCircle(
                              child: buildCircle(
                                child: imageWidget(
                                  image: userPhoto.profilePhotoUrl!,
                                  height: 50.toDouble(),
                                  width: 50.toDouble(),
                                ),
                                all: 2,
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
                            image: userPhoto.profilePhotoUrl!,
                            height: 50.toDouble(),
                            width: 50.toDouble(),
                          ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      userPhoto.userName!,
                      style: Theme.of(context).textTheme.headline2,
                    ),
                  ],
                ),
                widget.state
                    ? GestureDetector(
                        onTap: () {
                          buildBottomSheet(userPhoto);
                        },
                        child: Icon(
                          Icons.more_vert,
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      );
    }
  }

  ///To build bottom sheet for photo
  buildBottomSheet(UserPhoto userPhoto) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: new Icon(Icons.delete),
                title: new Text('UnFollow'),
                onTap: () async {
                  await buildUnFollowWidget(userPhoto);
                },
              ),
              !muteUser!.contains(userPhoto.userUid)
                  ? ListTile(
                      leading: new Icon(Icons.volume_mute),
                      title: new Text('Mute'),
                      onTap: () async {
                        await buildMuteWidget(userPhoto);
                      },
                    )
                  : ListTile(
                      leading: new Icon(Icons.volume_up),
                      title: new Text('UnMute'),
                      onTap: () async {
                        await buildUnMuteWidget(userPhoto);
                      },
                    ),
            ],
          );
        });
  }

  ///to animate the zoom for center image
  void showOverlay(BuildContext context) {
    final renderBox = context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = MediaQuery.of(context).size;
    entry = OverlayEntry(
      builder: (context) {
        final opacity = ((scale - 1) / (maxScale - 1)).clamp(0.0, 1.0);
        return Stack(
          children: [
            Positioned.fill(
                child: Opacity(
              opacity: opacity,
              child: Container(
                color: Colors.black,
              ),
            )),
            Positioned(
              left: offset.dx,
              top: offset.dy,
              width: size.width,
              child: buildImage(),
            ),
          ],
        );
      },
    );
    final overlay = Overlay.of(context)!;
    overlay.insert(entry!);
  }

  ///to reset the zoom animation of center image
  void resetAnimation() {
    animation = Matrix4Tween(begin: controller.value, end: Matrix4.identity())
        .animate(CurvedAnimation(
            parent: animationController, curve: Curves.easeInOut));
    animationController.forward(from: 0);
  }

  void removeOverlay() {
    entry?.remove();
    entry = null;
  }

  ///has to be update the following list
  buildUnFollowWidget(UserPhoto userPhotos) async {
    Dialogs.showLoadingDialog(context, _keyLoader);
    List<dynamic>? followers = [];
    Map<String, dynamic>? temp;
    var value = await FirebaseFirestore.instance
        .collection('users')
        .doc(userPhotos.userUid)
        .get();
    temp = value.data();
    Users users = Users.fromJson(temp!);
    followers = users.followerUid;
    following!.remove(userPhotos.userUid.toString());
    await SharedPreferencesHelper().setUserFollowing(following);
    following = await SharedPreferencesHelper().getUserFollowing();
    await FirebaseApi().addFollowingList(myUid!, following!, following!.length);
    if (followers != null) {
      followers.remove(myUid);
      await FirebaseApi()
          .addFollowersList(userPhotos.userUid!, followers, followers.length);
    }
    setState(() {});
    Navigator.pop(context);
    Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
  }

  ///To update mute list of current user
  buildMuteWidget(UserPhoto userPhoto) async {
    Dialogs.showLoadingDialog(context, _keyLoader);
    List<String>? muteArray = await SharedPreferencesHelper().getUserMute();
    muteArray!.add(userPhoto.userUid!);
    await SharedPreferencesHelper().setUserMute(muteArray);
    await FirebaseApi().updateUserMuteList(myUid: myUid, muteList: muteArray);
    muteUser = await SharedPreferencesHelper().getUserMute();
    following = await SharedPreferencesHelper().getUserFollowing();
    setState(() {});
    Navigator.pop(context);
    Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
  }

  buildUnMuteWidget(UserPhoto userPhoto) async {
    Dialogs.showLoadingDialog(context, _keyLoader);
    List<String>? muteArray = await SharedPreferencesHelper().getUserMute();
    muteArray!.remove(userPhoto.userUid!);
    await SharedPreferencesHelper().setUserMute(muteArray);
    await FirebaseApi().updateUserMuteList(myUid: myUid, muteList: muteArray);
    muteUser = await SharedPreferencesHelper().getUserMute();
    setState(() {});
    Navigator.pop(context);
    Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
  }

  ///to display icons for like comment
  buttonsWidget(UserPhoto userPhoto) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    isLiked
                        ? HeartAnimatingWidget(
                            child: IconButton(
                                icon: Icon(
                                  Icons.favorite,
                                  size: 30,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  setState(() {
                                    isLiked = !isLiked;
                                  });
                                  userPhoto.likeUsers!.remove(myUid);
                                  setState(() {});
                                  await FirebaseApi().updateLikeList(
                                    userPhoto.userUid!,
                                    userPhoto.docId!,
                                    userPhoto.likeUsers!,
                                  );
                                }),
                            isAnimating: isLiked,
                          )
                        : HeartAnimatingWidget(
                            child: IconButton(
                                icon: Icon(
                                  Icons.favorite_border_outlined,
                                  size: 30,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                                onPressed: () async {
                                  setState(() {
                                    isLiked = !isLiked;
                                  });
                                  userPhoto.likeUsers!.add(myUid);
                                  setState(() {});
                                  await FirebaseApi().updateLikeList(
                                    userPhoto.userUid!,
                                    userPhoto.docId!,
                                    userPhoto.likeUsers!,
                                  );
                                }),
                            isAnimating: isLiked,
                            alwaysAnimate: true,
                          ),
                    GestureDetector(
                      onTap: () {
                        focusNode.requestFocus();
                        setState(() {});
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CommentPage(
                              focusNode: focusNode,
                              userPhoto: userPhoto,
                            ),
                          ),
                        );
                      },
                      child: FaIcon(
                        FontAwesomeIcons.comment,
                        size: 30,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () async {
                        Dialogs.showLoadingDialog(context, _keyLoader);
                        final url = Uri.parse(userPhoto.imagePhotoUrl!);
                        final response = await http.get(url);
                        final bytes = response.bodyBytes;
                        final temp = await getTemporaryDirectory();
                        final path = '${temp.path}/image.jpg';
                        File(path).writeAsBytesSync(bytes);
                        Navigator.of(_keyLoader.currentContext!,
                                rootNavigator: true)
                            .pop();
                        await Share.shareFiles(
                          [path],
                          text: userPhoto.caption!,
                        );
                      },
                      child: FaIcon(
                        FontAwesomeIcons.telegramPlane,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                !isSaved
                    ? HeartAnimatingWidget(
                        child: IconButton(
                          onPressed: () async {
                            setState(() {
                              isSaved = !isSaved;
                            });
                            List<SaveImageJson>? photo =
                                await SharedPreferencesHelper().getSaveImage();
                            if (!photo!.isEmpty) {
                              final save = await SaveImageJson(
                                  userUid: userPhoto.userUid,
                                  docId: userPhoto.docId);
                              photo.add(save);
                            } else {
                              final save = await SaveImageJson(
                                  userUid: userPhoto.userUid,
                                  docId: userPhoto.docId);
                              photo = [save];
                            }
                            List<dynamic>? usersList = userPhoto.savedUser;
                            usersList!.add(myUid);
                            await FirebaseApi().setSaveImage(
                                uid: userPhoto.userUid,
                                docId: userPhoto.docId,
                                saveUser: usersList);
                            await SharedPreferencesHelper().saveImage(photo);
                            savedImage =
                                await SharedPreferencesHelper().getSaveImage();
                            await FirebaseApi()
                                .addSaveImage(myUid!, savedImage!);
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.turned_in_not_outlined,
                            size: 30,
                            color: Theme.of(context).backgroundColor,
                          ),
                        ),
                        isAnimating: isSaved,
                        alwaysAnimate: true,
                      )
                    : HeartAnimatingWidget(
                        child: IconButton(
                          onPressed: () async {
                            setState(() {
                              isSaved = !isSaved;
                            });
                            List<SaveImageJson>? photo =
                                await SharedPreferencesHelper().getSaveImage();
                            List<SaveImageJson>? save = [];
                            photo!.forEach((element) {
                              if (element.docId != userPhoto.docId) {
                                save.add(element);
                              }
                            });
                            List<dynamic>? usersList = userPhoto.savedUser;
                            usersList!.remove(myUid);
                            await FirebaseApi().setSaveImage(
                                uid: userPhoto.userUid,
                                docId: userPhoto.docId,
                                saveUser: usersList);
                            await SharedPreferencesHelper().saveImage(save);
                            savedImage =
                                await SharedPreferencesHelper().getSaveImage();
                            await FirebaseApi()
                                .addSaveImage(myUid!, savedImage!);
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.turned_in,
                            size: 30,
                          ),
                        ),
                        isAnimating: isSaved,
                      ),
              ],
            ),
            users != null
                ? Row(
                    children: [
                      Text(
                        "Likes by ",
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                userUid: users!.userUid,
                                displayName: users!.displayName,
                                myUid: myUid,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "${users!.displayName}",
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                      userPhoto.likeUsers!.length > 1
                          ? Text(
                              "and ",
                              style: Theme.of(context).textTheme.headline3,
                            )
                          : SizedBox.shrink(),
                      userPhoto.likeUsers!.length > 1
                          ? GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TopScreen(
                                        usersUid: userPhoto.likeUsers!,
                                        title: "Liked Users"),
                                  ),
                                );
                              },
                              child: Text(
                                "${userPhoto.likeUsers!.length - 1} others",
                                style: Theme.of(context).textTheme.headline3,
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  )
                : userPhoto.likeUsers!.length > 0
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TopScreen(
                                      usersUid: userPhoto.likeUsers!,
                                      title: "Liked Users",
                                    )),
                          );
                        },
                        child: Text(
                          'Liked by ${userPhoto.likeUsers!.length} others',
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      )
                    : SizedBox.shrink(),
            SizedBox(
              height: 5,
            ),
            Text(
              "${userPhoto.userName}  ${userPhoto.caption}",
              overflow: TextOverflow.clip,
              style: Theme.of(context).textTheme.headline3,
            ),
            TextButton(
              onPressed: () {
                focusNode.unfocus();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommentPage(
                      focusNode: focusNode,
                      userPhoto: userPhoto,
                    ),
                  ),
                );
              },
              child: Text(
                'View all comment',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            SizedBox(
              width: 5,
            ),
          ],
        ),
      ),
    );
  }

  ///to display image
  finalImage({String? image, double? height, width, bool? isLoading}) {
    return CachedNetworkImage(
      imageUrl: (image!),
      height: height,
      width: width,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      fit: BoxFit.cover,
      cacheManager: customCacheManager,
      placeholder: (context, url) => ClipRRect(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: isLoading == true
              ? Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    margin: const EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Theme.of(context).backgroundColor,
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ),
      ),
      errorWidget: (context, url, error) => ClipRRect(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: isLoading == true
              ? Center(
                  child: Text("Couldn't load image."),
                )
              : SizedBox.shrink(),
        ),
      ),
    );
  }

  imageWidget({String? image, double? height, width}) {
    return ClipOval(
      child: finalImage(
          image: image, height: height, width: width, isLoading: false),
    );
  }
}
