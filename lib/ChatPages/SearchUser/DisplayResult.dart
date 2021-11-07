///To display search result of current user

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///other class package
import 'package:insta_clone/ChatPages/FavoritePage/AddFavorite.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/ChatPages/SearchUser/DisplaySingleUserInfo.dart';
import 'package:insta_clone/ChatPages/SearchUser/DisplayAllUserList.dart';

class SearchResult extends StatefulWidget {
  final String? myNickName;
  final List<String>? following;
  const SearchResult({this.myNickName, this.following, Key? key})
      : super(key: key);

  @override
  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  bool isSearching = false;
  String? valuesName;
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
                  child: ListView(
                    primary: false,
                    shrinkWrap: true,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: isSearching == true
                            ? instantSearch(valuesName)
                            : getFollowingDetails(),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  ///App Bar
  topScreen() {
    return Row(
      children: [
        BackButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            valuesName = '';
            isSearching = false;
            textEditingController.text = '';
            setState(() {});
            Navigator.of(context).pop();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AddFavorite(),
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
                setState(() {
                  valuesName = val;
                });
                instantSearch(valuesName);
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

  ///to perform search with following users
  Widget getFollowingDetails() {
    return Container(
      height: MediaQuery.of(context).size.height,
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
                    return DisplaySingleInfo(
                      user: setQueryName[index],
                    );
                  })
              : emptyUserList();
        },
      ),
    );
  }

  ///search user with nick name
  instantSearch(value) {
    tempQueryName = [];
    setState(() {});
    setQueryName.forEach((element) {
      if (element.displayName!
          .toLowerCase()
          .startsWith(value!.toString().toLowerCase())) {
        setState(() {
          isSearching = true;
          tempQueryName.add(element);
        });
      }
    });
    return Container(
      height: MediaQuery.of(context).size.height - 200,
      width: MediaQuery.of(context).size.width,
      child: tempQueryName.isNotEmpty
          ? DisplayAllUser(
              user: tempQueryName,
            )
          : Center(
              child: Text('No User Found'),
            ),
    );
  }

  ///If search result is empty
  ///If search result is empty
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
