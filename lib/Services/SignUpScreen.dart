import 'package:flutter/material.dart';

///other class packages
import 'package:insta_clone/Services/otpVerification.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late String? _email;
  late String? _password;
  TextEditingController _controller = TextEditingController();
  bool _passIcon1 = true;
  bool _passIcon = true;

  final _key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        primary: true,
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
                  height: 130.0,
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    'Signup',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 65.0,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(225.0, 0.0, 0.0, 0.0),
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
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'EMAIL',
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 20.0,
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
                      height: 5.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15.0, right: 15.0),
                      child: TextFormField(
                        obscureText: _passIcon,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 20.0,
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
                        onChanged: (value) {
                          setState(() {
                            _password = value;
                          });
                        },
                        onSaved: (value) {
                          _password = value;
                        },
                        validator: (_password) {
                          if (_password!.isEmpty) {
                            return 'password should not be empty';
                          }
                          if (_password.length < 7) {
                            return 'minimum length is 7';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15.0, right: 15.0),
                      child: TextFormField(
                        controller: _controller,
                        obscureText: _passIcon1,
                        decoration: InputDecoration(
                          labelText: ' Conform Password',
                          labelStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                          prefixIcon: IconButton(
                            icon: Icon(
                              _passIcon1
                                  ? Icons.security_outlined
                                  : Icons.remove_red_eye_outlined,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              setState(() {
                                _passIcon1 = !_passIcon1;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (_controller.text.isEmpty) {
                            return 'password should not be empty';
                          }
                          if (_controller.text != _password) {
                            return 'password does n\'t match';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    MaterialButton(
                      onPressed: () {
                        if (_key.currentState!.validate()) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EmailVerification(
                                email: _email,
                                password: _password,
                                isForGet: false,
                              ),
                            ),
                          );
                        }
                      },
                      padding: EdgeInsets.only(left: 110.0, right: 110.0),
                      child: Text(
                        'Sign Up',
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
                height: 50,
              ),
            ],
          ),
          SizedBox(
            height: 5.0,
          ),
          Padding(
            padding: EdgeInsets.only(left: 30.0, right: 30.0),
            child: MaterialButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/signInScreen');
              },
              padding: EdgeInsets.only(left: 40.0, right: 40.0),
              child: Text(
                'Go Back',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              color: Colors.white,
              shape: StadiumBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
