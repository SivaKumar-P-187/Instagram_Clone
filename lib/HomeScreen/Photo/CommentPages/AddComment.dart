///To add comment to particular photo

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///image
import 'package:insta_clone/images.dart';

///random string
import 'package:random_string/random_string.dart';

///other class packages
import 'package:insta_clone/Json/commentJson.dart';
import 'package:insta_clone/Json/photoJson.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/HomeScreen/Photo/CommentPages/ReplyComment.dart';

class AddComment extends StatefulWidget {
  final FocusNode focusNode;
  final UserPhoto userPhoto;
  final Comment? replyComment;
  final VoidCallback onCancelReply;
  final Comment? comment;
  const AddComment({
    Key? key,
    required this.focusNode,
    required this.userPhoto,
    required this.replyComment,
    required this.onCancelReply,
    @required this.comment,
  }) : super(key: key);

  @override
  _AddCommentState createState() => _AddCommentState();
}

class _AddCommentState extends State<AddComment> {
  TextEditingController commentController = TextEditingController();
  String? myDisplayName;
  String? uid;
  String? profileUrl;
  getValue() async {
    if (this.mounted) {
      myDisplayName = await SharedPreferencesHelper().getUserDisplayName();
      uid = await SharedPreferencesHelper().getUserPhotoUrl();
      profileUrl = await SharedPreferencesHelper().getUserPhotoUrl();
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
    final isReplying = widget.replyComment != null;
    setState(() {});
    return Column(
      children: [
        Container(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.symmetric(
              horizontal: 5,
            ),
            child: Row(
              children: [
                imageWidget(
                  height: 40.toDouble(),
                  width: 40.toDouble(),
                  image: widget.userPhoto.profilePhotoUrl,
                ),
                SizedBox(
                  width: 5.0,
                ),
                Expanded(
                  child: Column(
                    children: [
                      if (isReplying) buildReply(),
                      TextField(
                        focusNode: widget.focusNode,
                        textCapitalization: TextCapitalization.sentences,
                        autocorrect: true,
                        enableSuggestions: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.only(
                              topRight: isReplying
                                  ? Radius.zero
                                  : Radius.circular(24),
                              topLeft: isReplying
                                  ? Radius.zero
                                  : Radius.circular(24),
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).scaffoldBackgroundColor ==
                                      Colors.white
                                  ? isReplying
                                      ? Colors.white
                                      : Colors.grey[100]
                                  : Colors.black26,
                          hintText: 'Add a comment...',
                        ),
                        controller: commentController,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                GestureDetector(
                  onTap: () {
                    addComment();
                  },
                  child: Text(
                    'Post',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  ///To build a reply comment widget
  Widget buildReply() => Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: ReplyComment(
          comment: widget.replyComment,
          onCancelReply: widget.onCancelReply,
        ),
      );

  ///To add comment to firestore
  addComment() async {
    final isReplying = widget.replyComment != null;
    final isComment = widget.comment != null;
    if (commentController.text != '') {
      String commentText = commentController.text;
      DateTime time = DateTime.now();
      String commentId = randomAlphaNumeric(12);
      String toName = isComment
          ? widget.comment!.userName!
          : isReplying
              ? widget.replyComment!.userName!
              : "";
      final comment = Comment(
        userName: myDisplayName,
        toUserName: toName,
        userUid: widget.userPhoto.userUid,
        photoUrl: profileUrl,
        photoId: widget.userPhoto.docId,
        time: time,
        likeUsers: [],
        comment: commentText,
        commentId: commentId,
        likes: 0,
        replyComments: [],
      );
      Map<String, dynamic> mapData = comment.toJson();
      if (!isReplying) {
        await FirebaseApi()
            .uploadComment(
          userUid: widget.userPhoto.userUid,
          photoUid: widget.userPhoto.docId,
          comment: mapData,
        )
            .whenComplete(() {
          commentController.text = '';
          FocusScope.of(context).unfocus();
          setState(() {});
        });
      } else {
        Comment tempComment = await FirebaseApi().getCommentReplyList(
          userUid: widget.userPhoto.userUid,
          photoUid: widget.userPhoto.docId,
          commentId: widget.replyComment!.commentId,
        );

        List<Comment> replyComments = [];
        if (widget.replyComment!.replyComments!.length > 0) {
          replyComments = tempComment.replyComments!;
          replyComments.add(comment);
        } else {
          replyComments = [comment];
        }
        await FirebaseApi()
            .updateReplyComment(
          photoUid: widget.userPhoto.docId,
          userUid: widget.userPhoto.userUid,
          commentId: widget.replyComment!.commentId,
          replyComment: replyComments,
        )
            .whenComplete(() {
          FocusScope.of(context).unfocus();
          widget.onCancelReply();
          commentController.text = '';
          setState(() {});
        });
      }
    }
  }

  ///build image of comment user
  imageWidget({String? image, double? height, width}) {
    return ClipOval(
      child: ImagesWidget(image: image, width: width, height: height),
    );
  }
}
