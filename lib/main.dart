import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mint_messenger/pages/home.dart';
import 'package:mint_messenger/pages/login.dart';
import 'package:mint_messenger/services/auth.dart';
import 'package:mint_messenger/widgets/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: Mytheme.LightTheme(context),
      darkTheme: Mytheme.DarkTheme(context),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: AuthMethods().getCurrentUser(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Home();
          } else {
            return Login();
          }
        },
      ),
    );
  }
}
