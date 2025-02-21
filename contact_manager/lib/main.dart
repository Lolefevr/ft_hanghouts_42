import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/locale_provider.dart';
import 'screens/home_page.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
        ChangeNotifierProvider(
            create: (context) => ThemeProvider()), // 🔥 Ajout de ThemeProvider
      ],
      child: const ContactManagerApp(),
    ),
  );
}

class ContactManagerApp extends StatelessWidget {
  const ContactManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion des Contacts',
      theme: ThemeData(primarySwatch: Colors.blue),
      locale: provider.locale, // 🔥 Langue dynamique gérée par LocaleProvider
      supportedLocales: const [
        Locale('fr', ''), // Français
        Locale('en', ''), // Anglais
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomePage(), // 🔥 On n'a plus besoin de passer `setLocale`
    );
  }
}
