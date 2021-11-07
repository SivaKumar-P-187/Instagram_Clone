import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  //Error Dialogs
  Future errorDialog(BuildContext context, e) {
    return showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text('Error'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 100.0,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
                child: Center(
                  child: Text(
                    e.toString(),
                  ),
                ),
              ),
              Container(
                height: 50.0,
                child: Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Ok'))
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
            onWillPop: () async => false,
            child: SimpleDialog(
              key: key,
              backgroundColor: Colors.black54,
              children: <Widget>[
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Please Wait....",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<bool?> showWarningDialog(BuildContext context) async => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Changes on this page will not be saved'),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text('Cancel')),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text('Discard'))
          ],
        ),
      );
}
