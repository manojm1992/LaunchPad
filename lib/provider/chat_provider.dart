import 'dart:typed_data';
import 'dart:io';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  final Gemini gemini = Gemini.instance;

  List<ChatMessage> _messages = [];
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Gemini",
    profileImage:
    "https://seeklogo.com/images/G/google-gemini-logo-A5787B2669-seeklogo.com.png",
  );

  List<ChatMessage> get messages => _messages;

  void sendMessage(ChatMessage chatMessage) {
    _messages = [chatMessage, ..._messages];
    notifyListeners();

    try {
      String question = chatMessage.text;
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }

      gemini.streamGenerateContent(question, images: images).listen((event) {
        ChatMessage? lastMessage = _messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = _messages.removeAt(0);
          String response = event.content?.parts?.fold(
              "", (previous, current) => "$previous ${current.text}") ??
              "";
          lastMessage.text += response;
          _messages = [lastMessage!, ..._messages];
        } else {
          String response = event.content?.parts?.fold(
              "", (previous, current) => "$previous ${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
              user: geminiUser, createdAt: DateTime.now(), text: response);
          _messages = [message, ..._messages];
        }
        notifyListeners();
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendMediaMessage(String filePath) async {
    ChatMessage chatMessage = ChatMessage(
      user: currentUser,
      createdAt: DateTime.now(),
      text: "Describe this picture?",
      medias: [
        ChatMedia(url: filePath, fileName: "", type: MediaType.image),
      ],
    );
    sendMessage(chatMessage);
  }
}
