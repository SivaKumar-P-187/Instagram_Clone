import 'package:flutter/material.dart';

///other class packages
import 'package:insta_clone/Profile_Page/TextWidget.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/handlers/ErrorHandler.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';

///picker
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

///firebase packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:insta_clone/images.dart';

class GetUserInformation extends StatefulWidget {
  @override
  _GetUserInformationState createState() => _GetUserInformationState();
}

class _GetUserInformationState extends State<GetUserInformation> {
  String image = 'https://i.stack.imgur.com/l60Hf.png';
  String about = "";
  String userName = "";
  String displayName = "";
  String userUid = FirebaseAuth.instance.currentUser!.uid;
  File? file;
  bool inProcess = false;
  UploadTask? task;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final picker = ImagePicker();
  final _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: ListView(
        shrinkWrap: true,
        children: [
          Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 20.0,
                  ),
                  Center(
                    child: Text(
                      'INFORMATION SCREEN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  inProcess
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : buildImage(),
                  SizedBox(
                    height: 15.0,
                  ),
                  Form(
                      key: _key,
                      child: Column(
                        children: [
                          TextEditing(
                            label: 'User Name',
                            maxLine: 1,
                            text: userName,
                            onChanged: (value) {
                              setState(() {
                                userName = value;
                              });
                            },
                            onSaved: (name) {
                              setState(() {
                                userName = name!;
                                userName.trim();
                              });
                            },
                            validator: (value) {
                              if (userName.length < 5) {
                                return "User Name must contain at least 5 characters";
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          TextEditing(
                              label: 'Nick Name',
                              maxLine: 1,
                              text: displayName,
                              onChanged: (value) {
                                setState(() {
                                  displayName = value;
                                });
                              },
                              onSaved: (name) {
                                setState(() {
                                  displayName = name!;
                                  displayName.trim();
                                });
                              },
                              validator: (value) {
                                if (displayName.length < 5) {
                                  return 'Display Name must contain at least 5 characters';
                                }
                                if (displayName.length > 10) {
                                  return 'Display Name max length is 10 characters';
                                }
                                return null;
                              }),
                          SizedBox(
                            height: 5.0,
                          ),
                          TextEditing(
                            label: 'About',
                            maxLine: 5,
                            text: about,
                            onChanged: (value) {
                              setState(() {
                                about = value;
                              });
                            },
                            onSaved: (value) {
                              setState(() {
                                about = value!;
                                about.trim();
                              });
                            },
                            validator: (value) {
                              if (about.length < 6) {
                                return "User About must contain at least 6 characters";
                              }
                              return null;
                            },
                          ),
                        ],
                      )),
                  SizedBox(
                    height: 5.0,
                  ),
                  MaterialButton(
                    onPressed: () async {
                      Dialogs.showLoadingDialog(context, _keyLoader);
                      await FirebaseApi()
                          .usernameCheck(displayName)
                          .then((value) async {
                        if (value.docs.isEmpty) {
                          if (_key.currentState!.validate()) {
                            await SharedPreferencesHelper()
                                .setUserName(userName);
                            await SharedPreferencesHelper()
                                .setUserDisplayName(displayName);
                            await SharedPreferencesHelper()
                                .setUserPhotoUrl(image);
                            await SharedPreferencesHelper().setUserAbout(about);
                            await SharedPreferencesHelper()
                                .setUserFollowing([]);
                            await SharedPreferencesHelper().setUserFavorite([]);
                            final userInfo = Users(
                              userUid: userUid,
                              userName: userName,
                              displayName: displayName,
                              about: about,
                              photoUrl: image,
                              post: 0,
                              lastStatusTime: DateTime.now().toUtc(),
                              followers: 0,
                              following: 0,
                              photos: [],
                              favorites: [],
                              followerUid: [],
                              followingUid: [],
                              story: [],
                              muteList: [],
                              saveImage: [],
                            );
                            await DataBaseMethod().storeNewUser(
                              userInfo: userInfo.toJson(),
                              userUid: userUid,
                              context: context,
                            );
                          } else {
                            Navigator.of(_keyLoader.currentContext!,
                                    rootNavigator: true)
                                .pop();
                          }
                        } else {
                          Navigator.of(_keyLoader.currentContext!,
                                  rootNavigator: true)
                              .pop();
                          ErrorHandler()
                              .errorDialog(context, 'Nick name already exist');
                        }
                      });
                    },
                    color: Colors.blue,
                    shape: StadiumBorder(),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  buildImage() {
    return Stack(
      children: [
        GestureDetector(
            onTap: () {
              inProcess = true;
              setState(() {});
              getImage();
            },
            child: imageWidget(
              image: image,
              height: 100.toDouble(),
              width: 100.toDouble(),
            )),
        Positioned(
          bottom: 4,
          right: 0,
          child: buildEditIcon(),
        ),
      ],
    );
  }

  imageWidget({String? image, double? height, double? width}) {
    return ClipOval(
      child: ImagesWidget(image: image, width: width, height: height),
    );
  }

  Widget buildEditIcon() {
    return buildCircle(
        child: buildCircle(
            child: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            all: 4,
            color: Colors.blue),
        all: 1,
        color: Colors.white);
  }

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) {
    return ClipOval(
      child: Container(
        padding: EdgeInsets.all(all),
        color: color,
        child: child,
      ),
    );
  }

  getImage() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    final fileName = result.files.single.path;
    setState(() {
      file = File(fileName!);
    });
    if (file == null) return;
    final fileNames = file!.path.split('/').last;
    final destination = 'Profile/$fileNames';
    final ref = FirebaseStorage.instance.ref(destination);
    task = ref.putFile(file!);
    final snapshot = await task!.whenComplete(() {});
    image = await snapshot.ref.getDownloadURL();
    inProcess = false;
    setState(() {});
  }
}
