import 'package:flutter/cupertino.dart';

///firebase packages
import 'package:firebase_auth/firebase_auth.dart';

///google sign in package
import 'package:google_sign_in/google_sign_in.dart';

///other class package
import 'package:insta_clone/handlers/ErrorHandler.dart';

class AuthMethod {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  ///to sign with google account
  Future<UserCredential> signInWithGoogle(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;
    Dialogs.showLoadingDialog(context, _keyLoader);
    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);
    final UserCredential result = await _auth.signInWithCredential(credential);
    Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
    return result;
  }

  ///to return the current user
  currentUser() async {
    return auth.currentUser;
  }
}
