import 'package:flutter/material.dart';

///other class package
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/HomeScreen/Story/StoryView/Story_Widget.dart';

class StoryPageWidget extends StatefulWidget {
  final Users? user;
  final List<Users>? usersList;
  const StoryPageWidget(
      {@required this.user, @required this.usersList, Key? key})
      : super(key: key);

  @override
  _StoryPageWidgetState createState() => _StoryPageWidgetState();
}

class _StoryPageWidgetState extends State<StoryPageWidget> {
  PageController? controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final initialPage = widget.usersList!.indexOf(widget.user!);
    controller = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: controller,
      children: widget.usersList!
          .map(
            (user) => StoryWidget(
              user: user,
              controller: controller,
              usersList: widget.usersList,
            ),
          )
          .toList(),
    );
  }
}
