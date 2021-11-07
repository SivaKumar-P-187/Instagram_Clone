///To display the reply comment widget

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

///other class package
import 'package:insta_clone/Json/commentJson.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/HomeScreen/Photo/Heart_animating_widget.dart';
import 'package:insta_clone/images.dart';

class ReplyDisplay extends StatefulWidget {
  final Comment comment;
  final Comment replyCommentJson;
  final ValueChanged<Comment> onReplyComment;
  final ValueChanged<Comment> isReplyComment;
  const ReplyDisplay({
    Key? key,
    required this.comment,
    required this.replyCommentJson,
    required this.onReplyComment,
    required this.isReplyComment,
  }) : super(key: key);

  @override
  _ReplyDisplayState createState() => _ReplyDisplayState();
}

class _ReplyDisplayState extends State<ReplyDisplay> {
  bool isLiked = false;
  bool isHeartAnimating = false;
  String? myUid;
  FocusNode focusNode = FocusNode();
  Comment? replyComment;
  getValue() async {
    if (this.mounted) {
      myUid = await SharedPreferencesHelper().getUserUid();
      isLiked =
          widget.replyCommentJson.likeUsers!.contains(myUid) ? true : false;
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
      margin: EdgeInsets.only(left: 35.0),
      child: Row(
        children: [
          imageWidget(
            image: widget.replyCommentJson.photoUrl,
            width: 30.toDouble(),
            height: 30.toDouble(),
          ),
          Container(
            width: width - 93,
            padding: EdgeInsets.all(2),
            margin: EdgeInsets.only(right: 5, left: 16, top: 8, bottom: 8),
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

  ///To display reply comment
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
                      '${widget.replyCommentJson.userName} ${widget.replyCommentJson.toUserName} ${widget.replyCommentJson.comment}',
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
                  widget.replyCommentJson.likeUsers!.length > 0
                      ? Text(
                          '${widget.replyCommentJson.likeUsers!.length} likes')
                      : SizedBox.shrink(),
                  SizedBox(
                    width: 25,
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onReplyComment(widget.comment);
                      widget.isReplyComment(widget.replyCommentJson);
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
                        List<Comment>? replyCom = widget.comment.replyComments;
                        for (var e in replyCom!) {
                          if (e.commentId ==
                              widget.replyCommentJson.commentId) {
                            e.likeUsers!.remove(myUid);
                          }
                        }
                        await FirebaseApi()
                            .updateReplyComment(
                          photoUid: widget.comment.photoId,
                          userUid: widget.comment.userUid,
                          commentId: widget.comment.commentId,
                          replyComment: replyCom,
                        )
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
                        List<Comment>? replyCom = widget.comment.replyComments;
                        for (var e in replyCom!) {
                          if (e.commentId ==
                              widget.replyCommentJson.commentId) {
                            e.likeUsers!.add(myUid);
                          }
                        }
                        await FirebaseApi()
                            .updateReplyComment(
                          photoUid: widget.comment.photoId,
                          userUid: widget.comment.userUid,
                          commentId: widget.comment.commentId,
                          replyComment: replyCom,
                        )
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

  ///To build image for reply comment
  imageWidget({String? image, double? height, width}) {
    return ClipOval(
      child: ImagesWidget(image: image, width: width, height: height),
    );
  }
}
