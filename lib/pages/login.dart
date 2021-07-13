import 'dart:ui';

import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter/material.dart';
import 'package:mint_messenger/services/auth.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: Column(children: [
          Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 20,
                offset: Offset(2, 2),
              )
            ]),
            child: Image.asset(
              "Assets/images/mint_login.png",
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 25.0,
          ),
          Text(
            "Welcome to Mint Messenger",
            style: TextStyle(
              fontSize: 23,
              color: Colors.green,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(
            height: 100.0,
          ),
          Center(
            child: Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  Text(
                    "Sign in with google",
                    style: TextStyle(color: Colors.grey.shade300),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        AuthMethods().signInWithGoogel(context);
                      },
                      child: Icon(
                        FlutterIcons.google_ant,
                        color: Colors.green,
                        size: 35.0,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
