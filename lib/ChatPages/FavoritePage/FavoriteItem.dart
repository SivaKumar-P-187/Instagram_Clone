import 'package:flutter/material.dart';

///other class package
import 'package:insta_clone/handlers/MenuIconHandler.dart';

class Menu {
  static final List<MenuItem> itemFirst = [
    addFavorite,
    removeFavoritesItem,
  ];
  static const addFavorite = MenuItem(
    title: 'Add',
    icon: Icons.add,
  );
  static const removeFavoritesItem = MenuItem(
    title: 'Remove',
    icon: Icons.remove,
  );
}

class Menu1 {
  static final List<MenuItem> itemFirst = [
    deleteStory,
    shareStory,
  ];
  static const deleteStory = MenuItem(
    title: 'Delete',
    icon: Icons.delete,
  );
  static const shareStory = MenuItem(
    title: 'Share',
    icon: Icons.share,
  );
}
