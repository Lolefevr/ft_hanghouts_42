import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/locale_provider.dart';
import 'screens/home_page.dart';
import 'providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

class ContactManagerApp extends StatefulWidget {
  const ContactManagerApp({super.key});

  @override
  ContactManagerAppState createState() => ContactManagerAppState();
}

class ContactManagerAppState extends State<ContactManagerApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      // 🔥 Sauvegarde la date et l’heure lorsque l’application passe en arrière-plan
      final prefs = await SharedPreferences.getInstance();
      String now = DateTime.now().toString();
      await prefs.setString('last_closed', now);
    } else if (state == AppLifecycleState.resumed) {
      // 🔥 Récupère la dernière date et affiche un Toast
      final prefs = await SharedPreferences.getInstance();
      String? lastClosed = prefs.getString('last_closed');

      if (lastClosed != null) {
        Fluttertoast.showToast(
          msg: "Dernière ouverture : $lastClosed",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }

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
