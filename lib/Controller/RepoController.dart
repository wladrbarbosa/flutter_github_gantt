import 'dart:convert';

import 'package:flutter/foundation.dart';

class RepoController extends ChangeNotifier {
  RepoController({
    this.id,
    this.name,
  });

  final String? name;
  final int? id;

  String toJSONStr() {
    return json.encode({
      'id': id,
      'name': name 
    });
  }

  static RepoController fromJSONStr(String value) {
    Map<String, dynamic> mapedRepo = json.decode(value);

    return RepoController(
      id: mapedRepo['id'],
      name: mapedRepo['name']
    );
  }

  void update() {
    notifyListeners();
  }
}