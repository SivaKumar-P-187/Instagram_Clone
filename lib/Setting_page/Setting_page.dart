import 'package:flutter/material.dart';

///setting package
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:insta_clone/images.dart';
import 'package:list_tile_switch/list_tile_switch.dart';

///font icon
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

///firebase package
import 'package:firebase_auth/firebase_auth.dart';

///google sign in package
import 'package:google_sign_in/google_sign_in.dart';

///provider package
import 'package:provider/provider.dart';

///local storage package
import 'package:shared_preferences/shared_preferences.dart';

///other class package
import 'package:insta_clone/Setting_page/DarkThemeProvider.dart';
import 'package:insta_clone/Setting_page/icon_widget.dart';
import 'package:insta_clone/Profile_Page/Profile_Page.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/Setting_page/GeneralSetting/MutedAccountPage.dart';
import 'package:insta_clone/Setting_page/FeedBack/Report.dart';
import 'package:insta_clone/Setting_page/GeneralSetting/SavedImages.dart';
import 'package:insta_clone/Setting_page/FeedBack/feedback.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String? userName;
  String? displayName;
  String? photoUrl;
  String? googleBool;

  getCurrentUserValue() async {
    if (this.mounted) {
      userName = await SharedPreferencesHelper().getUserName();
      displayName = await SharedPreferencesHelper().getUserDisplayName();
      photoUrl = await SharedPreferencesHelper().getUserPhotoUrl();
      googleBool = await SharedPreferencesHelper().getUserGoogleLogin();
      setState(() {});
    }
  }

  buildOnLaunch() async {
    await getCurrentUserValue();
  }

  @override
  void initState() {
    // TODO: implement initState
    buildOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return ListView(
      children: [
        SizedBox(
          height: 15.0,
        ),

        ///TO DISPLAY PROFILE DATA AND NAVIGATE TO PROFILE SCREEN
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Profile(),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(left: 15, right: 15),
              height: 70,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      photoUrl != null
                          ? imageWidget(
                              image: photoUrl,
                              height: 70.toDouble(),
                              width: 70.toDouble())
                          : SizedBox.shrink(),
                      SizedBox(
                        width: 10.0,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          displayName != null
                              ? Text(
                                  displayName!,
                                  overflow: TextOverflow.clip,
                                  style: Theme.of(context).textTheme.headline1,
                                )
                              : Text(''),
                          SizedBox(
                            height: 5.0,
                          ),
                          userName != null
                              ? Text(
                                  userName!,
                                  style: Theme.of(context).textTheme.headline2,
                                )
                              : Text(''),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Profile(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: 25.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 5.0,
        ),
        //HeaderPage(),
        ListTileSwitch(
          value: themeChange.darkTheme,
          leading: IconWidget(
            icon: Icons.dark_mode,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (value) {
            setState(() {
              themeChange.darkTheme = value;
            });
          },
          visualDensity: VisualDensity.comfortable,
          switchType: SwitchType.cupertino,
          switchActiveColor: Colors.indigo,
          title: Text('Dark theme'),
        ),
        SizedBox(
          height: 5.0,
        ),

        ///TO CREATE ACCOUNT SETTINGS PAGE
        SettingsGroup(
          title: 'GENERAL',
          children: [
            const SizedBox(
              height: 8,
            ),
            buildMuteAccount(),
            buildSavedImage(),
            buildLogout(context),
          ],
        ),
        const SizedBox(
          height: 32,
        ),

        ///TO CREATE FEEDBACK SETTING PAGE
        SettingsGroup(
          title: 'FEEDBACK',
          children: <Widget>[
            const SizedBox(
              height: 8,
            ),
            buildReportBug(context),
            buildSentFeedback(context),
          ],
        ),
      ],
    );
  }

  Widget buildMuteAccount() => SimpleSettingsTile(
      title: 'Muted Accounts',
      subtitle: '',
      leading: IconWidget(
        icon: FontAwesomeIcons.bellSlash,
        color: Colors.black26,
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MutedAccounts(),
          ),
        );
      });

  Widget buildSavedImage() => SimpleSettingsTile(
      title: 'SavedImage',
      subtitle: '',
      leading: IconWidget(
        icon: Icons.turned_in,
        color: Colors.lightBlueAccent,
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SaveImages(),
          ),
        );
      });

  Widget buildLogout(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SimpleSettingsTile(
        title: 'Logout',
        subtitle: '',
        leading: IconWidget(
          icon: Icons.logout,
          color: Colors.blue,
        ),
        onTap: () async {
          SharedPreferences preferences = await SharedPreferences.getInstance();

          await preferences.clear();
          Settings.clearCache();
          final GoogleSignIn signIn = GoogleSignIn();
          if (googleBool == "Google Login") {
            await signIn.signOut();
          }
          await FirebaseAuth.instance.signOut().whenComplete(
            () {
              setState(() {
                themeChange.darkTheme = false;
              });
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/signInScreen', (route) => false);
            },
          );
        });
  }

  Widget buildReportBug(BuildContext context) => SimpleSettingsTile(
      title: 'Report A Bug',
      subtitle: '',
      leading: IconWidget(
        icon: Icons.bug_report,
        color: Colors.teal,
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Report(),
          ),
        );
      });
  Widget buildSentFeedback(BuildContext context) => SimpleSettingsTile(
      title: 'Send FeedBack',
      subtitle: '',
      leading: IconWidget(
        icon: Icons.thumb_up,
        color: Colors.purple,
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FeedBack(),
          ),
        );
      });

  imageWidget({String? image, double? height, double? width}) {
    return ClipOval(
      child: ImagesWidget(image: image, width: width, height: height),
    );
  }
}
