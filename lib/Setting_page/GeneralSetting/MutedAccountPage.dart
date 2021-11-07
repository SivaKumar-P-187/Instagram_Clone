import 'package:flutter/material.dart';

///firebase
import 'package:cloud_firestore/cloud_firestore.dart';

///other class
import 'package:insta_clone/Json/userJson.dart';
import 'package:insta_clone/Json/utils.dart';
import 'package:insta_clone/SearchWidget/profilepage.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/images.dart';

class MutedAccounts extends StatefulWidget {
  const MutedAccounts({Key? key}) : super(key: key);

  @override
  _MutedAccountsState createState() => _MutedAccountsState();
}

class _MutedAccountsState extends State<MutedAccounts> {
  List<String>? muteUser = [];
  List<Users> users = [];
  Users? user;
  String? myUid;

  getValue() async {
    if (this.mounted) {
      myUid = await SharedPreferencesHelper().getUserUid();
      muteUser = await SharedPreferencesHelper().getUserMute();
      setState(() {});
    }
  }

  buildOnLaunch() async {
    await getValue();
  }

  @override
  void initState() {
    buildOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Muted Account'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: getMutedUserDetails(),
      ),
    );
  }

  getMutedUserDetails() {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('users').doc(myUid).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          Map<String, dynamic> temp =
              snapshot.data!.data() as Map<String, dynamic>;
          user = Users.fromJson(temp);
          return user!.muteList!.isNotEmpty
              ? StreamBuilder<List<Users>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where("userUid", whereIn: user!.muteList)
                      .snapshots()
                      .transform(Utils.transformer(Users.fromJson).cast()),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      users = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: users.length,
                        itemBuilder: (context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 5, right: 5, bottom: 5),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).backgroundColor,
                                    blurRadius: 1.0,
                                    spreadRadius: 0.0,
                                    offset: Offset(1.0, 1.0),
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ProfilePage(
                                        displayName: users[index].displayName,
                                        userUid: users[index].userUid,
                                        myUid: myUid!,
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(10),
                                          child: imageWidget(
                                              users[index].photoUrl),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                          users[index].displayName!,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .backgroundColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: ElevatedButton(
                                          onPressed: () async {
                                            muteUser!
                                                .remove(users[index].userUid);
                                            await SharedPreferencesHelper()
                                                .setUserMute(muteUser);
                                            await FirebaseApi()
                                                .updateUserMuteList(
                                                    myUid: myUid,
                                                    muteList: muteUser);
                                          },
                                          child: Text('UN MUTE')),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return Container();
                  },
                )
              : Center(
                  child: Container(
                    child: Text(
                      'No Account is Muted',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Theme.of(context).backgroundColor,
                      ),
                    ),
                  ),
                );
        }
        return Container();
      },
    );
  }

  imageWidget(String? image) {
    return ClipOval(
      child: ImagesWidget(image: image!, width: 50.0, height: 50.0),
    );
  }
}
