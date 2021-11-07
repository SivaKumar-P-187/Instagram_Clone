// To parse this JSON data, do
//
//     final users = usersFromJson(jsonString);

import 'dart:convert';
import 'package:insta_clone/Json/StoryJson.dart';
import 'package:insta_clone/Json/photoJson.dart';
import 'package:insta_clone/Json/SaveImageJson.dart';
import 'package:meta/meta.dart';

import 'package:flutter/material.dart';

List<Users> usersFromJson(String str) =>
    List<Users>.from(json.decode(str).map((x) => Users.fromJson(x)));

String usersToJson(List<Users> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Users {
  Users({
    @required this.userUid,
    @required this.userName,
    @required this.displayName,
    @required this.photoUrl,
    @required this.about,
    @required this.post,
    @required this.followers,
    @required this.following,
    @required this.favorites,
    @required this.followingUid,
    @required this.followerUid,
    @required this.photos,
    @required this.story,
    @required this.lastStatusTime,
    @required this.muteList,
    @required this.saveImage,
  });

  final String? userUid;
  final String? userName;
  final String? displayName;
  final String? photoUrl;
  final String? about;
  final DateTime? lastStatusTime;
  final int? post;
  final int? followers;
  final int? following;
  final List<dynamic>? muteList;
  final List<dynamic>? favorites;
  final List<dynamic>? followingUid;
  final List<dynamic>? followerUid;
  final List<dynamic>? photos;
  final List<SaveImageJson>? saveImage;
  final List<Story>? story;

  static Users fromJson(Map<String, dynamic> json) => Users(
        userUid: json["userUid"],
        userName: json["userName"],
        displayName: json["displayName"],
        photoUrl: json["photoUrl"],
        about: json["about"],
        post: json["post"],
        followers: json["followers"],
        following: json["following"],
        favorites: List<dynamic>.from(json["favorites"].map((x) => x)),
        followingUid: List<dynamic>.from(json["followingUid"].map((x) => x)),
        followerUid: List<dynamic>.from(json["followerUid"].map((x) => x)),
        photos: List<dynamic>.from(json["photos"].map((x) => x)),
        story: List<Story>.from(json["story"].map((x) => Story.fromJson(x))),
        lastStatusTime: DateTime.parse(json["lastStatusTime"]),
        muteList: List<dynamic>.from(json["muteList"].map((x) => x)),
        saveImage: List<SaveImageJson>.from(
          json["saveImage"].map(
            (x) => SaveImageJson.fromJson(x),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
        "userUid": userUid!,
        "userName": userName!,
        "displayName": displayName!,
        "photoUrl": photoUrl!,
        "about": about!,
        "post": post!,
        "followers": followers!,
        "following": following!,
        "favorites": List<dynamic>.from(favorites!.map((x) => x)),
        "followingUid": List<dynamic>.from(followingUid!.map((x) => x)),
        "followerUid": List<dynamic>.from(followerUid!.map((x) => x)),
        "photos": List<dynamic>.from(photos!.map((x) => x)),
        "story": List<dynamic>.from(story!.map((x) => x)),
        "lastStatusTime": lastStatusTime!.toIso8601String(),
        'muteList': List<dynamic>.from(muteList!.map((x) => x)),
        "saveImage": List<dynamic>.from(saveImage!.map((x) => x)),
      };
}

// [
// {
// "photoUrl": "",
// "message": "",
// "messageTime": "2012-04-23T18:25:43.511Z",
// "messageSendBy":"",
// "photoUrl":"",
// "replyMessage": {}
// }
// ]
//
// [
// {
// "userUid": "",
// "userName": "ram",
// "displayName": "sam",
// "photoUrl": "https://i.stack.imgur.com/l60Hf.png",
// "about": "Hi this master",
// "post": 0,
// "followers": 0,
// "following":0,
// "favorites":[],
// "followingUid":[],
// "followerUid": [],
//"story":[]
// }
// ]
// "posts":
// {
//     "photoUrl":"",
//     "time":"2012-04-23T18:25:43.511Z",
//     "Like count":0,
//     "comment":[],
//     "like users":[]
// },
