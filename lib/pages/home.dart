import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mint_messenger/helperfunctions/sharepref_helper.dart';
import 'package:mint_messenger/pages/chatscreen.dart';
import 'package:mint_messenger/pages/drawer.dart';
import 'package:mint_messenger/pages/login.dart';
import 'package:mint_messenger/services/auth.dart';
import 'package:mint_messenger/services/database.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
  Stream usersStream, chatRoomsStream;
  String myName, myUserName, myEmail, myProfilePic;

  TextEditingController searchUserNameEditingController =
      TextEditingController();

  getMyInfoFromSharedPrefs() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myProfilePic = await SharedPreferenceHelper().getUserProfilePic();
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  onSearchBtnClick() async {
    isSearching = true;
    setState(() {});
    usersStream = await DatabaseMethods()
        .getUserByUserName(searchUserNameEditingController.text);
    setState(() {});
  }

  Widget searchUsersList() {
    return StreamBuilder(
      stream: usersStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return searchUserTile(
                      picURL: ds["imgURL"],
                      name: ds["name"],
                      username: ds["username"],
                      email: ds["email"]);
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  Widget chatRoomList() {
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return ChatRoomListTile(
                        ds["lastMessage"], ds.id, myUserName);
                  })
              : Center(child: CircularProgressIndicator());
        });
  }

  Widget searchUserTile({String picURL, name, username, email}) {
    return GestureDetector(
      onTap: () {
        var chatRoomId = getChatRoomId(myUserName, username);

        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, username]
        };

        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Chatscreen(username, name)));
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              picURL,
              height: 40,
              width: 40,
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(name), Text(email)])
        ],
      ),
    );
  }

  getChatRooms() async {
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  onScreenLoaded() async {
    await getMyInfoFromSharedPrefs();
    getChatRooms();
  }

  @override
  void initState() {
    onScreenLoaded();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: Text(
          "Mint Messenger",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          InkWell(
            onTap: () {
              AuthMethods().signOut().then((s) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Login()));
              });
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.exit_to_app)),
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            Row(
              children: [
                isSearching
                    ? Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () {
                              isSearching = false;
                              searchUserNameEditingController.text = "";
                              setState(() {});
                            },
                            child: Icon(Icons.arrow_back_ios)),
                      )
                    : Container(),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.black,
                            style: BorderStyle.solid,
                            width: 0.7)),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          controller: searchUserNameEditingController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search for people and groups",
                          ),
                        )),
                        InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () {
                              if (searchUserNameEditingController.text !=
                                  null) {
                                onSearchBtnClick();
                              }
                            },
                            child: Icon(Icons.search))
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isSearching ? searchUsersList() : chatRoomList()
          ],
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername;

  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername);

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name, username;

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUsername, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    print("something ${querySnapshot.docs[0].id}");
    name = "${querySnapshot.docs[0]["name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["imgURL"]}";
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return profilePicUrl != ""
        ? InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Chatscreen(username, name)));
            },
            child: Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(profilePicUrl, height: 40, width: 40)),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(widget.lastMessage,
                        style: TextStyle(color: Colors.green.shade400))
                  ],
                )
              ],
            ),
          )
        : Container();
  }
}
