import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///picker
import 'package:file_picker/file_picker.dart';

///firebase
import 'package:firebase_storage/firebase_storage.dart';

///other class
import 'package:insta_clone/Json/reportjson.dart';
import 'package:insta_clone/MainHomeScreen.dart';
import 'package:insta_clone/UserManagement/DataBase.dart';
import 'package:insta_clone/UserManagement/SharedPreferenceHelper.dart';
import 'package:insta_clone/handlers/ErrorHandler.dart';
import 'package:insta_clone/images.dart';

class Report extends StatefulWidget {
  const Report({Key? key}) : super(key: key);

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final formKey = GlobalKey<FormState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  String? myUid;
  String? myName;
  String? problem;
  List<String> imageArray = [];
  String? image;
  File? file;
  UploadTask? task;
  bool inProcess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(
          'Report a Problem',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
              color: Theme.of(context).backgroundColor),
        ),
        centerTitle: true,
        elevation: 2,
        actions: [
          MaterialButton(
            onPressed: () async {
              await buildSubmit();
            },
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Text(
              'Submit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText:
                              "Briefly explain what happened or what's not working",
                          hintStyle: TextStyle(
                            color: Theme.of(context).backgroundColor,
                            fontSize: 15.0,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            problem = value;
                          });
                        },
                        textAlign: TextAlign.justify,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      buildImage(),
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: OutlinedButton(
                          onLongPress: () async {
                            if (task != null) {
                              task!.cancel();
                              inProcess = false;
                              setState(() {});
                            }
                          },
                          onPressed: () async {
                            await getImage();
                          },
                          child: inProcess == true
                              ? buildUploadStatus(task!)
                              : Text(
                                  'Gallery',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    fontSize: 25.0,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Please only leave feedback about Instagram and features.Visit our Help center to learn about reporting content posted on Instagram that violates our Community Guidelines,like abuse,spam or intellectual property violations.All reports are subject to our Terms of Use.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Theme.of(context).backgroundColor,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildImage() {
    return imageArray.length > 0
        ? Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Image:",
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).backgroundColor),
                ),
                SizedBox(
                  height: 10.0,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: imageArray.length,
                  itemBuilder: (context, int index) {
                    return Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildImageFinal(imageArray[index]),
                            GestureDetector(
                              onTap: () {
                                imageArray.remove(imageArray[index]);
                                setState(() {});
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).backgroundColor,
                                  ),
                                ),
                                child: Icon(
                                  Icons.clear,
                                  color: Theme.of(context).backgroundColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          )
        : SizedBox.shrink();
  }

  getImage() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    final fileName = result.files.single.path;
    setState(() {
      file = File(fileName!);
    });
    if (file == null) return;
    final fileNames = file!.path.split('/').last;
    final destination = 'Report/$fileNames';
    try {
      final ref = FirebaseStorage.instance.ref(destination);
      task = ref.putFile(File(file!.path));
      inProcess = true;
      setState(() {});
    } on FirebaseException catch (e) {
      inProcess = false;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message.toString()),
        ),
      );
    }
    if (task != null) {
      final snapshot = await task!.whenComplete(() {
        inProcess = false;
        setState(() {});
      });
      image = await snapshot.ref.getDownloadURL();
      imageArray.add(image!);
      setState(() {});
    }
  }

  buildUploadStatus(UploadTask task) {
    return StreamBuilder<TaskSnapshot>(
      stream: task.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Uploading...",
                    style: TextStyle(
                      color: Theme.of(context).backgroundColor,
                    ),
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  buildSubmit() async {
    Dialogs.showLoadingDialog(context, _keyLoader);
    myUid = await SharedPreferencesHelper().getUserUid();
    myName = await SharedPreferencesHelper().getUserDisplayName();
    setState(() {});
    final report = ReportBug(
      userUid: myUid,
      userName: myName,
      error: problem,
      time: DateTime.now(),
      image: imageArray,
    ).toJson();
    await FirebaseApi().addNewReport(report).whenComplete(
      () {
        Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainHomeScreen(
              pageControl: 3,
            ),
          ),
        );
      },
    );
  }

  buildImageFinal(String image) {
    return ClipOval(
      child: ImagesWidget(image: image, width: 50.0, height: 50.0),
    );
  }
}
