import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_github_gantt/widgets/initial_app.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  
  if (kIsWeb) {
    await BrowserContextMenu.disableContextMenu();
  }
  
  runApp(const InitialApp());
}
