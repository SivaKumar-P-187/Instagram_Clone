///to add image to firestore of particular user

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///firebase packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

///picker
import 'package:image_picker/image_picker.dart';
import 'dart:io';

///animate icon
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

///random string
import 'package:random_string/random_string.dart';

///other class packages
import 'package:insta_clone/HomeScreen/Story/AddStoryPages/story_helper.dart';
import 'package:insta_clone/Json/photoJson.dart';
import 'package:insta_clone/Profile_Page/Profile_Page.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/handlers/ErrorHandler.dart';
import 'package:insta_clone/MainHomeScreen.dart';

class AddPhoto extends StatefulWidget {
  final bool? isProfile;
  const AddPhoto({
    required this.isProfile,
    Key? key,
  }) : super(key: key);

  @override
  _AddPhotoState createState() => _AddPhotoState();
}

class _AddPhotoState extends State<AddPhoto> {
  bool inProcess = false;
  bool isPhoto = false;
  UserPhoto? userPhoto;
  UploadTask? task;
  String? myUid;
  String? myDisplay;
  String? profile;
  String? imageUrl;
  getValue() async {
    if (this.mounted) {
      myDisplay = await SharedPreferencesHelper().getUserDisplayName();
      myUid = await SharedPreferencesHelper().getUserUid();
      userPhoto = await SharedPreferencesHelper().getTempPhoto();
      profile = await SharedPreferencesHelper().getUserPhotoUrl();
      setState(() {});
    }
  }

  buildOnLaunch() async {
    await getValue();
    if (this.mounted) {
      if (userPhoto != null) {
        await updatePhoto();
        isPhoto = true;
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    buildOnLaunch();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isPhoto) {
          final shouldPop = await Dialogs().showWarningDialog(context);
          return shouldPop!;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              if (widget.isProfile == true) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => MainHomeScreen(
                      pageControl: 0,
                    ),
                  ),
                );
              } else {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Profile(),
                  ),
                );
              }
            },
          ),
          title: Text(
            'Upload Photo',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: inProcess == true
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : userPhoto != null
                  ? Stack(
                      children: [
                        Positioned(
                          top: 20,
                          child: Container(
                            height: 400,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent),
                              image: DecorationImage(
                                  image: FileImage(
                                    File(userPhoto!.imagePhotoUrl!),
                                  ), // picked file
                                  fit: BoxFit.fill),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 210,
                          left: (MediaQuery.of(context).size.width / 2) - 10,
                          child: isPhoto
                              ? CircularProgressIndicator()
                              : buildUploadStatus(task!),
                        )
                      ],
                    )
                  : Container(),
        ),
        floatingActionButton: SpeedDial(
          curve: Curves.bounceInOut,
          animatedIcon: AnimatedIcons.add_event,
          overlayColor: Colors.black87,
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white70,
          animatedIconTheme: IconThemeData.fallback(),
          children: [
            SpeedDialChild(
              child: Icon(Icons.camera_alt_outlined),
              backgroundColor: Colors.blue,
              label: 'Camera',
              onTap: () {
                pickImage(context, ImageSource.camera);
              },
            ),
            SpeedDialChild(
              child: Icon(Icons.photo_album),
              backgroundColor: Colors.blue,
              label: 'Gallery',
              onTap: () {
                pickImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  ///To pick image of particular source
  Future pickImage(BuildContext context, ImageSource source) async {
    setState(() {
      inProcess = true;
    });
    try {
      final image =
          await ImagePicker().pickImage(source: source, imageQuality: 100);
      if (image == null) {
        setState(() {
          inProcess = false;
        });
        return;
      }
      setState(() {
        inProcess = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryHelper(
            file: File(image.path),
            isStory: false,
            isProfile: widget.isProfile,
          ),
        ),
      );
    } on PlatformException catch (e) {
      ErrorHandler().errorDialog(context, e.message);
    }
  }

  updatePhoto() async {
    if (userPhoto != null) {
      await uploadPhoto();
    }
  }

  ///to upload image to firebase storage of particular user
  uploadImage() async {
    if (userPhoto != null) {
      final fileNames = userPhoto!.imagePhotoUrl!.split('/').last;
      final destination = '$myDisplay/$fileNames';
      try {
        final ref = FirebaseStorage.instance.ref(destination);
        task = ref.putFile(File(userPhoto!.imagePhotoUrl!));
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message.toString()),
          ),
        );
      }
      if (task != null) {
        final snapshot = await task!.whenComplete(() {});
        imageUrl = await snapshot.ref.getDownloadURL();
      }
    }
  }

  uploadPhoto() async {
    if (userPhoto != null) {
      await uploadImage();
      String photoId = randomAlphaNumeric(10);
      var time = DateTime.now();
      final photo = UserPhoto(
        imagePhotoUrl: imageUrl,
        docId: photoId,
        profilePhotoUrl: profile,
        userUid: myUid,
        userName: myDisplay,
        time: time,
        likeCount: 0,
        lastComment: null,
        likeUsers: [],
        savedUser: [],
        caption: userPhoto!.caption,
      ).toJson();
      await FirebaseApi().uploadPhoto(photo, myUid!, photoId).then(
        (value) async {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(myUid)
              .update(
            {
              'post': FieldValue.increment(1),
            },
          );
          if (mounted) {
            isPhoto = false;
            userPhoto = await SharedPreferencesHelper().removeTempPhoto();
            setState(() {});
          }
        },
      );
      setState(() {});
    }
  }

  buildUploadStatus(UploadTask task) {
    return StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final total = snap.totalBytes;
            double progress = snap.bytesTransferred / snap.totalBytes;
            if (progress == total) {
              setState(() {
                progress = 1;
              });
            }
            return GestureDetector(
              onTap: () async {
                userPhoto = await SharedPreferencesHelper().removeTempPhoto();
                task.cancel();
                setState(() {});
              },
              child: Stack(
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    valueColor: AlwaysStoppedAnimation(Colors.red),
                    strokeWidth: 3,
                    backgroundColor: Colors.grey.shade500,
                  ),
                  Positioned(
                    top: 5,
                    left: 6,
                    child: Center(
                      child: Icon(Icons.clear),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        });
  }
}
