import 'package:flutter/widgets.dart';

///firebase package
import 'package:cloud_firestore/cloud_firestore.dart';

///other class packages
import 'package:insta_clone/Json/StoryJson.dart';
import 'package:insta_clone/Json/commentJson.dart';
import 'package:insta_clone/Json/photoJson.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/Json/messageJson.dart';
import 'package:insta_clone/Json/utils.dart';
import 'package:insta_clone/handlers/ErrorHandler.dart';
import 'package:insta_clone/Json/SaveImageJson.dart';

class DataBaseMethod {
  ///store google account user details in firestore
  storeNewUser({
    Map<String, dynamic>? userInfo,
    String? userUid,
    context,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .set(userInfo!)
        .then((value) {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/homePageScreen');
    }).catchError((e) {
      ErrorHandler().errorDialog(context, e);
    });
  }

  ///to create the chat room id

  getChatRoomIdByUserNames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) == b.substring(0, 1).codeUnitAt(0)) {
      if (a.compareTo(b) > 0) {
        return "$b\_$a";
      } else {
        return "$a\_$b";
      }
    } else if (a.substring(0, 1).codeUnitAt(0) >
        b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }
}

class FirebaseApi {
  ///to get the details of the current user
  Future<QuerySnapshot> getUserUidInfo(String uid) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where('userUid', isEqualTo: uid)
        .get();
  }

  ///to get all user information except current information

  Stream<List<Users>> getAllUserInfo(String nickName) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('displayName', isNotEqualTo: nickName)
        .snapshots()
        .transform(Utils.transformer(Users.fromJson).cast());
  }

  ///get likes users details
  Stream<List<Users>> getLikesInfo(userUid) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('userUid', whereIn: userUid)
        .snapshots()
        .transform(Utils.transformer(Users.fromJson).cast());
  }

  ///to update the mute user list
  Future updateUserMuteList({String? myUid, List<String>? muteList}) async {
    return FirebaseFirestore.instance.collection('users').doc(myUid).update({
      'muteList': muteList,
    });
  }

  ///to check whether display name exist or not
  Future<QuerySnapshot> usernameCheck(String userDisplayName) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where('displayName', isEqualTo: userDisplayName)
        .get();
  }

  ///updates following users of currents user
  Future addFollowingList(
      String uid, List<String> following, int followingCount) async {
    return FirebaseFirestore.instance.collection('users').doc(uid).update({
      'followingUid': following,
      'following': followingCount,
    });
  }

  ///updates followers list of user
  Future addFollowersList(
      String uid, List<dynamic> followers, int followersCount) {
    return FirebaseFirestore.instance.collection('users').doc(uid).update({
      'followerUid': followers,
      'followers': followersCount,
    });
  }

  ///getting single user details
  Stream<List<Users>> getSingleUserInfo() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .transform(Utils.transformer(Users.fromJson).cast());
  }

  ///to update favorite list of current user
  Future addFavorite(String uid, List<String> favorite) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'favorites': favorite});
  }

  ///to update user story
  Future updateStory(String uid, List<Story> storyList) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'story': storyList.map((story) {
        return story.toJson();
      }).toList()
    });
  }

  ///to update user story
  updateSingleStory({int index = 0, List<Story>? story, Users? user}) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.userUid!)
        .update({
      'story': story!.map((story) {
        return story.toJson();
      }).toList(),
    });
  }

  ///to create chat room
  createNewChatRoom(Map<String, dynamic> chatRoomInfo, chatRoomId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .get();
    if (snapshot.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection('ChatRoom')
          .doc(chatRoomId)
          .set(chatRoomInfo);
    }
  }

  ///to add message to particular chat room
  Future addMessageToFireBase(
      {Map<String, dynamic>? message,
      String? messageId,
      String? chatRoomId}) async {
    return await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .collection('Chat')
        .doc(messageId)
        .set(message!);
  }

  ///to update last message of particular chat room
  Future updateLastMessage(Map<String, dynamic> messageInfo, chatRoomId) async {
    FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .update(messageInfo);
  }

  ///to get chats of chat rooms of current user
  Stream<List<Message>> getChatRooms(chatRoomId, nickName) {
    return FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .collection('Chat')
        .orderBy('messageTime', descending: true)
        .snapshots()
        .transform(Utils.transformer(Message.fromJson).cast());
  }

  ///to get following users story of current users
  Stream<List<Users>> getFollowingStory(followingUid) {
    return FirebaseFirestore.instance
        .collection('users')
        .where("userUid", whereIn: followingUid)
        .where("story", isNotEqualTo: [])
        .orderBy("story")
        .orderBy("lastStatusTime", descending: true)
        .snapshots()
        .transform(Utils.transformer(Users.fromJson).cast());
  }

  ///to get all chat rooms of current user
  Future<Stream<QuerySnapshot>> getAllChatRoomOfCurrentUser(
      String nickName) async {
    return FirebaseFirestore.instance
        .collection('ChatRoom')
        .orderBy('lastMessageTime', descending: true)
        .where('userNames', arrayContains: nickName)
        .snapshots();
  }

  ///upload image to firestore of current user
  Future uploadPhoto(
      Map<String, dynamic> photo, String uid, String photoID) async {
    return FirebaseFirestore.instance
        .collection("usersPhoto")
        .doc(uid)
        .collection('Photo')
        .doc(photoID)
        .set(photo)
        .then((value) {
      FirebaseFirestore.instance
          .collection('usersPhoto')
          .doc(uid)
          .set({'uid': uid});
    });
  }

  ///update likes count and likes users of photo
  updateLikeList(String uid, String docId, List<dynamic> userList) async {
    FirebaseFirestore.instance
        .collection('usersPhoto')
        .doc(uid)
        .collection('Photo')
        .doc(docId)
        .update({
      'Like count': userList.length,
      'like users': userList,
    });
  }

  ///update comment of particular photo
  Future uploadComment(
      {String? photoUid,
      String? userUid,
      Map<String, dynamic>? comment}) async {
    return FirebaseFirestore.instance
        .collection('usersPhoto')
        .doc(userUid)
        .collection('Photo')
        .doc(photoUid)
        .collection('comment')
        .doc(comment!['commentId'])
        .set(comment);
  }

  ///update reply comment for particular comment
  Future updateReplyComment({
    String? photoUid,
    String? userUid,
    String? commentId,
    List<Comment>? replyComment,
  }) async {
    return FirebaseFirestore.instance
        .collection('usersPhoto')
        .doc(userUid)
        .collection('Photo')
        .doc(photoUid)
        .collection('comment')
        .doc(commentId)
        .update(
      {
        "replyComments": replyComment!.map((e) {
          return e.toJson();
        }).toList(),
      },
    );
  }

  ///to get all reply comment of particular comment
  Future<Comment> getCommentReplyList({
    String? photoUid,
    String? userUid,
    String? commentId,
  }) async {
    var value = await FirebaseFirestore.instance
        .collection('usersPhoto')
        .doc(userUid)
        .collection('Photo')
        .doc(photoUid)
        .collection('comment')
        .doc(commentId)
        .get();
    Map<String, dynamic> temp = value.data() as Map<String, dynamic>;
    return Comment.fromJson(temp);
  }

  ///to update like of particular comment
  Future updateCommentLikeUsersList(
      {String? userId,
      String? photoId,
      String? commentId,
      List<dynamic>? array}) async {
    return FirebaseFirestore.instance
        .collection('usersPhoto')
        .doc(userId)
        .collection('Photo')
        .doc(photoId)
        .collection('comment')
        .doc(commentId)
        .update({
      'likes': array!.length,
      'like users': array,
    });
  }


  ///to get single photo details
  Future<UserPhoto> getSinglePhoto({String? userId, String? photoId}) async {
    Map<String, dynamic>? temp;
    var value = await FirebaseFirestore.instance
        .collection('usersPhoto')
        .doc(userId)
        .collection('Photo')
        .doc(photoId)
        .get();
    temp = value.data();
    UserPhoto userPhoto = UserPhoto.fromJson(temp!);
    return userPhoto;
  }

  ///to report a bug
  Future addNewReport(Map<String, dynamic> report) async {
    return FirebaseFirestore.instance.collection("Report").add(report);
  }

  ///to add a feedback
  Future addNewFeedback(Map<String, dynamic> feedback) async {
    return FirebaseFirestore.instance.collection("FeedBack").add(feedback);
  }

  ///to add image to current user
  Future addSaveImage(String myUid, List<SaveImageJson> image) async {
    return FirebaseFirestore.instance.collection('users').doc(myUid)
      ..update({
        'saveImage': image.map((image) {
          return image.toJson();
        }).toList()
      });
  }

  ///to update save image of users list to particular photo
  Future setSaveImage(
      {String? uid, String? docId, List<dynamic>? saveUser}) async {
    return FirebaseFirestore.instance
        .collection('usersPhoto')
        .doc(uid)
        .collection('Photo')
        .doc(docId)
        .update({'savedUser': saveUser});
  }

  ///to update profile of current user
  Future updateProfile(
      {String? uid,
      String? displayName,
      String? userName,
      String? about,
      String? photoUrl}) async {
    return FirebaseFirestore.instance.collection('users').doc(uid).update(
      {
        'displayName': displayName,
        'about': about,
        'userName': userName,
        'photoUrl': photoUrl,
      },
    );
  }

  ///to update display name of current users in chat room
  Future updateDisplayNameChat(
      String? uid, String? displayName, String? tempDisplayName) async {
    return FirebaseFirestore.instance
        .collection('ChatRoom')
        .where("userNames", arrayContains: tempDisplayName)
        .get()
        .then((value) {
      value.docs.forEach((element) async {
        var temp = element.data();
        await FirebaseFirestore.instance
            .collection('ChatRoom')
            .doc(temp["ChatRoomId"])
            .collection('Chat')
            .get()
            .then((value) {
          value.docs.forEach((element) async {
            var temp1 = element.data();
            if (temp1["messageSendBy"] == tempDisplayName) {
              await FirebaseFirestore.instance
                  .collection('ChatRoom')
                  .doc(temp1["chatRoomId"])
                  .collection('Chat')
                  .doc(temp1["docId"])
                  .update({'messageSendBy': displayName});
            }
          });
        }).whenComplete(() async {
          List<dynamic> arrayList = temp["userNames"];
          if (arrayList.contains(tempDisplayName)) {
            arrayList.remove(tempDisplayName);
            arrayList.add(displayName!);
            await FirebaseFirestore.instance
                .collection('ChatRoom')
                .doc(temp["ChatRoomId"])
                .update({
              "lastMessageSendBy": displayName,
              "userNames": arrayList,
            });
          }
        });
      });
    });
  }

  ///to update display name to photos of current user
  Future updateDisplayNamePhoto(String? uid, String? displayName) async {
    return FirebaseFirestore.instance
        .collection('usersPhoto')
        .doc(uid)
        .collection('Photo')
        .get()
        .then((value) {
      value.docs.forEach(
        (element) async {
          var temp = UserPhoto.fromJson(element.data());
          await FirebaseFirestore.instance
              .collection('usersPhoto')
              .doc(uid)
              .collection('Photo')
              .doc(temp.docId)
              .update(
            {'userName': displayName},
          );
        },
      );
    });
  }
}

///to stop glow in scroll of item in list view
class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
