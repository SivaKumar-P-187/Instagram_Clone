import 'package:flutter/material.dart';

///story
import 'package:story_view/story_view.dart';
import 'package:intl/intl.dart';

///other class package
import 'package:insta_clone/Json/StoryJson.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/HomeScreen/Story/StoryView/ProfileWidget.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/handlers/ErrorHandler.dart';

class StoryWidget extends StatefulWidget {
  final Users? user;
  final List<Users>? usersList;
  final PageController? controller;
  const StoryWidget(
      {@required this.user,
      @required this.controller,
      @required this.usersList,
      Key? key})
      : super(key: key);

  @override
  _StoryWidgetState createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  var storyItems = <StoryItem>[];
  String date = '';
  String? myUser;
  String? myUid;
  Map<String, dynamic>? tempMap;
  StoryController? controller;
  void addStoryItems() {
    storyItems.clear();
    for (final story in widget.user!.story!) {
      switch (story.media) {
        case MediaType.image:
          storyItems.add(StoryItem.pageImage(
            url: story.url!,
            controller: controller!,
            caption: story.caption,
            duration: Duration(
              milliseconds: (story.duration! * 1000).toInt(),
            ),
          ));
          break;
        case MediaType.text:
          storyItems.add(
            StoryItem.text(
              title: story.caption!,
              backgroundColor: Colors.green,
              duration: Duration(
                milliseconds: (story.duration! * 1000).toInt(),
              ),
            ),
          );
          break;
        case MediaType.video:
          storyItems.add(
            StoryItem.pageVideo(
              story.url!,
              controller: controller!,
              caption: story.caption,
              duration: Duration(
                milliseconds: (story.duration! * 1000).toInt(),
              ),
            ),
          );
          break;
        case null:
          break;
      }
    }
  }

  void handleCompleted() {
    widget.controller!.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );

    final currentIndex = widget.usersList!.indexOf(widget.user!);
    final isLastPage = widget.usersList!.length - 1 == currentIndex;

    if (isLastPage) {
      Navigator.of(context).pop();
    }
  }

  getValue() async {
    myUser = await SharedPreferencesHelper().getUserDisplayName();
    myUid = await SharedPreferencesHelper().getUserUid();
    setState(() {});
  }

  buildOnLaunch() async {
    await getValue();
  }

  @override
  void initState() {
    super.initState();
    controller = StoryController();
    addStoryItems();
    buildOnLaunch();
    date = DateFormat.jm()
        .format(
          DateTime.fromMicrosecondsSinceEpoch(
              widget.user!.story![0].time!.toUtc().microsecondsSinceEpoch),
        )
        .toString();
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
            onStoryShow: (storyItem) async {
              final index = storyItems.indexOf(storyItem);
              myUid = await SharedPreferencesHelper().getUserUid();
              Story story = widget.user!.story![index];
              List<Story>? finalStory = [];
              for (var i in widget.user!.story!) {
                List viewList = i.viewList!;
                if (i.url == story.url) {
                  if (!viewList.contains(myUid)) {
                    viewList.add(myUid);
                  }
                }
                final storyInfo = Story(
                  url: i.url,
                  time: i.time,
                  media: MediaType.image,
                  caption: i.caption,
                  duration: 15,
                  viewCount: viewList.length,
                  viewList: viewList,
                ).toJson();
                try {
                  finalStory.add(Story.fromJson(storyInfo));
                } catch (e) {
                  ErrorHandler().errorDialog(context, e);
                }
              }
              await FirebaseApi().updateSingleStory(
                index: index,
                story: finalStory,
                user: widget.user,
              );
              if (index > 0) {
                setState(() {
                  date = DateFormat.jm()
                      .format(
                        DateTime.fromMicrosecondsSinceEpoch(widget
                            .user!.story![index].time!
                            .toUtc()
                            .microsecondsSinceEpoch),
                      )
                      .toString();
                });
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 5,
            top: 8,
          ),
          child: ProfileWidget(
            user: widget.user,
            date: date,
            myUser: myUser,
            controllerCallback: stopFunction,
            controllerCallback1: playFunction,
            context: context,
          ),
        ),
      ],
    );
  }

  void stopFunction() {
    controller!.pause();
  }

  void playFunction() {
    controller!.play();
  }
}
