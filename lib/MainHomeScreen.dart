import 'package:flutter/material.dart';

///bottom navigation bar
import 'package:bottom_navy_bar/bottom_navy_bar.dart';

///other class packages
import 'package:insta_clone/ChatPages/MainHome.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/HomeScreen/HomeScreen.dart';
import 'package:insta_clone/SearchWidget/SearchUsers.dart';
import 'package:insta_clone/Setting_page/Setting_page.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';

class MainHomeScreen extends StatefulWidget {
  final int? pageControl;
  const MainHomeScreen({this.pageControl, Key? key}) : super(key: key);

  @override
  _MainHomeScreenState createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int index = 0;
  List<String>? followingUid;
  late PageController _pageController =
      PageController(initialPage: widget.pageControl!);
  List<Widget> _screen = [
    HomeScreen(),
    SearchUsers(),
    MainHomeChatScreen(),
    SettingPage(),
  ];
  buildOnLaunch() async {
    if (widget.pageControl != null) {
      index = widget.pageControl!;
      onPageChanged(widget.pageControl!);
    }
    await getValue();
    setState(() {});
  }

  getValue() async {
    followingUid = await SharedPreferencesHelper().getUserFollowing();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    buildOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: PageView(
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: _screen,
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        backgroundColor: Colors.black,
        containerHeight: 60,
        itemCornerRadius: 16,
        onItemSelected: onPageTab,
        selectedIndex: index,
        items: [
          BottomNavyBarItem(
            icon: Icon(Icons.home),
            textAlign: TextAlign.center,
            activeColor: Colors.green,
            inactiveColor: Colors.grey,
            title: Text('Home'),
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.search),
            textAlign: TextAlign.center,
            activeColor: Colors.deepOrangeAccent,
            inactiveColor: Colors.grey,
            title: Text('Search'),
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.chat),
            textAlign: TextAlign.center,
            activeColor: Colors.pink,
            inactiveColor: Colors.grey,
            title: Text('Chat'),
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.settings),
            textAlign: TextAlign.center,
            activeColor: Colors.lightBlueAccent,
            inactiveColor: Colors.grey,
            title: Text('Settings'),
          ),
        ],
      ),
    );
  }

  void onPageChanged(int selectedIndex) {
    setState(() {
      index = selectedIndex;
    });
  }

  void onPageTab(int value) {
    setState(() {
      _pageController.jumpToPage(value);
    });
  }
}
