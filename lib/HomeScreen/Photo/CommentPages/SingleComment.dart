///To display comment

import 'package:flutter/material.dart';

///image
import 'package:insta_clone/images.dart';
import 'package:intl/intl.dart';

///other class packages
import 'package:insta_clone/Json/commentJson.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/HomeScreen/Photo/Heart_animating_widget.dart';

class SingleComment extends StatefulWidget {
  final Comment comment;
  final ValueChanged<Comment> onReplyComment;
  const SingleComment({
    Key? key,
    required this.comment,
    required this.onReplyComment,
  }) : super(key: key);

  @override
  _SingleCommentState createState() => _SingleCommentState();
}

class _SingleCommentState extends State<SingleComment> {
  bool isLiked = false;
  bool isHeartAnimating = false;
  String? myUid;
  FocusNode focusNode = FocusNode();
  Comment? replyComment;
  getValue() async {
    if (this.mounted) {
      myUid = await SharedPreferencesHelper().getUserUid();
      isLiked = widget.comment.likeUsers!.contains(myUid) ? true : false;
      setState(() {});
    }
  }

  buildOnLaunch() async {
    await getValue();
  }

  @override
  void initState() {
    buildOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      child: Row(
        children: [
          imageWidget(
            image: widget.comment.photoUrl,
            width: 30.toDouble(),
            height: 30.toDouble(),
          ),
          Container(
            width: width - 63,
            padding: EdgeInsets.all(2),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor == Colors.white
                  ? Colors.grey[200]
                  : Colors.deepPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: buildCommentWidget(),
          ),
        ],
      ),
    );
  }

  ///to display comment
  buildCommentWidget() {
    DateTime commentTime = DateTime.fromMicrosecondsSinceEpoch(
        widget.comment.time!.microsecondsSinceEpoch);
    String commentTimeHour = DateFormat.H().format(commentTime);
    String commentTimeMinutes = DateFormat.m().format(commentTime);
    DateTime nowTime = DateTime.fromMicrosecondsSinceEpoch(
        DateTime.now().microsecondsSinceEpoch);
    String nowTimeHour = DateFormat.H().format(nowTime);
    String nowTimeMinutes = DateFormat.m().format(nowTime);
    String? displayTime;
    if (nowTimeHour == commentTimeHour) {
      if (int.parse(commentTimeMinutes) == int.parse(nowTimeMinutes)) {
        displayTime = "Just Now";
        setState(() {});
      } else if (int.parse(commentTimeMinutes) > int.parse(nowTimeMinutes)) {
        displayTime =
            (int.parse(commentTimeMinutes) - int.parse(nowTimeMinutes))
                    .toString() +
                'm';
        setState(() {});
      } else {
        displayTime =
            (int.parse(nowTimeMinutes) - int.parse(commentTimeMinutes))
                    .toString() +
                'm';
        setState(() {});
      }
    } else {
      if (int.parse(commentTimeHour) > int.parse(nowTimeHour)) {
        displayTime =
            (int.parse(commentTimeHour) - int.parse(nowTimeHour)).toString() +
                'h';
        setState(() {});
      } else {
        displayTime =
            (int.parse(nowTimeHour) - int.parse(commentTimeHour)).toString() +
                'h';
        setState(() {});
      }
    }
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 8,
                right: 29,
                top: 5,
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${widget.comment.userName}    ${widget.comment.comment}',
                      maxLines: 10,
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 8,
                right: 29,
                top: 5,
                bottom: 10,
              ),
              child: Row(
                children: [
                  Text(displayTime),
                  SizedBox(
                    width: 25,
                  ),
                  widget.comment.likes! > 0
                      ? Text('${widget.comment.likes} likes')
                      : SizedBox.shrink(),
                  SizedBox(
                    width: 25,
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onReplyComment(widget.comment);
                    },
                    child: Text('Reply'),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 10,
          top: 10,
          child: isLiked
              ? HeartAnimatingWidget(
                  child: IconButton(
                      icon: Icon(
                        Icons.favorite,
                        size: 20,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        setState(() {
                          isLiked = !isLiked;
                        });
                        var array = widget.comment.likeUsers;
                        array!.remove(myUid);
                        await FirebaseApi()
                            .updateCommentLikeUsersList(
                                userId: widget.comment.userUid,
                                photoId: widget.comment.photoId,
                                commentId: widget.comment.commentId,
                                array: array)
                            .whenComplete(() async {
                          await FirebaseApi().getSinglePhoto(
                            userId: widget.comment.userUid,
                            photoId: widget.comment.photoId,
                          );
                          focusNode.unfocus();
                          setState(() {});
                        });
                      }),
                  isAnimating: isLiked,
                )
              : HeartAnimatingWidget(
                  child: IconButton(
                      icon: Icon(
                        Icons.favorite_border_outlined,
                        size: 20,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        setState(() {
                          isLiked = !isLiked;
                        });
                        var array = widget.comment.likeUsers;
                        array!.add(myUid);
                        await FirebaseApi()
                            .updateCommentLikeUsersList(
                                userId: widget.comment.userUid,
                                photoId: widget.comment.photoId,
                                commentId: widget.comment.commentId,
                                array: array)
                            .whenComplete(() async {
                          await FirebaseApi().getSinglePhoto(
                            userId: widget.comment.userUid,
                            photoId: widget.comment.photoId,
                          );
                          focusNode.unfocus();
                          setState(() {});
                        });
                      }),
                  isAnimating: isLiked,
                  alwaysAnimate: true,
                ),
        ),
      ],
    );
  }

  ///to display image for comment
  imageWidget({String? image, double? height, width}) {
    return ClipOval(
      child: ImagesWidget(image: image, width: width, height: height),
    );
  }
}
