import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photosharing/view/login/components/credentials.dart';
import 'package:photosharing/view/login/components/heading.dart';
import 'package:photosharing/view/widgets/inputfield.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.green, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Heading(),
              Credentials(),
            ],
          ),
        )),
      ),
    );
  }
}
