import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'provider/chat_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gemini Chat"),
      ),
      body: DashChat(
        inputOptions: InputOptions(
          trailing: [
            IconButton(
              onPressed: () async {
                ImagePicker picker = ImagePicker();
                XFile? file =
                    await picker.pickImage(source: ImageSource.gallery);

                if (file != null) {
                  chatProvider.sendMediaMessage(file.path);
                }
              },
              icon: const Icon(Icons.image),
            ),
          ],
        ),
        currentUser: chatProvider.currentUser,
        onSend: chatProvider.sendMessage,
        messages: chatProvider.messages,
      ),
    );
  }
}
