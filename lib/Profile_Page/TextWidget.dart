import 'package:flutter/material.dart';

class TextEditing extends StatefulWidget {
  final String label;
  final String text;
  final int maxLine;
  final ValueChanged<String> onChanged;
  final ValueChanged<String?> onSaved;
  final FormFieldValidator<String>? validator;
  const TextEditing({
    Key? key,
    required this.label,
    required this.text,
    required this.maxLine,
    required this.onChanged,
    required this.onSaved,
    required this.validator,
  }) : super(key: key);

  @override
  _TextEditingState createState() => _TextEditingState();
}

class _TextEditingState extends State<TextEditing> {
  late final TextEditingController controller;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    controller = TextEditingController(text: widget.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 28.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          TextFormField(
            controller: controller,
            maxLines: widget.maxLine,
            keyboardType: widget.maxLine == 5
                ? TextInputType.multiline
                : TextInputType.name,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onChanged: widget.onChanged,
            onSaved: widget.onSaved,
            validator: widget.validator,
          ),
        ],
      ),
    );
  }
}
