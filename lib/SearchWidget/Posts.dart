import 'package:flutter/material.dart';

///other class package
import 'package:insta_clone/HomeScreen/Photo/DisplayImage.dart';
import 'package:insta_clone/Json/photoJson.dart';

class Posts extends StatefulWidget {
  final List<UserPhoto> photo;
  const Posts({
    Key? key,
    required this.photo,
  }) : super(key: key);

  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Theme.of(context).backgroundColor,
        ),
        title: Text(
          'Posts',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).backgroundColor),
        ),
      ),
      body: buildImage(),
    );
  }

  buildImage() {
    return widget.photo.length <= 0
        ? Center(
            child: Text("No Saved Image"),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemCount: widget.photo.length,
            itemBuilder: (context, int index) {
              return Padding(
                padding: EdgeInsets.only(
                  top: 5,
                ),
                child: DisplayImage(
                  userPhoto: widget.photo[index],
                  state: false,
                ),
              );
            },
          );
  }
}
