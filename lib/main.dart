import 'package:flutter/material.dart';
import 'dart:async';

///firebase package
import 'package:firebase_core/firebase_core.dart';

///setting screen
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:insta_clone/Services/getEmailIdReset.dart';

///provider
import 'package:provider/provider.dart';

///other class packages
import 'package:insta_clone/theme.dart';
import 'package:insta_clone/Setting_page/DarkThemeProvider.dart';
import 'package:insta_clone/Services/SignInScreen.dart';
import 'package:insta_clone/Services/SignUpScreen.dart';
import 'package:insta_clone/MainHomeScreen.dart';
import 'package:insta_clone/Services/GetUserData.dart';
import 'package:insta_clone/Services/AuthState.dart';
import 'package:insta_clone/Profile_Page/Profile_Page.dart';
import 'package:insta_clone/ChatPages/FavoritePage/AddFavorite.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Settings.init(cacheProvider: SharePreferenceCache());
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();
  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreferences.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            return themeChangeProvider;
          },
        ),
      ],
      child: Consumer<DarkThemeProvider>(builder: (context, themeData, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme: themeChangeProvider.darkTheme
              ? darkBasicTheme(context)
              : lightBasicTheme(context),
          routes: {
            '/signInScreen': (BuildContext context) => LoginScreen(),
            '/signUpScreen': (BuildContext context) => SignUpScreen(),
            '/homePageScreen': (BuildContext context) => MainHomeScreen(
                  pageControl: 0,
                ),
            '/getUserInfo': (BuildContext context) => GetUserInformation(),
            '/profilePage': (BuildContext context) => Profile(),
            '/addFavorite': (BuildContext context) => AddFavorite(
                  choose: true,
                ),
            '/getEmail': (BuildContext context) => GetEmail(),
            '/removeFavorite': (BuildContext context) => AddFavorite(
                  choose: false,
                ),
          },
          home: FutureBuilder(
            future: AuthMethod().currentUser(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                return MainHomeScreen(
                  pageControl: 0,
                );
              } else {
                return LoginScreen();
              }
            },
          ),
        );
      }),
    );
  }
}
