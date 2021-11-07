import 'package:flutter/material.dart';

///other class packages
import 'package:insta_clone/Services/otpVerification.dart';

class GetEmail extends StatefulWidget {
  const GetEmail({Key? key}) : super(key: key);

  @override
  _GetEmailState createState() => _GetEmailState();
}

class _GetEmailState extends State<GetEmail> {
  String? _email;

  ///to change value of obscureText
  bool isLoading = false;

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
                            'RESET',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 40.0,
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
                            'PASSWORD',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 40.0,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(245.0, 30.0, 0.0, 0.0),
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
                      height: 10.0,
                    ),

                    ///login with email account
                    MaterialButton(
                      onPressed: () {
                        if (_key.currentState!.validate()) {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EmailVerification(
                                email: _email,
                                isForGet: true,
                                password: "",
                              ),
                            ),
                          );
                        }
                      },
                      padding: EdgeInsets.only(left: 110.0, right: 110.0),
                      child: Text(
                        'GET OTP',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
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
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
