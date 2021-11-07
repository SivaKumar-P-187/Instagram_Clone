///Home page for particular comment room

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///other class package
import 'package:insta_clone/Json/commentJson.dart';
import 'package:insta_clone/Json/photoJson.dart';
import 'package:insta_clone/HomeScreen/Photo/CommentPages/AddComment.dart';
import 'package:insta_clone/HomeScreen/Photo/CommentPages/Comments.dart';

class CommentPage extends StatefulWidget {
  final UserPhoto userPhoto;
  final FocusNode focusNode;
  const CommentPage({
    Key? key,
    required this.userPhoto,
    required this.focusNode,
  }) : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  Comment? replyComment;
  Comment? isReplyComment;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Theme.of(context).backgroundColor,
        ),
        title: Text(
          'Comments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  child: Comments1(
                    userUid: widget.userPhoto.userUid!,
                    docId: widget.userPhoto.docId!,
                    onReplyComment: (comment) {
                      replyToComment(comment);
                      widget.focusNode.requestFocus();
                    },
                    isReplyComment: (comment) {
                      isReplyCommentReply(comment);
                    },
                  ),
                ),
              ),
              AddComment(
                focusNode: widget.focusNode,
                userPhoto: widget.userPhoto,
                onCancelReply: cancelReply,
                replyComment: replyComment,
                comment: isReplyComment,
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///Update the reply comment
  void replyToComment(Comment comment) {
    setState(() {
      replyComment = comment;
    });
  }

  ///to get reply comment of comment
  void isReplyCommentReply(Comment comment) {
    setState(() {
      isReplyComment = comment;
    });
  }

  ///to cancel the reply comment
  void cancelReply() {
    setState(() {
      isReplyComment = null;
      replyComment = null;
    });
  }
}
