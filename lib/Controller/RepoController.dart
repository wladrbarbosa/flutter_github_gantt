import 'package:flutter/foundation.dart';

class RepoController extends ChangeNotifier {
  RepoController({
    this.name,
  });

  final String? name;

  void update() {
    notifyListeners();
  }
}