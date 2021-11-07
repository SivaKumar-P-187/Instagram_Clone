///other class packages
import 'package:flutter/material.dart';
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/HomeScreen/Photo/DisplayUserInfo.dart';

class TopScreen extends StatefulWidget {
  final List<dynamic> usersUid;
  final String? title;
  const TopScreen({
    Key? key,
    required this.usersUid,
    required this.title,
  }) : super(key: key);

  @override
  _TopScreenState createState() => _TopScreenState();
}

class _TopScreenState extends State<TopScreen> {
  List<Users> users = [];
  List<Users> queryResultSet = [];
  List<Users> setQueryName = [];
  List<Users> tempQueryName = [];
  String? valuesName;
  bool isSearching = false;
  String? myName;
  List<String>? following = [];
  TextEditingController textEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            valuesName = '';
            isSearching = false;
            textEditingController.text = '';
            setState(() {});
            Navigator.of(context).pop();
          },
          color: Theme.of(context).backgroundColor,
        ),
        title: Text(
          "${widget.title}",
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
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

  topScreen() {
    return Row(
      children: [
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

  Widget getFollowingDetails() {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: StreamBuilder<List<Users>>(
        stream: FirebaseApi().getLikesInfo(widget.usersUid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            setQueryName = [];
            queryResultSet = snapshot.data!;
            setQueryName = queryResultSet;
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

  emptyUserList() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Text('No User Found'),
      ),
    );
  }

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
          ? ListView.builder(
              itemCount: tempQueryName.length,
              itemBuilder: (context, int index) {
                return DisplaySingleInfo(
                  user: tempQueryName[index],
                );
              },
            )
          : Center(
              child: Text('No User Found'),
            ),
    );
  }
}
