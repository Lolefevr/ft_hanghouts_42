import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../l10n.dart';
import '../models/contact.dart';
import 'contact_detail_page.dart';
import 'edit_contact_page.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> filteredContacts = [];
  late DatabaseHelper dbHelper;
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
    _loadContacts();
    _searchController.addListener(() {
      _filterContacts(_searchController.text);
    });
  }

  void _filterContacts(String query) {
    setState(() {
      filteredContacts = contacts
          .where((contact) =>
              contact.name.toLowerCase().contains(query.toLowerCase()) ||
              contact.phone.contains(query))
          .toList();
    });
  }

  Future<void> _loadContacts() async {
    final data = await dbHelper.getContacts();
    setState(() {
      contacts = data;
      filteredContacts = contacts;
    });
  }

  Future<void> _deleteContact(int id) async {
    await dbHelper.deleteContact(id);
    _loadContacts();
  }

  void _confirmDeleteContact(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final locale = Provider.of<LocaleProvider>(context).locale.languageCode;
        return AlertDialog(
          title: Text(L10n.getText('confirm_delete', locale)),
          content: Text(L10n.getText('delete_contact', locale)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(L10n.getText('cancel', locale)),
            ),
            TextButton(
              onPressed: () {
                _deleteContact(id);
                Navigator.pop(context);
              },
              child: Text(L10n.getText('delete', locale),
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final provider = Provider.of<LocaleProvider>(context);
    final locale =
        provider.locale.languageCode; // 🔥 Récupère la langue mise à jour

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.getText('contacts', locale)),
        backgroundColor: themeProvider.appBarColor, // 🔥 Couleur dynamique
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () => _showColorPicker(context),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              provider.setLocale(
                  Locale(value)); // 🔥 Mise à jour via LocaleProvider
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'fr', child: Text('🇫🇷 Français')),
              const PopupMenuItem(value: 'en', child: Text('🇬🇧 English')),
            ],
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: L10n.getText('search', locale), // 🔥 Texte traduit
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) => _filterContacts(value),
            ),
          ),
          Expanded(
            child: filteredContacts.isEmpty
                ? Center(
                    child: Text(L10n.getText(
                        'no_contacts', locale))) // 🔥 Texte traduit
                : ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = filteredContacts[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Text(contact.name[0],
                              style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(contact.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(contact.phone,
                            style: TextStyle(color: Colors.grey.shade600)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        tileColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ContactDetailPage(contact: contact),
                            ),
                          ).then((_) => _loadContacts());
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _confirmDeleteContact(contact.id!);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditContactPage()),
          );

          if (result == true) {
            _loadContacts();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(L10n.getText('choose_color',
              Provider.of<LocaleProvider>(context).locale.languageCode)),
          content: Wrap(
            spacing: 10,
            children: [
              _buildColorOption(Colors.blue, themeProvider),
              _buildColorOption(Colors.red, themeProvider),
              _buildColorOption(Colors.green, themeProvider),
              _buildColorOption(Colors.orange, themeProvider),
              _buildColorOption(Colors.purple, themeProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorOption(Color color, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () {
        themeProvider.setAppBarColor(color);
        Navigator.pop(context); // 🔥 Ferme le dialogue après sélection
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
              color: Colors.black,
              width: themeProvider.appBarColor == color ? 3 : 1),
        ),
      ),
    );
  }
}
