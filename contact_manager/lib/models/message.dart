class Message {
  int? id;
  int contactId;
  String content;
  String timestamp;
  bool isSent;

  Message({
    this.id,
    required this.contactId,
    required this.content,
    required this.timestamp,
    required this.isSent,
  });

  // Convertir en Map (pour SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contactId': contactId,
      'content': content,
      'timestamp': timestamp,
      'isSent': isSent ? 1 : 0, // Convertir booléen en entier
    };
  }

  // Créer un message depuis un Map (quand on lit la BD)
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      contactId: map['contactId'],
      content: map['content'],
      timestamp: map['timestamp'],
      isSent: map['isSent'] == 1, // Convertir entier en booléen
    );
  }
}
