import 'package:flutter/material.dart';

///other class package
import 'package:insta_clone/SearchWidget/DisplayAllUserList.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';

class SearchUsers extends StatefulWidget {
  const SearchUsers({Key? key}) : super(key: key);

  @override
  _SearchUsersState createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  String? myNickName;
  String? valuesName;
  bool isSearching = false;
  TextEditingController textEditingController = TextEditingController();
  List<Users>? queryResultSet = [];
  List<Users>? tempSearchStore = [];

  ///search user with nick name
  instantSearch(value) {
    tempSearchStore = [];
    setState(() {});
    queryResultSet!.forEach((element) {
      if (element.displayName!
          .toLowerCase()
          .startsWith(value.toString().toLowerCase())) {
        setState(() {
          isSearching = true;
          tempSearchStore!.add(element);
        });
      }
    });
    return Container(
      height: MediaQuery.of(context).size.height - 200,
      width: MediaQuery.of(context).size.width,
      child: tempSearchStore!.isNotEmpty
          ? DisplayAllUser(
              user: tempSearchStore,
            )
          : Center(
              child: Text('No User Found'),
            ),
    );
  }

  ///search bar
  topScreen() {
    return Row(
      children: [
        isSearching == true
            ? GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  textEditingController.text = '';
                  isSearching = false;
                  valuesName = '';
                  setState(() {});
                },
                child: Icon(
                  Icons.arrow_back,
                  size: 30,
                ),
              )
            : Container(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 5, left: 5),
            child: TextField(
              controller: textEditingController,
              onChanged: (val) {
                valuesName = val;
                setState(() {});
                instantSearch(valuesName);
              },
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  size: 30,
                ),
                contentPadding: EdgeInsets.only(left: 25.0),
                hintText: 'Search by Nick Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  ///to display get all user info

  getAllUser(String nickName) {
    if (myNickName!.isNotEmpty)
      return StreamBuilder<List<Users>>(
          stream: FirebaseApi().getAllUserInfo(nickName),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              queryResultSet = snapshot.data;
              return Container(
                height: MediaQuery.of(context).size.height - 200,
                width: MediaQuery.of(context).size.width,
                child: DisplayAllUser(
                  user: queryResultSet,
                ),
              );
            } else {
              return Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          });
  }

  getInitialValue() async {
    if (this.mounted) {
      myNickName = await SharedPreferencesHelper().getUserDisplayName();
      setState(() {});
    }
  }

  ///build On Launch
  buildOnLaunch() async {
    await getInitialValue();
  }

  @override
  void initState() {
    buildOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    myNickName != null
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: isSearching == true
                                ? instantSearch(valuesName)
                                : getAllUser(myNickName!),
                          )
                        : Container(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
