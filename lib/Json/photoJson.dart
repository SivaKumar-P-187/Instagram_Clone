// To parse this JSON data, do
//
//     final lastMessage = lastMessageFromJson(jsonString);

import 'package:insta_clone/Json/commentJson.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

List<UserPhoto> userPhotoFromJson(String str) =>
    List<UserPhoto>.from(json.decode(str).map((x) => UserPhoto.fromJson(x)));

String userPhotoToJson(List<UserPhoto> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserPhoto {
  UserPhoto(
      {@required this.imagePhotoUrl,
      @required this.profilePhotoUrl,
      @required this.userUid,
      @required this.docId,
      @required this.userName,
      @required this.time,
      @required this.likeCount,
      // @required this.comment,
      @required this.likeUsers,
      @required this.caption,
      @required this.lastComment,
      @required this.savedUser});

  final String? imagePhotoUrl;
  final String? profilePhotoUrl;
  final String? userName;
  final String? userUid;
  final String? docId;
  final String? caption;
  final DateTime? time;
  final int? likeCount;
  // final List<Comment>? comment;
  final Comment? lastComment;
  final List<dynamic>? likeUsers;
  final List<dynamic>? savedUser;

  static UserPhoto fromJson(Map<String, dynamic> json) => UserPhoto(
      imagePhotoUrl: json["photoUrl"],
      profilePhotoUrl: json["profileUrl"],
      docId: json["docId"],
      userName: json["userName"],
      userUid: json['userUid'],
      caption: json['caption'],
      time: DateTime.parse(json["time"]),
      likeCount: json["Like count"],
      // comment:
      //     List<Comment>.from(json["comment"].map((x) => Comment.fromJson(x))),
      likeUsers: List<dynamic>.from(json["like users"].map((x) => x)),
      savedUser: List<dynamic>.from(json["savedUser"].map((x) => x)),
      lastComment: json["last comment"] == null
          ? null
          : Comment.fromJson(json["last comment"]));
  Map<String, dynamic> toJson() => {
        "photoUrl": imagePhotoUrl,
        "profileUrl": profilePhotoUrl,
        "docId": docId,
        "userName": userName,
        "userUid": userUid,
        "caption": caption,
        "time": time!.toIso8601String(),
        "Like count": likeCount,
        // "comment": List<dynamic>.from(comment!.map((x) => x)),
        "like users": List<dynamic>.from(likeUsers!.map((x) => x)),
        "last comment": lastComment == null ? null : lastComment!.toJson(),
        "savedUser": List<dynamic>.from(savedUser!.map((x) => x)),
      };
}
