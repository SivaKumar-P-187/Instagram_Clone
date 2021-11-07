import 'package:flutter/material.dart';

///firebase packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

///other class packages
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/Json/SaveImageJson.dart';
import 'package:insta_clone/Json/StoryJson.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/Services/AuthState.dart';
import 'package:insta_clone/handlers/ErrorHandler.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String? _email;

  ///to store email address from user
  bool _passIcon = true;

  ///to change value of obscureText
  bool isLoading = false;

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  ///to do loading animation when press any button
  TextEditingController _controller = TextEditingController();
  final _key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        primary: true,
        shrinkWrap: false,
        children: [
          Column(
            children: [
              SizedBox(
                height: 130.0,
              ),
              Stack(
                children: [
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 60.0,
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.1), //24
                          child: Text(
                            'Hello',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 60.0,
                                color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 60.0,
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.1), //24
                          child: Text(
                            'There',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 60.0,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(195.0, 50.0, 0.0, 0.0),
                    child: Text(
                      '.',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 90.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),

              ///validating email address and password
              Form(
                key: _key,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15.0, right: 15.0),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'EMAIL',
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                          ),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.blue,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _email = value;
                          });
                          _email!.trim();
                        },
                        onSaved: (value) {
                          _email = value;
                        },
                        validator: (_email) {
                          if (_email!.isEmpty) {
                            return 'email should not be empty';
                          }
                          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                              .hasMatch(_email)) {
                            return 'enter valid email';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15.0, right: 15.0),
                      child: TextFormField(
                        controller: _controller,
                        obscureText: _passIcon,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                          prefixIcon: IconButton(
                            icon: Icon(
                              _passIcon
                                  ? Icons.security_outlined
                                  : Icons.remove_red_eye_outlined,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              setState(() {
                                _passIcon = !_passIcon;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (_controller.text.isEmpty) {
                            return 'password should not be empty';
                          }
                          if (_controller.text.length < 7) {
                            return 'minimum length is 7';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 180.0),
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/getEmail', (route) => false);
                        },
                        child: Text(
                          'Forgot Password',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                          ),
                        ),
                        elevation: 0.0,
                        color: Colors.white,
                        shape: StadiumBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),

                    ///login with email account
                    MaterialButton(
                      onPressed: () {
                        if (_key.currentState!.validate()) {
                          Dialogs.showLoadingDialog(context, _keyLoader);
                          setState(() {});
                          try {
                            FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: _email!, password: _controller.text)
                                .then((value) async {
                              await SharedPreferencesHelper()
                                  .setUserUid(value.user!.uid);
                              DocumentSnapshot document =
                                  await checkUserPresent(value.user!.uid);
                              if (!document.exists) {
                                Navigator.of(_keyLoader.currentContext!,
                                        rootNavigator: true)
                                    .pop();
                                Navigator.of(context)
                                    .pushReplacementNamed('/getUserInfo');
                              } else {
                                await getCurrentUser(value.user!.uid, context);
                              }
                            }).catchError((e) {
                              Navigator.of(_keyLoader.currentContext!,
                                      rootNavigator: true)
                                  .pop();
                              ErrorHandler().errorDialog(context, e);
                            });
                          } on FirebaseException catch (e) {
                            Navigator.of(_keyLoader.currentContext!,
                                    rootNavigator: true)
                                .pop();
                            ErrorHandler().errorDialog(context, e.message);
                          }
                        }
                      },
                      padding: EdgeInsets.only(left: 110.0, right: 110.0),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      color: Colors.blue,
                      shape: StadiumBorder(),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5.0,
              ),

              ///login with google account
              MaterialButton(
                onPressed: () async {
                  isLoading = true;
                  setState(() {});
                  AuthMethod().signInWithGoogle(context).then((value) async {
                    await SharedPreferencesHelper().setUserUid(value.user!.uid);
                    await SharedPreferencesHelper()
                        .setUserGoogleLogin("Google Login");
                    Dialogs.showLoadingDialog(context, _keyLoader);
                    DocumentSnapshot document =
                        await checkUserPresent(value.user!.uid);
                    if (!document.exists) {
                      Navigator.of(_keyLoader.currentContext!,
                              rootNavigator: true)
                          .pop();
                      Navigator.of(context)
                          .pushReplacementNamed('/getUserInfo');
                    } else {
                      await getCurrentUser(value.user!.uid, context);
                    }
                  }).catchError((e) {
                    ErrorHandler().errorDialog(context, "Sign In cancelled");
                  });
                },
                padding: EdgeInsets.only(left: 55.0, right: 55.0),
                child: Text(
                  'Login with Google',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                color: Colors.white,
                shape: StadiumBorder(),
              ),
              SizedBox(
                height: 15.0,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 50.0,
                ),
                child: Row(
                  children: [
                    Text(
                      'New to Instagram ?',
                      style: TextStyle(color: Colors.grey, fontSize: 20.0),
                    ),
                    SizedBox(
                      width: 2.0,
                    ),
                    MaterialButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed('/signUpScreen');
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      color: Colors.white,
                      elevation: 0.0,
                      shape: StadiumBorder(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<DocumentSnapshot> checkUserPresent(String uid) async {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  getCurrentUser(String uid, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((value) async {
      Map<String, dynamic>? data = value.data();
      final Users users = Users.fromJson(data!);
      List<Story>? story = users.story;
      List<SaveImageJson>? photo = users.saveImage;
      await SharedPreferencesHelper().setUserStoryFinal(story);
      await SharedPreferencesHelper().setUserName(data['userName']);
      await SharedPreferencesHelper().setUserDisplayName(data['displayName']);
      await SharedPreferencesHelper().setUserPhotoUrl(data['photoUrl']);
      await SharedPreferencesHelper().setUserAbout(data['about']);
      await SharedPreferencesHelper().setUserFollowing(data['followingUid']);
      await SharedPreferencesHelper().setUserFavorite(data['favorites']);
      await SharedPreferencesHelper().setUserMute(data['muteList']);
      await SharedPreferencesHelper().saveImage(photo);
      isLoading = true;
      setState(() {});
      Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
      Navigator.of(context).pushReplacementNamed('/homePageScreen');
    }).catchError((e) {
      Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
      ErrorHandler().errorDialog(context, e);
    });
  }
}
