import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mint_messenger/helperfunctions/sharepref_helper.dart';
import 'package:mint_messenger/services/database.dart';
import 'package:random_string/random_string.dart';

class Chatscreen extends StatefulWidget {
  final String chatwithusername, name;

  Chatscreen(this.chatwithusername, this.name);

  @override
  _ChatscreenState createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  String chatRoomId, messageId = "";
  Stream messageStream;
  String myName, myUserName, myEmail, myProfilePic;
  TextEditingController messageTextController = TextEditingController();

  getMyInfoFromSharedPrefs() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    myProfilePic = await SharedPreferenceHelper().getUserProfilePic();

    chatRoomId = getChatRoomId(widget.chatwithusername, myUserName);
  }

  getChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  addMessage(bool sendClicked) {
    if (messageTextController.text != "") {
      String message = messageTextController.text;
      var lastMSGtimeStamp = DateTime.now();

      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUserName,
        "time": lastMSGtimeStamp,
        "imgURL": myProfilePic,
      };

      //generate Message Id

      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }
      DatabaseMethods()
          .addMessage(chatRoomId, messageId, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage": message,
          "lastMessageSendBy": myUserName,
          "lastMessageSendTs": lastMSGtimeStamp
        };

        DatabaseMethods().updateLastMessageSent(chatRoomId, lastMessageInfoMap);

        if (sendClicked) {
          //make text form field blank
          messageTextController.text = "";
          //to make new message id
          messageId = "";
        }
      });
    }
  }

  Widget chatMessageTile(String message, bool sendByMe) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment:
            sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                  color: sendByMe ? Colors.green.shade700 : Color(0xfff1f0f0),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomRight:
                          sendByMe ? Radius.circular(0) : Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft:
                          sendByMe ? Radius.circular(30) : Radius.circular(0))),
              child: Text(message),
              padding: EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
        stream: messageStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.only(bottom: 70, top: 16),
                  reverse: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return chatMessageTile(
                        ds["message"], myUserName == ds["sendBy"]);
                  },
                )
              : Center(child: CircularProgressIndicator());
        });
  }

  getAndSetMSG() async {
    messageStream = await DatabaseMethods().getChatRoomsMsgs(chatRoomId);
    setState(() {});
  }

  doThisOnLaunch() async {
    await getMyInfoFromSharedPrefs();
    getAndSetMSG();
  }

  @override
  void initState() {
    doThisOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Icon(CupertinoIcons.person_crop_circle_fill_badge_plus),
            ),
          )
        ],
        backgroundColor: Colors.green.shade600,
        title: Text(
          widget.name,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 55,
                color: Colors.green.withOpacity(0.8),
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.emoji_emotions_sharp),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        addMessage(false);
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter the message to send"),
                    )),
                    Icon(CupertinoIcons.paperclip, color: Colors.white),
                    SizedBox(width: 20),
                    InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () {
                          addMessage(true);
                        },
                        child: Icon(Icons.send_rounded, color: Colors.white)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
