import 'package:flutter/material.dart';
import 'package:photosharing/view/widgets/textfieldContainer.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextEditingController editingController;
  const InputField({
    Key? key,
    required this.hintText,
    required this.icon,
    required this.obscureText,
    required this.editingController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        cursorColor: Colors.black,
        obscureText: obscureText,
        controller: editingController,
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            helperStyle: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            prefixIcon: Icon(
              icon,
              color: Colors.black,
              size: 20,
            )),
      ),
    );
  }
}
