import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class Heading extends StatelessWidget {
  const Heading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          SizedBox(
            height: size.height * 0.05,
          ),
          Center(
            child: Text(
              "PhotoSharing App",
              style: TextStyle(
                  fontSize: 55,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Myfont'),
            ),
          ),
          SizedBox(
            height: size.height * 0.05,
          ),
          Center(
            child: Text("Login",
                style: TextStyle(
                    fontSize: 45,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
