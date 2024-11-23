import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'provider/chat_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    String? chatData = prefs.getString('chat_history');
    if (chatData != null) {
      List<dynamic> jsonData = json.decode(chatData);
      chatProvider.loadMessages(jsonData.map((e) => ChatMessage.fromJson(e)).toList());
    }
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    String chatData = json.encode(chatProvider.messages.map((e) => e.toJson()).toList());
    await prefs.setString('chat_history', chatData);
  }

  Future<void> _clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history');

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.clearMessages();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: const Text("Gemini Chat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await _clearChatHistory();
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: DashChat(
              inputOptions: InputOptions(
                trailing: [
                  IconButton(
                    onPressed: () async {
                      ImagePicker picker = ImagePicker();
                      XFile? file = await picker.pickImage(source: ImageSource.gallery);

                      if (file != null) {
                        chatProvider.sendMediaMessage(file.path);
                        _saveChatHistory();
                      }
                    },
                    icon: const Icon(Icons.image),
                  ),
                ],
              ),
              currentUser: chatProvider.currentUser,
              onSend: (message) {
                chatProvider.sendMessage(message);
                _saveChatHistory();
              },
              messages: chatProvider.messages,
              messageOptions: MessageOptions(
                showTime: true,
              ),
              typingUsers: isTyping
                  ? [
                ChatUser(
                  id: 'ai',
                  firstName: 'AI',
                ),
              ]
                  : [],
            ),
          ),
          if (isTyping)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(width: 8),
                  Text("AI is typing...")
                ],
              ),
            ),
        ],
      ),
    );
  }
}
