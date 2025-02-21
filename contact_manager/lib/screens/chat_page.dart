import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../models/message.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // ✅ Pour générer des réponses aléatoires

class ChatPage extends StatefulWidget {
  final Contact contact;

  const ChatPage({super.key, required this.contact});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final DatabaseHelper dbHelper = DatabaseHelper();
  final TextEditingController _messageController = TextEditingController();
  List<Message> messages = [];

  final List<String> _autoResponses = [
    // ✅ Liste des réponses automatiques
    "Coucou toi, tu aimes les coquillettes ?",
    "Tout à fait !",
    "Tu m'ennuies",
    "Il est où le outstanding là ?",
    "Moi aussi je t'aime bien <3",
    "Allez, jouons encore un peu tous les deux ;)"
  ];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final data = await dbHelper.getMessagesForContact(widget.contact.id!);
    setState(() {
      messages = data;
    });

    // 🔥 Défilement automatique vers le bas après le chargement
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final sentMessage = Message(
      contactId: widget.contact.id!,
      content: _messageController.text.trim(),
      timestamp: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      isSent: true, // ✅ Message envoyé par l’utilisateur
    );

    await dbHelper.insertMessage(sentMessage);
    _messageController.clear();
    // 🔥 Défilement automatique vers le bas après le chargement
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
    await _loadMessages();

    // 🔥 Réponse automatique après 1 seconde
    Future.delayed(const Duration(seconds: 1), () async {
      final randomResponse = _autoResponses[
          Random().nextInt(_autoResponses.length)]; // ✅ Choix aléatoire

      final replyMessage = Message(
        contactId: widget.contact.id!,
        content: randomResponse,
        timestamp: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        isSent: false, // ✅ Message reçu (automatique)
      );

      await dbHelper.insertMessage(replyMessage);
      await _loadMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.contact.name)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Align(
                  alignment:
                      msg.isSent ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          msg.isSent ? Colors.blueAccent : Colors.grey.shade300,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(10),
                        topRight: const Radius.circular(10),
                        bottomLeft: msg.isSent
                            ? const Radius.circular(10)
                            : const Radius.circular(0),
                        bottomRight: msg.isSent
                            ? const Radius.circular(0)
                            : const Radius.circular(10),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.content,
                          style: TextStyle(
                              color: msg.isSent ? Colors.white : Colors.black,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            DateFormat('HH:mm')
                                .format(DateTime.parse(msg.timestamp)),
                            style:
                                TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration:
                        const InputDecoration(hintText: "Écrire un message..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
