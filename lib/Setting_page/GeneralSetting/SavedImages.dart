import 'package:flutter/material.dart';

///image
import 'package:insta_clone/images.dart';

///scroll to particular index
import 'package:scroll_to_index/scroll_to_index.dart';

///other class package
import 'package:insta_clone/HomeScreen/Photo/DisplayImage.dart';
import 'package:insta_clone/Json/SaveImageJson.dart';
import 'package:insta_clone/Json/photoJson.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';

class SaveImages extends StatefulWidget {
  const SaveImages({Key? key}) : super(key: key);

  @override
  _SaveImagesState createState() => _SaveImagesState();
}

class _SaveImagesState extends State<SaveImages> {
  String? myUid;
  List<SaveImageJson>? saveImage = [];
  List<UserPhoto>? photo = [];
  bool isMethod = true;
  late AutoScrollController controller;
  final scrollDirection = Axis.vertical;

  getValue() async {
    if (this.mounted) {
      myUid = await SharedPreferencesHelper().getUserUid();
      saveImage = await SharedPreferencesHelper().getSaveImage();
      for (var element in saveImage!) {
        UserPhoto userPhoto = await FirebaseApi()
            .getSinglePhoto(userId: element.userUid, photoId: element.docId);
        photo!.add(userPhoto);
      }
      setState(() {});
    }
  }

  buildOnLaunch() async {
    await getValue();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    buildOnLaunch();
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Saved Images'),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: isMethod ? buildGridImage() : buildImage(),
      ),
    );
  }

  buildGridImage() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: saveImage!.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GridView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150,
                crossAxisSpacing: 1.0,
                mainAxisSpacing: 2.0,
              ),
              itemCount: photo!.length,
              itemBuilder: (BuildContext context, index) {
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    child: displayImage(photo![index], index),
                  ),
                );
              },
            ),
    );
  }

  displayImage(UserPhoto? image, index) {
    return GestureDetector(
      onTap: () async {
        await _scrollToIndex(index);
        setState(() {
          isMethod = false;
        });
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

  buildImage() {
    return photo!.length <= 0
        ? Center(
            child: Text("No Saved Image"),
          )
        : ListView.builder(
            shrinkWrap: true,
            scrollDirection: scrollDirection,
            controller: controller,
            physics: ScrollPhysics(),
            itemCount: photo!.length,
            itemBuilder: (context, int index) {
              return Padding(
                padding: EdgeInsets.only(
                  top: 5,
                ),
                child: DisplayImage(
                  userPhoto: photo![index],
                  state: false,
                ),
              );
            },
          );
  }

  Future _scrollToIndex(index) async {
    await controller.scrollToIndex(index,
        preferPosition: AutoScrollPosition.begin);
  }
}
