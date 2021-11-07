// To parse this JSON data, do
//
//     final comment = commentFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

List<Comment> commentFromJson(String str) =>
    List<Comment>.from(json.decode(str).map((x) => Comment.fromJson(x)));

String commentToJson(List<Comment> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Comment {
  Comment({
    @required this.userName,
    @required this.toUserName,
    @required this.photoUrl,
    @required this.userUid,
    @required this.time,
    @required this.comment,
    @required this.commentId,
    @required this.likes,
    @required this.photoId,
    @required this.likeUsers,
    @required this.replyComments,
  });

  final String? userName;
  final String? toUserName;
  final String? photoUrl;
  final String? photoId;
  final String? userUid;
  final DateTime? time;
  final String? comment;
  final String? commentId;
  final int? likes;
  final List<dynamic>? likeUsers;
  final List<Comment>? replyComments;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        userName: json["User Name"],
        toUserName: json["toUserName"],
        userUid: json["userUid"],
        photoUrl: json["photoUrl"],
        photoId: json["photoId"],
        time: DateTime.parse(json["time"]),
        comment: json["comment"],
        commentId: json["commentId"],
        likes: json["likes"],
        likeUsers: List<dynamic>.from(json["like users"].map((x) => x)),
        replyComments: List<Comment>.from(
          json["replyComments"].map(
            (x) => Comment.fromJson(x),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
        "User Name": userName,
        "toUserName": toUserName,
        "userUid": userUid,
        "photoUrl": photoUrl,
        "photoId": photoId,
        "time": time!.toIso8601String(),
        "comment": comment,
        "commentId": commentId,
        "likes": likes,
        "like users": List<dynamic>.from(likeUsers!.map((x) => x)),
        "replyComments": List<dynamic>.from(replyComments!.map((x) => x)),
      };
}
