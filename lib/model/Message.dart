class Message {
  String message;
  String sentByMe;

  Message({required this.message, required this.sentByMe});

  factory Message.fromJson(Map<String,dynamic> json){
    return Message(
      message: json["message"] ?? '', // Providing default value if message is null
      sentByMe: json["sentByMe"] ?? '', // Providing default value if sentByMe is null
    );
  }

}


