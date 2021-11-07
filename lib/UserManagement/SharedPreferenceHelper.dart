import 'dart:convert';

///shared preferences package
import 'package:shared_preferences/shared_preferences.dart';

///other class packages
import 'package:insta_clone/Json/StoryJson.dart';
import 'package:insta_clone/Json/photoJson.dart';
import 'package:insta_clone/Json/SaveImageJson.dart';

class SharedPreferencesHelper {
  static final userUidKey = "UserUidKey";
  static final userNameKey = "UserNameKey";
  static final userDisplayNameKey = "UserDisplayNameKey";
  static final userPhotoUrlKey = "UserPhotoUrlKey";
  static final userAboutKey = "UserAboutKey";
  static final userGoogleLogin = "UserGoogleLogin";
  static final userFollowingKey = "UserFollowingKey";
  static final userFavoriteKey = "UserFavoriteKey";
  static final userStoryKey = "UserStoryKey";
  static final userStoryTempKey = "UserStoryTempKey";
  static final userPhotoTempKey = "UserPhotoTempKey";
  static const THEME_STATUS = "THEMESTATUS";
  static final userMuteUsers = "UsersMuteFollowingUsers";
  static final userSaveImage = "UserSaveImage";

  setDarkTheme(bool value) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool(THEME_STATUS, value);
  }

  Future<bool> getTheme() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(THEME_STATUS) ?? false;
  }

  ///set shared preference key values


  Future<bool> setUserUid(String uid) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(userUidKey, uid);
  }

  Future<bool> setUserName(String name) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(userNameKey, name);
  }

  Future<bool> setUserDisplayName(String name) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(userDisplayNameKey, name);
  }

  Future<bool> setUserPhotoUrl(String photoUrl) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(userPhotoUrlKey, photoUrl);
  }

  Future<bool> setUserAbout(String about) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(userAboutKey, about);
  }

  Future<bool> setUserGoogleLogin(String loginInfo) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(userGoogleLogin, loginInfo);
  }

  Future<bool> setUserFollowing(List<dynamic>? following) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> strList = following!.map((i) => i.toString()).toList();
    return preferences.setStringList(userFollowingKey, strList);
  }

  Future<bool> setUserMute(List<dynamic>? following) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> strList = following!.map((i) => i.toString()).toList();
    return preferences.setStringList(userMuteUsers, strList);
  }

  Future<bool> setUserFavorite(List<dynamic>? following) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> strList = following!.map((i) => i.toString()).toList();
    return preferences.setStringList(userFavoriteKey, strList);
  }

  Future<bool> setUserStoryFinal(List<Story>? story) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String story1 = encode(story!);
    return preferences.setString(userStoryKey, story1);
  }

  static String encode(List<Story> story) => json.encode(
      story.map<Map<String, dynamic>>((story1) => story1.toJson()).toList());
  static String encode1(List<SaveImageJson> story) => json.encode(
      story.map<Map<String, dynamic>>((story1) => story1.toJson()).toList());

  Future<bool> setUserTempStoryKey(Story? story) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String? storyString = jsonEncode(story);
    return preferences.setString(userStoryTempKey, storyString);
  }

  Future<bool> setUserTempPhotoKey(UserPhoto? userPhoto) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String? photoString = jsonEncode(userPhoto);
    return preferences.setString(userPhotoTempKey, photoString);
  }

  Future<bool> saveImage(List<SaveImageJson>? images) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String story1 = encode1(images!);
    return preferences.setString(userSaveImage, story1);
  }

  ///to get value
  Future<String?> getUserUid() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(userUidKey);
  }

  Future<String?> getUserName() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(userNameKey);
  }

  Future<String?> getUserDisplayName() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(userDisplayNameKey);
  }

  Future<String?> getUserPhotoUrl() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(userPhotoUrlKey);
  }

  Future<String?> getUserAbout() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(userAboutKey);
  }

  Future<String?> getUserGoogleLogin() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(userGoogleLogin);
  }

  Future<List<String>?> getUserFollowing() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String>? savedStrList = preferences.getStringList(userFollowingKey);
    if (savedStrList != null)
      return savedStrList;
    else
      return [];
  }

  Future<List<String>?> getUserMute() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String>? savedStrList = preferences.getStringList(userMuteUsers);
    if (savedStrList != null)
      return savedStrList;
    else
      return [];
  }

  Future<List<String>?> getUserFavorite() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String>? savedStrList = preferences.getStringList(userFavoriteKey);
    if (savedStrList != null)
      return savedStrList;
    else
      return [];
  }

  Future getUserStoryFinal() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? story1 = preferences.getString(userStoryKey);
    if (story1 != null) {
      final List<Story>? story = decode(story1);
      return story;
    }
    return;
  }

  static List<Story>? decode(String story1) =>
      (json.decode(story1) as List<dynamic>)
          .map<Story>((item) => Story.fromJson(item))
          .toList();
  static List<SaveImageJson>? decode1(String images) =>
      (json.decode(images) as List<dynamic>)
          .map<SaveImageJson>((item) => SaveImageJson.fromJson(item))
          .toList();

  Future getTempStory() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? story1 = preferences.getString(userStoryTempKey);
    if (story1 != null) {
      Story? story = Story.fromJson(jsonDecode(story1));
      return story;
    }
    return;
  }

  Future getTempPhoto() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? photo1 = preferences.getString(userPhotoTempKey);
    if (photo1 != null) {
      UserPhoto? photo = UserPhoto.fromJson(jsonDecode(photo1));
      return photo;
    }
    return;
  }


  Future<List<SaveImageJson>?> getSaveImage() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? userPhoto = preferences.getString(userSaveImage);
    if (userPhoto != null) {
      final List<SaveImageJson>? photo = decode1(userPhoto);
      return photo;
    }
    return [];
  }

  ///remove the value
  Future removeTempStory() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(userStoryTempKey);
  }

  Future removeTempPhoto() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(userPhotoTempKey);
  }
}
