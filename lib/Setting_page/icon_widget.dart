import 'package:flutter/material.dart';

///image
import 'package:insta_clone/images.dart';

///TO DISPLAY ICON FOR EVERY SETTINGS
class IconWidget extends StatelessWidget {
  final IconData icon;
  final Color color;

  const IconWidget({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(7),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Icon(
        icon,
        color: Colors.white,
      ),
    );
  }
}

///to display profile photo of current user
class ProfilePhoto extends StatelessWidget {
  final String profile;

  const ProfilePhoto({
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return imageWidget(
      image: profile,
      height: 90.toDouble(),
      width: 90.toDouble(),
    );
  }

  imageWidget({String? image, double? height, width}) {
    return ClipOval(
      child: ImagesWidget(image: image, width: width, height: height),
    );
  }
}
