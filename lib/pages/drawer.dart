import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mint_messenger/helperfunctions/sharepref_helper.dart';
import 'package:mint_messenger/pages/profile.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String myName = "", myUserName = "", myEmail = "", myProfilePic = "";

  getMyInfoFromSharedPrefs() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myProfilePic = await SharedPreferenceHelper().getUserProfilePic();
  }

  final imageurl =
      "https://i1.sndcdn.com/avatars-QWA1tiegwRVcWmFT-bcEOUw-t200x200.jpg";

  onScreenLoaded() async {
    await getMyInfoFromSharedPrefs();
    setState(() {});
  }

  @override
  void initState() {
    onScreenLoaded();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Theme.of(context).primaryColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: UserAccountsDrawerHeader(
                margin: EdgeInsets.zero,
                accountName: Text(myName),
                accountEmail: Text(myEmail),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(myProfilePic),
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              },
              leading: Icon(
                CupertinoIcons.profile_circled,
                color: Theme.of(context).dividerColor,
              ),
              title: Text(
                "Profile",
                textScaleFactor: 1,
                style: TextStyle(color: Theme.of(context).dividerColor),
              ),
            ),
            ListTile(
              leading: Icon(
                CupertinoIcons.settings,
                color: Theme.of(context).dividerColor,
              ),
              title: Text(
                "Settings",
                textScaleFactor: 1,
                style: TextStyle(color: Theme.of(context).dividerColor),
              ),
            ),
            ListTile(
              leading: Icon(
                CupertinoIcons.mail,
                color: Theme.of(context).dividerColor,
              ),
              title: Text(
                "Contact Dev",
                textScaleFactor: 1,
                style: TextStyle(color: Theme.of(context).dividerColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
