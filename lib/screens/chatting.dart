import 'package:chatapp/helper/stoarage_helper.dart';
import 'package:chatapp/screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Chat extends StatefulWidget {
  const Chat(
      {Key? key,
      @required this.sendto,
      @required this.currentuseremail,
      @required this.sendtoemail,
      @required this.chatRoom,
      @required this.profile})
      : super(key: key);
  final sendto;
  final currentuseremail;
  final sendtoemail;
  final chatRoom;
  final profile;
  @override
  _ChatState createState() => _ChatState();
}

bool selectuser = true;

TextEditingController msg = TextEditingController();

addData(sender, receiver, chatRoom) async {
  await FirebaseFirestore.instance
      .collection("chatRoom")
      .doc(chatRoom)
      .collection("Chats")
      .add({
    'currentemail': sender,
    'senttoemail': receiver,
    'message': msg.text,
    'time': DateTime.now().millisecondsSinceEpoch,
  });
  msg.clear();
}

a(timeInMillis) {
  var date = DateTime.fromMillisecondsSinceEpoch(timeInMillis);
  var formattedDate = DateFormat.yMMMd().format(date);
  var formattedtime = DateFormat.Hm().format(date);
  return "${formattedtime}";
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 50,
              height: 50,
              child: StreamBuilder(
                stream: Storage().downloadedUrl('${widget.profile}'),
                builder: (context, AsyncSnapshot<String> snap) {
                  if (snap.hasError) {
                    return const Text("Error");
                  } else if (snap.connectionState == ConnectionState.done &&
                      snap.hasData) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Profile(
                                    profile: '${widget.profile}',
                                    profileimg: '${snap.data!}')));
                      },
                      child: CircleAvatar(
                          backgroundColor: Colors.purple,
                          backgroundImage: NetworkImage(
                            snap.data!,
                          )),
                    );
                    //Container(width: 300,height: 450,
                    // child: Image.network(snap.data!,
                    // fit: BoxFit.cover,),

                  }
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar(
                        backgroundColor: Colors.purple,
                        backgroundImage: AssetImage(
                          "assets/images/default.jpeg",
                        ));
                  }
                  return Container();
                },
              ),
            ),
          ),
        ],
        title: Center(
          child: Text(
            "${widget.sendto}",
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.purple),
          ),
        ),
        leadingWidth: MediaQuery.of(context).size.width * 0.2,
        leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_outlined, color: Colors.purple)),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("chatRoom")
                    .doc('${widget.chatRoom}')
                    .collection("Chats")
                    .orderBy("time")
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Image(
                      image: AssetImage("assets/images/run.gif"),
                    );
                  }

                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      if ('${data['currentemail']}' ==
                          "${widget.currentuseremail}") {
                        selectuser = true;
                      } else {
                        selectuser = false;
                      }
                      return Column(children: [
                        Container(
                          margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.width * 0.05,
                            left: selectuser
                                ? MediaQuery.of(context).size.width * 0.25
                                : MediaQuery.of(context).size.width * 0.05,
                            right: selectuser
                                ? MediaQuery.of(context).size.width * 0.05
                                : MediaQuery.of(context).size.width * 0.25,
                          ),
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.width * 0.01,
                              right: MediaQuery.of(context).size.width * 0.01,
                              top: MediaQuery.of(context).size.width * 0.05),
                          decoration: BoxDecoration(
                            color: selectuser ? Colors.purple : Colors.white,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          width: MediaQuery.of(context).size.width * 0.90,
                          child: Container(
                            padding: EdgeInsets.only(
                                right: MediaQuery.of(context).size.width * 0.01,
                                left: MediaQuery.of(context).size.width * 0.05),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: '${data['message']}',
                                    style: TextStyle(
                                        color: selectuser
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 18.0),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.library_add_check_outlined,
                                      size: 15,
                                      color: selectuser
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    Text(" ${a(data['time'])}",
                                        style: TextStyle(
                                            color: selectuser
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 13.0)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]);
                    }).toList(),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.width * 0.03,
                  top: MediaQuery.of(context).size.width * 0.03),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.05,
                      right: MediaQuery.of(context).size.width * 0.05,
                    ),
                    width: MediaQuery.of(context).size.width * 0.78,
                    child: TextField(
                        controller: msg,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(25.7)),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(25.7)),
                            suffixIcon: const Icon(
                              Icons.mic,
                              color: Colors.purple,
                            ),
                            hintText: 'Type a message',
                            prefixIcon: const Icon(
                              Icons.face,
                              color: Colors.purple,
                            ))),
                  ),
                  InkWell(
                    onTap: () {},
                    child: InkWell(
                      onTap: () {
                        if (msg.text != "") {
                          addData("${widget.currentuseremail}",
                              "${widget.sendtoemail}", "${widget.chatRoom}");
                        }
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.purple,
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
