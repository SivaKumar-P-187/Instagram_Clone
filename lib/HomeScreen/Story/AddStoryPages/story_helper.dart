import 'package:flutter/material.dart';
import 'dart:io';

///image
import 'package:image_cropper/image_cropper.dart';

///other class packages
import 'package:insta_clone/HomeScreen/Photo/AddPhoto/AddPhoto.dart';
import 'package:insta_clone/HomeScreen/Story/AddStoryPages/PresstoAddStory.dart';
import 'package:insta_clone/HomeScreen/Story/AddStoryPages/StoryPage.dart';
import 'package:insta_clone/Json/StoryJson.dart';
import 'package:insta_clone/Json/photoJson.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/images.dart';

class StoryHelper extends StatefulWidget {
  final File? file;
  final bool? isStory;
  final bool? isProfile;
  const StoryHelper(
      {this.file, required this.isProfile, required this.isStory, Key? key})
      : super(key: key);

  @override
  _StoryHelperState createState() => _StoryHelperState();
}

class _StoryHelperState extends State<StoryHelper> {
  String? imgPath;
  String? profile;
  String? myDisplay;
  File? image;
  String? myUid;
  String? text = '';
  bool _process = false;
  getValue() async {
    if (this.mounted) {
      imgPath = await SharedPreferencesHelper().getUserPhotoUrl();
      myDisplay = await SharedPreferencesHelper().getUserDisplayName();
      myUid = await SharedPreferencesHelper().getUserUid();
      profile = await SharedPreferencesHelper().getUserPhotoUrl();
      setState(() {});
    }
  }

  buildOnLaunch() async {
    await getValue();
  }

  @override
  void initState() {
    // TODO: implement initState
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
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  imgPath != null
                      ? Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            ClipRRect(
                              child: ImagesWidget(
                                  image: imgPath!, width: 50.0, height: 50.0),
                            ),
                          ],
                        )
                      : Container(),
                  IconButton(
                    onPressed: () async {
                      await imageCrop();
                    },
                    icon: Icon(
                      Icons.crop,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  child: Image.file(
                    widget.file!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              AddStory(
                onClicked: () {
                  widget.isStory! ? uploadStatus() : uploadPhoto();
                },
                text: text,
                onChanged: (value) {
                  setState(() {
                    text = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  imageCrop() async {
    _process = false;
    final cropped = await ImageCropper.cropImage(
      sourcePath: widget.file!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      compressQuality: 100,
      maxWidth: 700,
      maxHeight: 700,
      compressFormat: ImageCompressFormat.jpg,
      androidUiSettings: AndroidUiSettings(
          toolbarColor: Colors.deepOrange,
          toolbarTitle: 'Cropper',
          statusBarColor: Colors.deepOrange.shade200,
          backgroundColor: Colors.white,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
      ),
    );
    setState(() {
      if (cropped != null) {
        this.image = cropped;
      } else {
        this.image = File(image!.path);
      }
      _process = true;
    });
    if (_process) rebuildWidget();
  }

  rebuildWidget() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoryHelper(
          file: File(this.image!.path),
          isStory: widget.isStory,
          isProfile: widget.isProfile,
        ),
      ),
    );
  }

  uploadStatus() async {
    final tempStory = Story(
      url: widget.file!.path,
      time: DateTime.now(),
      media: MediaType.image,
      caption: text,
      duration: 15,
      viewCount: 0,
      viewList: [],
    );
    await SharedPreferencesHelper().setUserTempStoryKey(tempStory);
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => StoryPage(),
      ),
    );
  }

  uploadPhoto() async {
    final tempPhoto = UserPhoto(
      imagePhotoUrl: widget.file!.path,
      profilePhotoUrl: profile,
      time: DateTime.now(),
      docId: '',
      likeCount: 0,
      lastComment: null,
      likeUsers: [],
      caption: text,
      savedUser: [],
      userUid: myUid,
      userName: myDisplay,
    );
    await SharedPreferencesHelper().setUserTempPhotoKey(tempPhoto);
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => AddPhoto(
          isProfile: widget.isProfile,
        ),
      ),
    );
  }
}
