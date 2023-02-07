import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/widgets/multi_scroll_behavior.dart';
import 'package:flutter_github_gantt/widgets/root_stateful_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class InitialApp extends StatelessWidget {
  const InitialApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'), // Brazillian Portuguese, no country code
        Locale('en', ''), // English, no country code
        Locale('es', ''), // Spanish, no country code
      ],
      scrollBehavior: MultiScrollScrollBehavior(),
      debugShowCheckedModeBanner: false,
      title: 'Github Gantt',
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green,
        primarySwatch: Colors.green,
      ),
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.light,
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const RootStatefulWidget(title: 'Github Gantt'),
    );
  }
}