import 'package:get/get.dart';

import '../model/Message.dart';

class ChatController extends GetxController{
  var chatMessage = <Message>[].obs;
  var connectedUser = 0.obs;
}