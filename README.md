# insta_clone

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

used packages:
///firebase package
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

///google sign_in package
import 'package:google_sign_in/google_sign_in.dart';

///font package
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

///picker
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_clone/theme.dart';

///local storage
import 'package:shared_preferences/shared_preferences.dart';

///image
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:carousel_slider/carousel_slider.dart';

///provider
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

///random string generator
import 'package:random_string/random_string.dart';

///animating icon
import 'package:animate_icons/animate_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

///date format
import 'package:intl/intl.dart';

///setting screen
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:list_tile_switch/list_tile_switch.dart';

///bottom navigation bar
import 'package:bottom_navy_bar/bottom_navy_bar.dart';

///story
import 'package:story_view/story_view.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

///share
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
