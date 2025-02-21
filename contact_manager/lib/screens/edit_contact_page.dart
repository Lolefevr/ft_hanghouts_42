import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../database/database_helper.dart';
import '../l10n.dart';
import '../providers/locale_provider.dart';

class EditContactPage extends StatefulWidget {
  final Contact? contact;

  const EditContactPage({super.key, this.contact});

  @override
  EditContactPageState createState() => EditContactPageState();
}

class EditContactPageState extends State<EditContactPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;

  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phone ?? '');
    _emailController = TextEditingController(text: widget.contact?.email ?? '');
    _addressController =
        TextEditingController(text: widget.contact?.address ?? '');
    _notesController = TextEditingController(text: widget.contact?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (_formKey.currentState!.validate()) {
      final contact = Contact(
        id: widget.contact?.id,
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
        notes: _notesController.text,
        photo: _selectedImage?.path,
      );

      if (widget.contact == null) {
        await dbHelper.insertContact(contact);
      } else {
        await dbHelper.updateContact(contact);
      }

      if (mounted) {
        Navigator.pop(
            context, true); // 🔥 On envoie "true" pour rafraîchir la liste
      }
    }
  }

  String? _validatePhone(String? value, String locale) {
    final RegExp phoneRegExp = RegExp(r'^[0-9]{10,15}$'); // 10 à 15 chiffres
    if (value == null || value.isEmpty)
      return L10n.getText('enter_phone', locale);
    if (!phoneRegExp.hasMatch(value))
      return L10n.getText('invalid_phone', locale);
    return null;
  }

  String? _validateEmail(String? value, String locale) {
    final RegExp emailRegExp =
        RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
    if (value == null || value.isEmpty)
      return L10n.getText('enter_email', locale);
    if (!emailRegExp.hasMatch(value))
      return L10n.getText('invalid_email', locale);
    return null;
  }

  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context).locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.contact == null
              ? L10n.getText('add_contact', locale)
              : L10n.getText('edit_contact', locale),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔥 Ajout du bouton pour uploader une image
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : widget.contact?.photo != null
                          ? FileImage(File(widget.contact!.photo!))
                          : null,
                  child: _selectedImage == null && widget.contact?.photo == null
                      ? Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _pickImage,
                child: Text(L10n.getText('choose_photo', locale)),
              ),

              // 🔥 Tous les champs du formulaire restent inchangés
              TextFormField(
                controller: _nameController,
                decoration:
                    InputDecoration(labelText: L10n.getText('name', locale)),
                validator: (value) =>
                    value!.isEmpty ? L10n.getText('enter_name', locale) : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration:
                    InputDecoration(labelText: L10n.getText('phone', locale)),
                keyboardType: TextInputType.phone,
                validator: (value) => _validatePhone(value, locale),
              ),
              TextFormField(
                controller: _emailController,
                decoration:
                    InputDecoration(labelText: L10n.getText('email', locale)),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => _validateEmail(value, locale),
              ),
              TextFormField(
                controller: _addressController,
                decoration:
                    InputDecoration(labelText: L10n.getText('address', locale)),
              ),
              TextFormField(
                controller: _notesController,
                decoration:
                    InputDecoration(labelText: L10n.getText('notes', locale)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveContact,
                child: Text(L10n.getText('save', locale)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
