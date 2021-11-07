import 'package:flutter/material.dart';

///picker
import 'package:file_picker/file_picker.dart';
import 'dart:io';

///firebase package
import 'package:firebase_storage/firebase_storage.dart';

///other class packages
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/handlers/ErrorHandler.dart';
import 'package:insta_clone/Profile_Page/TextWidget.dart';
import 'package:insta_clone/Profile_Page/ProfileWidget.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String? userName;
  String? displayName;
  String? lastDisplayName;
  String? photoUrl;
  String? userAbout;
  String? uid;
  bool changes = false;
  bool instant = false;
  String? image;
  String images = 'https://i.stack.imgur.com/l60Hf.png';
  File? file;
  UploadTask? task;
  bool inProcess = false;
  final _key = GlobalKey<FormState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  ///to get value of current user from shared preference
  getCurrentUserValue() async {
    if (this.mounted) {
      userName = await SharedPreferencesHelper().getUserName();
      displayName = await SharedPreferencesHelper().getUserDisplayName();
      lastDisplayName = displayName;
      photoUrl = await SharedPreferencesHelper().getUserPhotoUrl();
      userAbout = await SharedPreferencesHelper().getUserAbout();
      uid = await SharedPreferencesHelper().getUserUid();
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    buildOnLaunch();
    setState(() {});
    super.initState();
  }

  ///build on launch on page launch
  buildOnLaunch() async {
    await getCurrentUserValue();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (changes) {
          final shouldPop = await Dialogs().showWarningDialog(context);
          return shouldPop!;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: Theme.of(context).backgroundColor,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Form(
              key: _key,
              child: Column(
                children: [
                  inProcess
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : photoUrl != null
                          ? ProfileWidget(
                              imagePath: image == null ? photoUrl! : image,
                              editingState: true,
                              onClicked: () async {
                                inProcess = true;
                                setState(() {});
                                await getImage();
                              },
                            )
                          : Container(),
                  const SizedBox(
                    height: 20,
                  ),
                  userName != null
                      ? TextEditing(
                          label: 'User Name',
                          text: userName!,
                          maxLine: 1,
                          onChanged: (name) {
                            setState(() {
                              userName = name;
                              changes = true;
                            });
                          },
                          onSaved: (name) {
                            setState(() {
                              userName = name;
                              userName!.trim();
                            });
                          },
                          validator: (value) {
                            if (userName!.length < 5) {
                              return "User Name must contain at least 5 characters";
                            }
                            return null;
                          },
                        )
                      : Container(),
                  const SizedBox(
                    height: 20,
                  ),
                  displayName != null
                      ? TextEditing(
                          label: 'Nick Name',
                          text: displayName!,
                          maxLine: 1,
                          onChanged: (name) {
                            setState(() {
                              displayName = name;
                              changes = true;
                            });
                          },
                          onSaved: (name) {
                            setState(() {
                              displayName = name;
                              displayName!.trim();
                            });
                          },
                          validator: (value) {
                            if (displayName!.length < 5) {
                              return 'Display Name must contain at least 5 characters';
                            }
                            if (displayName!.length > 10) {
                              return 'Display Name max length is 10 characters';
                            }
                            return null;
                          })
                      : Container(),
                  const SizedBox(
                    height: 20,
                  ),
                  userAbout != null
                      ? TextEditing(
                          label: 'About',
                          text: userAbout!,
                          maxLine: 5,
                          onChanged: (name) {
                            setState(() {
                              userAbout = name;
                              changes = true;
                            });
                          },
                          onSaved: (name) {
                            setState(() {
                              userAbout = name;
                              userAbout!.trim();
                            });
                          },
                          validator: (value) {
                            if (userAbout!.length < 6) {
                              return "User About must contain at least 6 characters";
                            }
                            return null;
                          },
                        )
                      : Container(),
                  const SizedBox(
                    height: 20,
                  ),
                  MaterialButton(
                    onPressed: () async {
                      Dialogs.showLoadingDialog(context, _keyLoader);
                      if (_key.currentState!.validate()) {
                        await FirebaseApi()
                            .usernameCheck(displayName!)
                            .then((value) {
                          if (value.docs.isEmpty) {
                            instant = true;
                            setState(() {});
                          }
                          if (value.docs.isNotEmpty) {
                            var ds =
                                value.docs[0].data() as Map<String, dynamic>;
                            if (ds['userUid'] == uid) {
                              instant = true;
                              setState(() {});
                            } else {
                              instant = false;
                              Navigator.of(_keyLoader.currentContext!,
                                      rootNavigator: true)
                                  .pop();
                              setState(() {});
                            }
                          }
                        });
                        setState(() {});
                        if (instant) {
                          await FirebaseApi()
                              .updateProfile(
                            uid: uid,
                            displayName: displayName,
                            userName: userName,
                            about: userAbout,
                            photoUrl: image != null ? image : photoUrl,
                          )
                              .then((value) async {
                            await FirebaseApi()
                                .updateDisplayNamePhoto(uid, displayName)
                                .then((value) async {
                              await FirebaseApi().updateDisplayNameChat(
                                  uid, displayName, lastDisplayName);
                            });
                            if (image != null) {
                              await SharedPreferencesHelper()
                                  .setUserPhotoUrl(image!);
                            }
                            await SharedPreferencesHelper()
                                .setUserAbout(userAbout!);
                            await SharedPreferencesHelper()
                                .setUserDisplayName(displayName!);
                            await SharedPreferencesHelper()
                                .setUserName(userName!);
                            Navigator.of(_keyLoader.currentContext!,
                                    rootNavigator: true)
                                .pop();
                            Navigator.of(context).pop();
                            Navigator.of(context)
                                .popAndPushNamed('/profilePage');
                          });
                        } else {
                          Navigator.of(_keyLoader.currentContext!,
                                  rootNavigator: true)
                              .pop();
                          ErrorHandler().errorDialog(context,
                              'Update Failed ..   Nick name already exist');
                        }
                      }
                    },
                    color: Colors.blue,
                    child: Text('Update profile'),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    final destination = '$displayName/$fileNames';
    final ref = FirebaseStorage.instance.ref(destination);
    task = ref.putFile(file!);
    final snapshot = await task!.whenComplete(() {});
    image = await snapshot.ref.getDownloadURL();
    inProcess = false;
    setState(() {});
  }
}
