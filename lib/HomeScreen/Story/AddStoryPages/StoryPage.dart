import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///firebase package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:insta_clone/handlers/ErrorHandler.dart';
import 'package:insta_clone/images.dart';

///provider
import 'package:path_provider/path_provider.dart';

///picker
import 'package:image_picker/image_picker.dart';
import 'dart:io';

///share
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

///animating icon
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

///other class package
import 'package:insta_clone/ChatPages/FavoritePage/FavoriteItem.dart';
import 'package:insta_clone/HomeScreen/Story/AddStoryPages/story_helper.dart';
import 'package:insta_clone/HomeScreen/Story/StoryView/MyStoryWidget.dart';
import 'package:insta_clone/Json/StoryJson.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/handlers/MenuIconHandler.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({Key? key}) : super(key: key);

  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  bool inProcess = false;
  double progress = 0;
  UploadTask? task;
  String? imageUrl;
  String? myDisplay;
  Story? tempStory;
  List<Story>? story = [];
  List<Story>? finalStory;
  String? myUid;

  getValue() async {
    if (this.mounted) {
      myDisplay = await SharedPreferencesHelper().getUserDisplayName();
      myUid = await SharedPreferencesHelper().getUserUid();
      tempStory = await SharedPreferencesHelper().getTempStory();
      finalStory = await SharedPreferencesHelper().getUserStoryFinal();
      setState(() {});
    }
  }

  buildOnLaunch() async {
    await getValue();
    if (this.mounted) {
      if (tempStory != null) {
        await updateStatus();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    buildOnLaunch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Theme.of(context).backgroundColor,
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed('/homePageScreen');
          },
        ),
        title: Text(
          "My Story",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  tempStory != null ? newStory() : Container(),
                  finalStory != null ? finalStoryList() : Container(),
                ],
              ),
              inProcess
                  ? Positioned(
                      top: MediaQuery.of(context).size.height / 2,
                      left: MediaQuery.of(context).size.width / 2,
                      child: CircularProgressIndicator(),
                    )
                  : Container()
            ],
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        curve: Curves.bounceInOut,
        animatedIcon: AnimatedIcons.add_event,
        overlayColor: Colors.black87,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white70,
        animatedIconTheme: IconThemeData.fallback(),
        children: [
          SpeedDialChild(
            child: Icon(Icons.camera_alt_outlined),
            backgroundColor: Colors.blue,
            label: 'Camera',
            onTap: () {
              pickImage(context, ImageSource.camera);
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.photo_album),
            backgroundColor: Colors.blue,
            label: 'Gallery',
            onTap: () {
              pickImage(context, ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Future pickImage(BuildContext context, ImageSource source) async {
    setState(() {
      inProcess = true;
    });
    try {
      final image =
          await ImagePicker().pickImage(source: source, imageQuality: 100);
      if (image == null) {
        setState(() {
          inProcess = false;
        });
        return;
      }
      setState(() {
        inProcess = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryHelper(
            file: File(image.path),
            isStory: true,
            isProfile: false,
          ),
        ),
      );
    } on PlatformException catch (e) {
      ErrorHandler().errorDialog(context, e.message);
    }
  }

  updateStatus() async {
    if (tempStory != null) {
      await uploadStatus();
    }
  }

  uploadImage() async {
    if (tempStory != null) {
      final fileNames = tempStory!.url!.split('/').last;
      final destination = '$myDisplay/$fileNames';
      try {
        final ref = FirebaseStorage.instance.ref(destination);
        task = ref.putFile(File(tempStory!.url!));
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message.toString()),
          ),
        );
      }
      if (task != null) {
        final snapshot = await task!.whenComplete(() {});
        imageUrl = await snapshot.ref.getDownloadURL();
      }
    }
  }

  uploadStatus() async {
    if (tempStory != null) {
      await uploadImage();
      var time = DateTime.now();
      final storyInfo = Story(
        url: imageUrl,
        time: time,
        media: MediaType.image,
        caption: tempStory!.caption,
        duration: 15,
        viewCount: 0,
        viewList: [],
      ).toJson();

      final Story storyJson = Story.fromJson(storyInfo);
      final List<Story>? getStoryList =
          await SharedPreferencesHelper().getUserStoryFinal();
      List<Story>? finalStory1;
      if (getStoryList != null) {
        finalStory1 = getStoryList;
        finalStory1.add(storyJson);
      } else {
        finalStory1 = [storyJson];
      }

      await FirebaseApi().updateStory(myUid!, finalStory1).then((value) async {
        await FirebaseFirestore.instance.collection('users').doc(myUid).update({
          "lastStatusTime": time.toIso8601String(),
        });
        await SharedPreferencesHelper().setUserStoryFinal(finalStory1);
        tempStory = await SharedPreferencesHelper().removeTempStory();
        finalStory = await SharedPreferencesHelper().getUserStoryFinal();
        setState(() {});
      });
      setState(() {});
    }
  }

  buildUploadStatus(UploadTask task) {
    return StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final total = snap.totalBytes;
            double progress = snap.bytesTransferred / snap.totalBytes;
            if (progress == total) {
              setState(() {
                progress = 1;
              });
            }
            return GestureDetector(
              onTap: () async {
                tempStory = await SharedPreferencesHelper().removeTempStory();
                task.cancel();
                setState(() {});
              },
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    valueColor: AlwaysStoppedAnimation(Colors.red),
                    strokeWidth: 3,
                    backgroundColor: Colors.grey.shade500,
                  ),
                  Positioned(
                    top: 5,
                    left: 6,
                    child: Center(
                      child: Icon(Icons.clear),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        });
  }

  newStory() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: storyWidget(story: tempStory, isTemp: true, viewCount: 0),
      ),
    );
  }

  finalStoryList() {
    return new Container(
      child: ScrollConfiguration(
        behavior: MyBehavior(),
        child: StreamBuilder<Users>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(myUid)
                .snapshots()
                .map((event) => Users.fromJson(event.data() ?? {})),
            builder: (context, AsyncSnapshot<Users> snapshot) {
              if (snapshot.hasData) {
                Users? users = snapshot.data;
                story = users!.story;
                return new ListView.builder(
                    shrinkWrap: true,
                    itemCount: finalStory!.length,
                    itemBuilder: (context, int index) {
                      return new Padding(
                        padding: EdgeInsets.only(
                          top: 5,
                          left: 5,
                          right: 8,
                          bottom: 8,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => StoryWidget(
                                  story: finalStory!.elementAt(index),
                                ),
                              ),
                            );
                          },
                          child: storyWidget(
                            story: finalStory!.elementAt(index),
                            viewCount: story![index].viewCount,
                            isTemp: false,
                          ),
                        ),
                      );
                    });
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }

  storyWidget({Story? story, bool? isTemp, int? viewCount}) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              isTemp!
                  ? buildCircle(
                      child: buildCircle(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: FileImage(
                                  File(tempStory!.url!),
                                ), // picked file
                                fit: BoxFit.fill),
                          ),
                        ),
                        all: 2,
                        linear: LinearGradient(colors: [
                          Theme.of(context).scaffoldBackgroundColor,
                          Theme.of(context).scaffoldBackgroundColor,
                        ]),
                      ),
                      all: 2,
                      linear: LinearGradient(colors: [
                        Colors.pinkAccent,
                        Colors.deepOrange,
                        Colors.deepOrangeAccent,
                      ]),
                    )
                  : buildCircle(
                      child: buildCircle(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: ImagesWidget(
                                image: story!.url!, width: 50.0, height: 50.0),
                          ),
                        ),
                        all: 2,
                        linear: LinearGradient(colors: [
                          Theme.of(context).scaffoldBackgroundColor,
                          Theme.of(context).scaffoldBackgroundColor,
                        ]),
                      ),
                      all: 2,
                      linear: LinearGradient(colors: [
                        Colors.green,
                        Colors.lightGreen,
                        Colors.greenAccent,
                      ]),
                    ),
              SizedBox(
                width: 30,
              ),
              Column(
                children: [
                  isTemp
                      ? Text(
                          'Sending ...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        )
                      : Text(
                          '$viewCount views',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                  isTemp
                      ? SizedBox.shrink()
                      : Text(
                          DateFormat.jm()
                              .format(
                                DateTime.fromMicrosecondsSinceEpoch(story!.time!
                                    .toUtc()
                                    .microsecondsSinceEpoch),
                              )
                              .toString(),
                        ),
                ],
              ),
            ],
          ),
          isTemp
              ? task != null
                  ? buildUploadStatus(task!)
                  : CircularProgressIndicator()
              : PopupMenuButton<MenuItem>(
                  onSelected: (item) => onSelected(context, item, story!),
                  itemBuilder: (context) => [
                    ...Menu1.itemFirst.map(buildItem).toList(),
                  ],
                ),
        ],
      ),
    );
  }

  PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem<MenuItem>(
        value: item,
        child: Row(
          children: [
            Icon(
              item.icon,
              color: Colors.black,
            ),
            SizedBox(
              width: 12,
            ),
            Text(item.title),
          ],
        ),
      );

  void onSelected(BuildContext context, MenuItem item, Story story) {
    switch (item) {
      case Menu1.deleteStory:
        removeStory(story);
        break;
      case Menu1.shareStory:
        shareStory(story);
        break;
    }
  }

  removeStory(Story story) async {
    finalStory!.remove(story);
    setState(() {});
    await SharedPreferencesHelper().setUserStoryFinal(finalStory);
    await FirebaseApi().updateStory(myUid!, finalStory!);
  }

  shareStory(Story story) async {
    final url = Uri.parse(story.url!);
    final response = await http.get(url);
    final bytes = response.bodyBytes;
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/image.jpg';
    File(path).writeAsBytesSync(bytes);
    await Share.shareFiles(
      [path],
      text: story.caption!,
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
}
