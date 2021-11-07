import 'package:flutter/material.dart';

///firebase package
import 'package:cloud_firestore/cloud_firestore.dart';

///story
import 'package:story_view/story_view.dart';
import 'package:intl/intl.dart';

///other class package
import 'package:insta_clone/Json/StoryJson.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/HomeScreen/Story/StoryView/ProfileWidget.dart';

class StoryWidget extends StatefulWidget {
  final Story? story;
  const StoryWidget({this.story, Key? key}) : super(key: key);

  @override
  _StoryWidgetState createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  StoryController? controller;
  var storyItems = <StoryItem>[];
  String date = '';
  Users? users;
  String? myUser, myUid;

  getValue() async {
    if (this.mounted) {
      myUser = await SharedPreferencesHelper().getUserDisplayName();
      myUid = await SharedPreferencesHelper().getUserUid();
      date = DateFormat.jm()
          .format(
            DateTime.fromMicrosecondsSinceEpoch(
                widget.story!.time!.toUtc().microsecondsSinceEpoch),
          )
          .toString();
      setState(() {});
    }
  }

  buildOnLaunch() async {
    await getValue();
  }

  @override
  void initState() {
    super.initState();
    controller = StoryController();
    buildOnLaunch();
    addStoryItems();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          type: MaterialType.transparency,
          child: StoryView(
            storyItems: storyItems,
            controller: controller!,
            onComplete: handleCompleted,
            onVerticalSwipeComplete: (direction) {
              if (direction == Direction.down) {
                Navigator.pop(context);
              }
            },
            onStoryShow: (storyItem) {
              final index = storyItems.indexOf(storyItem);

              if (index > 0) {
                setState(() {});
              }
            },
          ),
        ),
        StreamBuilder<Users>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(myUid)
                .snapshots()
                .map((event) => Users.fromJson(event.data() ?? {})),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 5,
                    top: 8,
                  ),
                  child: ProfileWidget(
                    user: snapshot.data,
                    date: date,
                    myUser: myUser,
                    story: widget.story,
                    controllerCallback1: playFunction,
                    controllerCallback: stopFunction,
                    context: context,
                  ),
                );
              } else {
                return Container();
              }
            }),
      ],
    );
  }

  void stopFunction() {
    controller!.pause();
  }

  void playFunction() {
    controller!.play();
  }

  void addStoryItems() {
    switch (widget.story!.media) {
      case MediaType.image:
        storyItems.add(StoryItem.pageImage(
          url: widget.story!.url!,
          controller: controller!,
          caption: widget.story!.caption,
          duration: Duration(
            milliseconds: widget.story!.duration! * 1000,
          ),
        ));
        break;
      case MediaType.text:
        storyItems.add(
          StoryItem.text(
            title: widget.story!.caption!,
            backgroundColor: Colors.green,
            duration: Duration(
              milliseconds: widget.story!.duration!,
            ),
          ),
        );
        break;
      case MediaType.video:
        storyItems.add(
          StoryItem.pageVideo(
            widget.story!.url!,
            controller: controller!,
            caption: widget.story!.caption,
            duration: Duration(
              milliseconds: widget.story!.duration! * 10000,
            ),
          ),
        );
        break;
      case null:
        break;
    }
  }

  void handleCompleted() {
    Navigator.of(context).pop();
  }
}
