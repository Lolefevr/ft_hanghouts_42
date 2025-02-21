import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact.dart';
import '../models/message.dart';

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'contacts';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'contacts.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) {
        return db.execute('''
  CREATE TABLE contacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT NOT NULL,
    address TEXT NOT NULL,
    notes TEXT NOT NULL
  );
''').then((_) {
          return db.execute('''
    CREATE TABLE messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      contactId INTEGER NOT NULL,
      content TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      isSent INTEGER NOT NULL,
      FOREIGN KEY (contactId) REFERENCES contacts (id) ON DELETE CASCADE
    );
  ''');
        });
      },
    );
  }

  // Ajouter un contact
  Future<int> insertContact(Contact contact) async {
    final db = await database;
    return await db.insert(tableName, contact.toMap());
  }

  // Récupérer tous les contacts
  Future<List<Contact>> getContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> contacts = await db.query(tableName);
    return contacts.map((map) => Contact.fromMap(map)).toList();
  }

  // Modifier un contact
  Future<int> updateContact(Contact contact) async {
    final db = await database;
    return await db.update(
      tableName,
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  // Supprimer un contact
  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Ajouter un message
  Future<int> insertMessage(Message message) async {
    final db = await database;
    return await db.insert('messages', message.toMap());
  }

// Récupérer tous les messages d’un contact
  Future<List<Message>> getMessagesForContact(int contactId) async {
    final db = await database;
    final List<Map<String, dynamic>> messages = await db.query(
      'messages',
      where: 'contactId = ?',
      whereArgs: [contactId],
      orderBy: 'timestamp ASC', // Trier par date
    );
    return messages.map((map) => Message.fromMap(map)).toList();
  }
}
