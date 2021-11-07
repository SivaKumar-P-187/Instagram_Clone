import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

ThemeData lightBasicTheme(BuildContext context) {
  TextTheme _textBasicTheme(TextTheme base) {
    return base.copyWith(
      ///app bar user display name in profile page
      headline1: base.headline1!.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 22.0,
      ),

      ///displaying list of user display name in list
      headline2: base.headline2!.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 20.0,
      ),

      ///display list of user user name in list
      headline3: base.headline3!.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 16.0,
      ),
    );
  }

  final ThemeData base = ThemeData.light();
  return base.copyWith(
    colorScheme: ColorScheme.light(),
    popupMenuTheme: PopupMenuThemeData(color: Colors.white),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.blue),
    primaryColor: Colors.white,
    brightness: Brightness.light,
    disabledColor: Colors.grey,
    backgroundColor: Colors.black,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        onPrimary: Colors.white,
        primary: Colors.blue,
      ),
    ),
    buttonTheme: Theme.of(context)
        .buttonTheme
        .copyWith(colorScheme: ColorScheme.light(), buttonColor: Colors.blue),
    appBarTheme: AppBarTheme(
      color: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
      iconTheme: IconThemeData(color: Colors.black),
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: _textBasicTheme(base.textTheme),
    cardTheme: CardTheme(
      color: Colors.black87,
    ),
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
  );
}

ThemeData darkBasicTheme(BuildContext context) {
  TextTheme _textBasicTheme(TextTheme base) {
    return base.copyWith(
      ///app bar user display name in profile page
      headline1: base.headline1!.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22.0,
      ),

      ///displaying list of user display name in list
      headline2: base.headline2!.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20.0,
      ),

      ///display list of user user name in list
      headline3: base.headline3!.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16.0,
      ),
    );
  }

  final ThemeData base = ThemeData.dark();
  return base.copyWith(
    colorScheme: ColorScheme.dark(),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.white),
    popupMenuTheme: PopupMenuThemeData(color: Colors.grey.shade900),
    canvasColor: Colors.black,
    primaryColor: Colors.black,
    brightness: Brightness.dark,
    disabledColor: Colors.grey,
    backgroundColor: Colors.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        onPrimary: Colors.black,
        primary: Colors.blue,
      ),
    ),
    buttonTheme: Theme.of(context)
        .buttonTheme
        .copyWith(colorScheme: ColorScheme.dark(), buttonColor: Colors.blue),
    appBarTheme: AppBarTheme(
      color: Colors.black,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    scaffoldBackgroundColor: Colors.black,
    textTheme: _textBasicTheme(base.textTheme),
    cardTheme: CardTheme(
      color: Colors.white60,
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
  );
}
