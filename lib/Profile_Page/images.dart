import 'package:flutter/material.dart';

///firebase package
import 'package:cloud_firestore/cloud_firestore.dart';

///other class package
import 'package:insta_clone/Json/photoJson.dart';
import 'package:insta_clone/SearchWidget/Posts.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/images.dart';

class Photos extends StatefulWidget {
  final List<UserPhoto> photo;
  final String? userUid;
  const Photos({
    required this.photo,
    required this.userUid,
    Key? key,
  }) : super(key: key);

  @override
  _PhotosState createState() => _PhotosState();
}

class _PhotosState extends State<Photos> {
  bool isMethod = true;
  String? myUid;
  final scrollDirection = Axis.vertical;
  final List<UserPhoto> photo = [];

  getValue() async {
    if (this.mounted) {
      myUid = await SharedPreferencesHelper().getUserUid();
      setState(() {});
    }
  }

  buildOnLaunch() async {
    await getValue();
  }

  @override
  void initState() {
    // TODO: implement initState
    buildOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('usersPhoto')
            .doc(widget.userUid)
            .collection('Photo')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            photo.clear();
            snapshot.data!.docs.forEach((element) {
              Map<String, dynamic> tempMap =
                  element.data() as Map<String, dynamic>;
              photo.add(UserPhoto.fromJson(tempMap));
            });
            return GridView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150,
                crossAxisSpacing: 1.0,
                mainAxisSpacing: 2.0,
              ),
              itemCount: photo.length,
              itemBuilder: (BuildContext ctx, index) {
                return Container(
                  child: displayImage(photo[index]),
                );
              },
            );
          }
          return Container();
        });
  }

  displayImage(UserPhoto? image) {
    return GestureDetector(
      onTap: () {
        if (myUid != widget.userUid) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Posts(photo: photo),
            ),
          );
        }
      },
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
            color: Colors.amber, borderRadius: BorderRadius.circular(15)),
        child: ImagesWidget(
            image: image!.imagePhotoUrl!, width: 100.0, height: 100.0),
      ),
    );
  }
}
