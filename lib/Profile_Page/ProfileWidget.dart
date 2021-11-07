import 'package:flutter/material.dart';

///image
import 'package:insta_clone/images.dart';

class ProfileWidget extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onClicked;
  final bool editingState;
  const ProfileWidget({
    this.imagePath,
    required this.onClicked,
    required this.editingState,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          buildImage(),
          Positioned(
            bottom: 0,
            right: 4,
            child: buildEditIcon(context),
          ),
        ],
      ),
    );
  }

  ///to display image
  Widget buildImage() {
    return GestureDetector(
      child: ClipOval(
          child: ImagesWidget(image: imagePath, width: 100.0, height: 100.0)),
      onTap: onClicked,
    );
  }

  imageWidget({String? image, double? height, double? width}) {
    return ClipOval(
        child: ImagesWidget(image: image, width: width, height: height));
  }

  ///to display icon on image
  Widget buildEditIcon(BuildContext context) {
    return buildCircle(
        child: buildCircle(
            child: Icon(
              editingState ? Icons.add_a_photo : Icons.add,
              color: Colors.white,
            ),
            all: 4,
            color: Colors.blue),
        all: 2,
        color: Theme.of(context).scaffoldBackgroundColor);
  }

  ///build circle for icon
  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) {
    return ClipOval(
      child: Container(
        padding: EdgeInsets.all(all),
        color: color,
        child: child,
      ),
    );
  }
}
