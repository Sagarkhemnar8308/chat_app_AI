import 'package:chat_app_with_gemini/message_model.dart';
import 'package:chat_app_with_gemini/themeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final List<Message> message = [
    Message(isUser: true, text: 'hii'),
    Message(isUser: false, text: 'Hello ! how can exist today'),
    Message(isUser: true, text: 'Flutter'),
    Message(isUser: false, text: 'Used for app development'),
  ];

  bool _isloading = false;

  callGeminiModel() async {
    try {
      if (_searchController.text.isNotEmpty) {
        message.add(
          Message(isUser: true, text: _searchController.text),
        );
        _isloading=true;
      }
      final model = GenerativeModel(
          model: 'gemini-pro', apiKey: dotenv.env['GOOGLE_API_KEY'] ?? "");
      final prompt = _searchController.text.trim();
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      setState(() {
        message.add(Message(
          isUser: false,
          text: response.text ?? "",
        ));
        _isloading=false;
      });
      _searchController.clear();
    } catch (e, stk) {
      print("[38] homescreen $e , $stk");
      _searchController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SagarAI',
                style: Theme.of(context).textTheme.titleLarge,
              )
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                ref.read(themeProvider.notifier).toggleTheme();
              },
              icon: const Icon(
                Icons.light_mode_sharp,
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: message.length,
                itemBuilder: (context, index) {
                  var messages = message[index];
                  return ListTile(
                    title: Align(
                      alignment: messages.isUser
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(
                              20,
                            ),
                            topRight: Radius.circular(
                              20,
                            ),
                            bottomRight: Radius.circular(
                              20,
                            ),
                          ),
                          color: messages.isUser ? Colors.white : Colors.blue,
                        ),
                        child: Text(
                          messages.text,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.9),
                          spreadRadius: 3,
                          blurRadius: 3,
                          offset: const Offset(0, 1))
                    ]),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                            hintText: "Search text here",
                            contentPadding: EdgeInsets.all(12),
                            border: InputBorder.none),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    _isloading
                        ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(),
                            ),
                        )
                        : IconButton(
                            onPressed: () {
                              callGeminiModel();
                            },
                            icon: const Icon(Icons.send_rounded))
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
