import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact.dart';
import 'chat_page.dart';
import 'edit_contact_page.dart';
import '../l10n.dart';
import '../providers/locale_provider.dart';

class ContactDetailPage extends StatelessWidget {
  final Contact contact;

  const ContactDetailPage({super.key, required this.contact});

  void callContact(String phoneNumber) async {
    final Uri url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw "Impossible d’ouvrir l’application téléphonique.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context).locale.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(contact.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: contact.photo != null
                    ? FileImage(File(contact.photo!))
                    : null,
                child: contact.photo == null
                    ? Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
              ),
            ),
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
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.call),
                    label: Text(L10n.getText('call', locale)),
                    onPressed: () {
                      callContact(contact.phone);
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
