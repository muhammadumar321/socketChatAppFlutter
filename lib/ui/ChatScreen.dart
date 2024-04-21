import 'package:chat_app/controller/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../model/Message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Color orange = Colors.orange;
  Color black = Colors.black;

  TextEditingController msgInputController = TextEditingController();

  late IO.Socket socket;

  ChatController chatController = ChatController();

  @override
  void initState() {
    super.initState();
    initSocketConnection();
    setUpSocketListener();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Obx(
                () => Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "Connected User: ${chatController.connectedUser.string}",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 9,
                child: Obx(
                  () => ListView.builder(
                    itemCount: chatController.chatMessage.length,
                    itemBuilder: (context, index) {
                      var currentItem = chatController.chatMessage[index];
                      return MessageItem(
                        sentByMe: currentItem.sentByMe == socket.id,
                        message: currentItem.message,
                      );
                    },
                  ),
                )),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  cursorColor: orange,
                  controller: msgInputController,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: Container(
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                            color: orange,
                            borderRadius: BorderRadius.circular(10)),
                        child: IconButton(
                          onPressed: () {
                            sendMessage(msgInputController.text);
                            msgInputController.text = "";
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void initSocketConnection() {
    try {
      socket = IO.io(
          'http://localhost:4000',
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .build());
      socket.connect();

      socket.onConnect((_) {
        print('Connection established');
      });
      socket.onDisconnect((_) => print('Connection Disconnection'));
      socket.onConnectError((err) => print(err));
      socket.onError((err) => print(err));
      // Set up event listeners or any other initialization logic here
    } catch (e) {
      // Handle connection errors
      print('Socket connection error: $e');
    }
  }

  void setUpSocketListener() {
    socket.on(
        'message-received',
        (data) => {
              print('message received: $data'),
              chatController.chatMessage.add(Message.fromJson(data))
            });
    socket.on(
        'connected-user',
            (data) => {
          print('connected-user: $data'),
          chatController.connectedUser.value = data
        });
  }

  void sendMessage(String text) {
    var messageJson = {"message": text, "sentByMe": socket.id};
    socket.emit('message', messageJson);
    chatController.chatMessage.add(Message.fromJson(messageJson));
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({super.key, required this.sentByMe, required this.message});

  final bool sentByMe;
  final String message;

  @override
  Widget build(BuildContext context) {
    Color orange = Colors.orange;

    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.bottomLeft,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: sentByMe ? orange : Colors.white,
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              message.toString(),
              style: TextStyle(
                  color: sentByMe ? Colors.white : orange, fontSize: 18),
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              "1:10 am",
              style: TextStyle(
                  color: (sentByMe ? Colors.white : orange).withOpacity(0.7),
                  fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
