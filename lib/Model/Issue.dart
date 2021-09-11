import 'package:flutter/foundation.dart';

class Issue extends ChangeNotifier {
  Issue({
    this.number,
    this.assignees,
    this.title,
    this.startTime,
    this.endTime,
    this.body,
    this.state = 'open',
    this.selected = false,
    this.dragPosFactor = 0,
    this.draggingRemainingWidth,
    this.startPanChartPos = 0,
    this.remainingWidth,
    this.processing = false,
  });

  final int? number;
  final List<String>? assignees;
  String? title;
  DateTime? startTime;
  DateTime? endTime;
  double _width = 0;
  String state;
  String? body;
  bool selected;
  bool processing;
  double dragPosFactor;
  int? draggingRemainingWidth;
  int? remainingWidth;
  double startPanChartPos;

  double get width => _width;
  set width(value) {
    _width = value;
    update();
  }

  void update() {
    notifyListeners();
  }

  void toggleSelect() {
    selected = !selected; 
    update();
  }

  void toggleProcessing({bool notify = true}) {
    processing = !processing;

    if (notify)
      update();
  }
}