///To get comments of particular photo

import 'package:flutter/material.dart';

///firebase package
import 'package:cloud_firestore/cloud_firestore.dart';

///other class packages
import 'package:insta_clone/Json/commentJson.dart';
import 'package:insta_clone/HomeScreen/Photo/CommentPages/SingleComment.dart';
import 'package:insta_clone/HomeScreen/Photo/CommentPages/ReplyDisplay.dart';

class Comments1 extends StatefulWidget {
  final String userUid;
  final String docId;
  final ValueChanged<Comment> onReplyComment;
  final ValueChanged<Comment> isReplyComment;
  const Comments1({
    required this.userUid,
    required this.docId,
    required this.onReplyComment,
    required this.isReplyComment,
    Key? key,
  }) : super(key: key);

  @override
  _Comments1State createState() => _Comments1State();
}

class _Comments1State extends State<Comments1> {
  List<Comment> commentsList = [];
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('usersPhoto')
              .doc(widget.userUid)
              .collection('Photo')
              .doc(widget.docId)
              .collection('comment')
              .orderBy('time', descending: false)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              commentsList.clear();
              snapshot.data!.docs.forEach((element) {
                var tempMap = element.data();
                Map<String, dynamic> temp = tempMap as Map<String, dynamic>;
                Comment comment = Comment.fromJson(temp);
                commentsList.add(comment);
              });
              return ListView.builder(
                primary: true,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: commentsList.length,
                itemBuilder: (context, int index) {
                  return Column(
                    children: [
                      SingleComment(
                        comment: commentsList[index],
                        onReplyComment: widget.onReplyComment,
                      ),
                      commentsList[index].replyComments!.length > 0
                          ? ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount:
                                  commentsList[index].replyComments!.length,
                              itemBuilder: (context, int replyIndex) {
                                return ReplyDisplay(
                                  comment: commentsList[index],
                                  onReplyComment: widget.onReplyComment,
                                  replyCommentJson: commentsList[index]
                                      .replyComments![replyIndex],
                                  isReplyComment: widget.isReplyComment,
                                );
                              },
                            )
                          : SizedBox.shrink(),
                    ],
                  );
                },
              );
            } else
              return Container();
          },
        ),
      ),
    );
  }
}
