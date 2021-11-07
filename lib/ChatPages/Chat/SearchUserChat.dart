///to build search tile to search user to move to chat room

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///other class packages
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/MainHomeScreen.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';

import 'SearchDisplay.dart';

class SearchResultChat extends StatefulWidget {
  final String? myNickName;
  final List<String>? following;
  const SearchResultChat({this.myNickName, this.following, Key? key})
      : super(key: key);

  @override
  _SearchResultChatState createState() => _SearchResultChatState();
}

class _SearchResultChatState extends State<SearchResultChat> {
  bool isSearching = false;
  String? valuesName = '';
  List<Users> queryResultSet = [];
  List<Users> setQueryName = [];
  List<Users> tempQueryName = [];
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: topScreen(),
            ),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: textEditingController.text.length > 0
                    ? tempQueryName.length > 0
                        ? ListView.builder(
                            itemCount: tempQueryName.length,
                            itemBuilder: (context, int index) {
                              return SearchDisplay(
                                user: tempQueryName[index],
                              );
                            })
                        : emptyUserList()
                    : getFollowingDetails(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  topScreen() {
    return Row(
      children: [
        BackButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MainHomeScreen(
                  pageControl: 2,
                ),
              ),
            );
          },
          color: Theme.of(context).backgroundColor,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 5, left: 0),
            child: TextField(
              controller: textEditingController,
              onChanged: (val) {
                valuesName = val;
                setState(() {});
                instantSearch();
              },
              decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    size: 30,
                  ),
                  contentPadding: EdgeInsets.only(left: 25.0),
                  hintText: 'Search',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0))),
            ),
          ),
        ),
      ],
    );
  }

  Widget getFollowingDetails() {
    return Container(
      child: StreamBuilder<List<Users>>(
        stream: FirebaseApi().getAllUserInfo(widget.myNickName!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            setQueryName = [];
            queryResultSet = snapshot.data!;
            queryResultSet.forEach((element) {
              if (widget.following!.contains(element.userUid)) {
                setQueryName.add(element);
              }
            });
          }
          return setQueryName.length > 0
              ? ListView.builder(
                  itemCount: setQueryName.length,
                  itemBuilder: (context, int index) {
                    return SearchDisplay(
                      user: setQueryName[index],
                    );
                  })
              : emptyUserList();
        },
      ),
    );
  }

  ///search user with nick name
  instantSearch() {
    tempQueryName = [];
    isSearching = true;
    setState(() {});
    setQueryName.forEach((element) {
      if (element.displayName!
          .toLowerCase()
          .startsWith(valuesName!.toLowerCase())) {
        setState(() {
          isSearching = true;
          tempQueryName.add(element);
        });
      }
    });
  }

  ///if search user is not present
  emptyUserList() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Text('No User Found'),
      ),
    );
  }
}
