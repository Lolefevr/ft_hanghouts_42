import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import 'chat_page.dart';
import 'edit_contact_page.dart';
import '../l10n.dart';
import '../providers/locale_provider.dart';

class ContactDetailPage extends StatelessWidget {
  final Contact contact;

  const ContactDetailPage({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context)
        .locale
        .languageCode; // 🔥 Récupère la langue actuelle

    return Scaffold(
      appBar: AppBar(title: Text(contact.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📞 ${L10n.getText('phone', locale)} : ${contact.phone}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              '📧 ${L10n.getText('email', locale)} : ${contact.email}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              '📍 ${L10n.getText('address', locale)} : ${contact.address}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              '📝 ${L10n.getText('notes', locale)} : ${contact.notes}',
              style: const TextStyle(fontSize: 18),
            ),
            const Spacer(),
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.message),
                    label: Text(L10n.getText('message', locale)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(contact: contact),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10), // Espace entre les boutons
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: Text(L10n.getText('edit_contact', locale)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditContactPage(contact: contact),
                        ),
                      ).then((_) {
                        if (context.mounted) {
                          Navigator.pop(context, true);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
