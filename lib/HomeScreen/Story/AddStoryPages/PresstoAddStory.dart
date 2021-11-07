import 'package:flutter/material.dart';

class AddStory extends StatefulWidget {
  final VoidCallback onClicked;
  final ValueChanged<String> onChanged;
  final String? text;
  const AddStory(
      {required this.onClicked,
      required this.text,
      required this.onChanged,
      Key? key})
      : super(key: key);

  @override
  _AddStoryState createState() => _AddStoryState();
}

class _AddStoryState extends State<AddStory> {
  TextEditingController? storyCaptionController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    storyCaptionController = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    storyCaptionController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 5,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 5.0,
                ),
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        //focusNode: widget.focusNode,
                        textCapitalization: TextCapitalization.sentences,
                        autocorrect: true,
                        enableSuggestions: true,
                        decoration: InputDecoration(
                          enabledBorder: new OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            borderSide: new BorderSide(color: Colors.green),
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).scaffoldBackgroundColor ==
                                      Colors.white
                                  ? Colors.grey[100]
                                  : Colors.black26,
                          hintText: 'Add caption',
                        ),
                        controller: storyCaptionController,
                        onChanged: widget.onChanged,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                GestureDetector(
                  onTap: widget.onClicked,
                  child: Center(
                      child: Container(
                    child: Icon(
                      Icons.send,
                      size: 35,
                      color: Colors.blue,
                    ),
                  )),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
