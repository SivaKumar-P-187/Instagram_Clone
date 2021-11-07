import 'package:flutter/material.dart';

///firebase package
import 'package:firebase_auth/firebase_auth.dart';

///email verification package
import 'package:email_auth/email_auth.dart';

///font icon package
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

///other class package
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/handlers/ErrorHandler.dart';

class EmailVerification extends StatefulWidget {
  final String? email;
  final String? password;
  final bool? isForGet;
  const EmailVerification({
    Key? key,
    required this.email,
    required this.isForGet,
    @required this.password,
  }) : super(key: key);

  @override
  _EmailVerificationState createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  String? otp;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  EmailAuth emailAuth = new EmailAuth(sessionName: "Instagram Sign in");
  final _key = GlobalKey<FormState>();

  void sendOtp() async {
    var res = await emailAuth.sendOtp(recipientMail: widget.email!);
    if (res) {
      final snackBar = SnackBar(content: Text('OTP is Send'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void verifyOtp() async {
    var res;
    if (widget.email != null) {
      res = emailAuth.validateOtp(recipientMail: widget.email!, userOtp: otp!);
    }
    if (res) {
      if (!widget.isForGet!) {
        await conformEmail();
      } else {
        await sendRequest();
      }
    } else {
      ErrorHandler().errorDialog(context, "OTP is Invalid please try again..");
    }
  }

  buildOnLaunch() async {
    sendOtp();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    buildOnLaunch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: ListView(
        primary: true,
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        children: [
          SizedBox(
            height: 80.0,
          ),
          Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 30.0),
                  height: 170.0,
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    'Verify Email',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 65.0,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(185.0, 60.0, 0.0, 0.0),
                child: Text(
                  '.',
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 90.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          Stack(
            children: [
              Form(
                key: _key,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 15.0, right: 15.0),
                      child: TextFormField(
                        enabled: false,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: widget.email,
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.blue,
                          ),
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                            borderSide: new BorderSide(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15.0, right: 15.0),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'OTP',
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FaIcon(
                              FontAwesomeIcons.key,
                              color: Colors.redAccent,
                            ),
                          ),
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(25.0),
                            borderSide: new BorderSide(),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            otp = value;
                          });
                          otp!.trim();
                        },
                        onSaved: (value) {
                          otp = value;
                        },
                        validator: (_email) {
                          if (otp!.isEmpty) {
                            return 'OTP should not be Empty..';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    MaterialButton(
                      onPressed: () async {
                        verifyOtp();
                      },
                      child: Text(
                        "Verify OTP",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      padding: EdgeInsets.only(left: 110.0, right: 110.0),
                      color: Colors.blue,
                      shape: StadiumBorder(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    MaterialButton(
                      onPressed: () async {
                        Navigator.of(context)
                            .pushReplacementNamed('/signInScreen');
                      },
                      child: Text(
                        'Go Back',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      padding: EdgeInsets.only(left: 110.0, right: 110.0),
                      color: Colors.white,
                      shape: StadiumBorder(),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'If OTP not received ? ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17.0),
                          ),
                          MaterialButton(
                            onPressed: () async {
                              sendOtp();
                            },
                            child: Text(
                              "Resend OTP",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 20.0,
                              ),
                            ),
                            color: Colors.grey.shade50,
                            shape: StadiumBorder(),
                          ),
                        ],
                      ),
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

  sendRequest() async {
    print("correct");
    Dialogs.showLoadingDialog(context, _keyLoader);
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: widget.email!)
        .whenComplete(() {
      Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
      Navigator.of(context).pushReplacementNamed('/signInScreen');
    }).catchError((e) {
      print(e);
    });
  }

  conformEmail() async {
    if (_key.currentState!.validate()) {
      Dialogs.showLoadingDialog(context, _keyLoader);
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: widget.email!, password: widget.password!)
          .then((value) async {
        await SharedPreferencesHelper().setUserUid(value.user!.uid);
        await SharedPreferencesHelper().setUserGoogleLogin("Email Login");
        Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/getUserInfo', (route) => false);
      }).catchError((e) {
        Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
        ErrorHandler().errorDialog(context, e);
      });
    }
  }
}
