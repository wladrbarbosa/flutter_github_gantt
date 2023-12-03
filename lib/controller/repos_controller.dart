import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/controller/gantt_chart_controller.dart';
import 'package:flutter_github_gantt/controller/repository.dart';
import 'package:intl/intl.dart';

class ReposController extends ChangeNotifier {
  static List<Repository> repos = [];
  static Map<String, Color> _reposColors = {};
  static Map<String, double> _reposPerHourValue = {};
  static Map<String, Map<int, List<int?>>> _reposWorkWeekHours = {};
  static Map<String, Map<DateTime, List<int?>>> _reposWorkSpecificDaysHours = {};

  static Color getRepoColorById(String nodeId) {
    return _reposColors[nodeId] ?? Colors.grey;
  }

  static double getRepoPerHourValueById(String nodeId) {
    return _reposPerHourValue[nodeId] ?? defaultPerHourValue;
  }

  static Map<int, List<int?>> getRepoWorkWeekHoursById(String nodeId) {
    return _reposWorkWeekHours[nodeId] ?? defaultWorkWeekHours;
  }

  static Map<DateTime, List<int?>> getRepoWorkSpecificDaysHoursById(String nodeId) {
    return _reposWorkSpecificDaysHours[nodeId] ?? defaultWorkSpecificDaysHours;
  }

  static void loadRepoConfigs() {
    // Color
    Map<String, dynamic> temp = json.decode(GanttChartController.instance.prefs!.getString('reposColors') ?? '{}');

    _reposColors = temp.map<String, Color>((key, value) {
      return MapEntry(key, Color(int.parse(value, radix: 16)));
    });
    
    // Per Hour Value
    temp = json.decode(GanttChartController.instance.prefs!.getString('reposPerHourValue') ?? '{}');

    _reposPerHourValue = temp.map<String, double>((key, value) {
      return MapEntry(key, value);
    });

    // Work Week Hours
    temp = json.decode(GanttChartController.instance.prefs!.getString('reposWorkWeekHours') ?? '{}');

    _reposWorkWeekHours = temp.map<String, Map<int, List<int?>>>((key, value) {
      Map<int, List<int?>> temp = (value as Map<String, dynamic>).map<int, List<int?>>((key, value) => MapEntry(int.parse(key), (value as List<dynamic>).map<int?>((e) => e).toList()));
      return MapEntry(key, temp);
    });

    // Work Specific Days Hours
    temp = json.decode(GanttChartController.instance.prefs!.getString('reposWorkSpecificDaysHours') ?? '{}');

    _reposWorkSpecificDaysHours = temp.map<String, Map<DateTime, List<int?>>>((key, value) {
      Map<DateTime, List<int?>> temp = (value as Map<String, dynamic>).map<DateTime, List<int?>>((key, value) => MapEntry(DateTime.parse(key), (value as List<dynamic>).map<int?>((e) => e).toList()));
      return MapEntry(key, temp);
    });
  }

  static void setRepoConfigs(
    String nodeId,
    Color color,
    double perHourValue,
    Map<int, List<int?>> workWeekHours,
    Map<DateTime, List<int?>> workSpecificDaysHours,
  ) {
    // Color
    _reposColors[nodeId] = color;

    Map<String, dynamic> temp = _reposColors.map<String, String>((key, value) {
      String colorString = value.toString();
      String valueString = colorString.split('(0x')[1].split(')')[0];

      return MapEntry(key, valueString);
    });

    GanttChartController.instance.prefs!.setString('reposColors', json.encode(temp));
    // Per Hour Value
    _reposPerHourValue[nodeId] = perHourValue;

    temp = _reposPerHourValue.map<String, double>((key, value) {
      return MapEntry(key, value);
    });

    GanttChartController.instance.prefs!.setString('reposPerHourValue', json.encode(temp));
    // Work Week Hours
    _reposWorkWeekHours[nodeId] = workWeekHours;

    temp = _reposWorkWeekHours.map<String, Map<String, List<int?>>>((key, value) {
      Map<String, List<int?>> temp = value.map<String, List<int?>>((key, value) => MapEntry(key.toString(), value));
      return MapEntry(key, temp);
    });

    GanttChartController.instance.prefs!.setString('reposWorkWeekHours', json.encode(temp));
    // Work Specific Days Hours
    _reposWorkSpecificDaysHours[nodeId] = workSpecificDaysHours;

    temp = _reposWorkSpecificDaysHours.map<String, Map<String, List<int?>>>((key, value) {
      Map<String, List<int?>> temp = value.map<String, List<int?>>((key, value) => MapEntry(DateFormat('yyyy-MM-dd').format(key), value));
      return MapEntry(key, temp);
    });

    GanttChartController.instance.prefs!.setString('reposWorkSpecificDaysHours', json.encode(temp));
  }

  void update() {
    notifyListeners();
  }
}