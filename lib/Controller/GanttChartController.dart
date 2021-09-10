import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Model/User.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import '../GitHubAPI.dart';
import '../Log.dart';
import '../Model/Issue.dart';
import 'RepoController.dart';

enum PanType {
  Start,
  Middle,
  End,
}

class GanttChartController extends ChangeNotifier {
  double _issuesListWidth = 400;
  int? viewRangeToFitScreen = 22;
  List<DateTime>? viewRange;
  Color? userColor;
  double initX = 0;
  double initY = 0;
  double dx = 0;
  double dy = 0;
  bool isPanStartActive = false;
  bool isPanMiddleActive = false;
  bool isPanEndActive = false;
  ScrollController gridHorizontalController = ScrollController();
  GitHubAPI? gitHub;
  LinkedScrollControllerGroup controllers = LinkedScrollControllerGroup();
  ScrollController horizontalController = ScrollController();
  List<Issue?> selectedIssues = [];
  double lastScrollPos = 0;
  double chartViewWidth = 1200;
  bool isAltPressed = false;
  bool isShiftPressed = false;
  bool isCtrlPressed = false;
  ScrollController chartController = ScrollController();
  ScrollController listController = ScrollController();
  BuildContext? rootContext;
  List<RepoController> reposList = [];
  RepoController? repo;
  late FocusNode focus;
  late FocusAttachment nodeAttachment;
  User? user;
  DateTime? fromDate;
  DateTime? toDate;
  double detailsValue = 0;

  // torna esta classe singleton
  GanttChartController._privateConstructor();
  static final GanttChartController instance = GanttChartController._privateConstructor();

  Color randomColorGenerator() {
    Random? r = new Random();
    return Color.fromRGBO(r.nextInt(256), r.nextInt(256), r.nextInt(256), 0.75);
  }

  get issuesListWidth => _issuesListWidth;
  set issuesListWidth(value) {
    _issuesListWidth = value;
    update();
  }

  List<DateTime> calculateNumberOfDaysBetween(DateTime from, DateTime to) {
    List<DateTime> period = [];
    DateTime currentDate = from;

    do {
      period.add(currentDate);
      currentDate = currentDate.add(Duration(days: 1));
    } while (currentDate.compareTo(to) <= 0);
    
    return period;
  }

  void launchURL(String url) async {
    String encodedUrl = Uri.encodeFull(url);
    
    if (await canLaunch(encodedUrl))
      await launch(encodedUrl);
    
    return;
  }

  Future<void> onIssueRightButton(BuildContext context, PointerDownEvent event, Issue issue) async {
    // Check if right mouse button clicked
    if (event.kind == PointerDeviceKind.mouse &&
        event.buttons == kSecondaryMouseButton) {
      final overlay =
          Overlay.of(context)!.context.findRenderObject() as RenderBox;
      final menuItem = await showMenu<int>(
          context: context,
          items: [
            PopupMenuItem(child: Text('Editar tarefa #${issue.number}'), value: 1),
          ],
          position: RelativeRect.fromSize(
              event.position & Size(48.0, 48.0), overlay.size));
      // Check if menu item clicked
      switch (menuItem) {
        case 1:
          launchURL("https://github.com/${GanttChartController.instance.user!.login}/${GanttChartController.instance.repo!.name}/issues/${issue.number}");
        break;
        default:
      }
    }
  }

  void addDaysOnStart() {
    fromDate = fromDate!.subtract(Duration(days: 3));
    viewRange = calculateNumberOfDaysBetween(fromDate!, toDate!);
  }

  void addDaysOnEnd() {
    toDate = toDate!.add(Duration(days: 3));
    viewRange = calculateNumberOfDaysBetween(fromDate!, toDate!);
  }

  int calculateRemainingWidth(
      DateTime projectStartedAt, DateTime projectEndedAt) {
    int projectLength = calculateNumberOfDaysBetween(projectStartedAt, projectEndedAt).length;
    if (projectStartedAt.compareTo(fromDate!) >= 0 && projectStartedAt.compareTo(toDate!) <= 0) {
      if (projectLength <= viewRange!.length)
        return projectLength;
      else
        return viewRange!.length - calculateNumberOfDaysBetween(fromDate!, projectStartedAt).length;
    } else if (projectStartedAt.isBefore(fromDate!) && projectEndedAt.isBefore(fromDate!)) {
      return 0;
    } else if (projectStartedAt.isBefore(fromDate!) && projectEndedAt.isBefore(toDate!)) {
      return projectLength - calculateNumberOfDaysBetween(projectStartedAt, fromDate!).length;
    } else if (projectStartedAt.isBefore(instance.fromDate!) && projectEndedAt.isAfter(toDate!)) {
      return viewRange!.length;
    }
    return 0;
  }

  int calculateDistanceToLeftBorder(DateTime projectStartedAt) {
    if (projectStartedAt.compareTo(fromDate!) <= 0) {
      return 0;
    } else
      return calculateNumberOfDaysBetween(fromDate!, projectStartedAt).length - 1;
  }

  void onScrollChange() {
    for (int i = 0; i < selectedIssues.length; i++) {
      bool overLimits = false;
      bool underLimits = false;

      if (selectedIssues[i]!.dragPosFactor.abs() >= 0.4 && selectedIssues[i] != null) {
        if (isPanStartActive || (isPanMiddleActive && selectedIssues[i]!.dragPosFactor.sign < 0)) {
          //Verifica se não tem perídodo menor do que 1 dia 
          overLimits = selectedIssues[i]!.draggingRemainingWidth! * chartViewWidth / viewRangeToFitScreen! + selectedIssues[i]!.width + (horizontalController.position.pixels - lastScrollPos) >= chartViewWidth / viewRangeToFitScreen!;
          underLimits = calculateDistanceToLeftBorder(selectedIssues[i]!.startTime!) * chartViewWidth / viewRangeToFitScreen! + selectedIssues[i]!.width + (horizontalController.position.pixels - lastScrollPos) <= horizontalController.position.pixels;
        }
        
        if (isPanEndActive || (isPanMiddleActive && selectedIssues[i]!.dragPosFactor.sign > 0)) {
          overLimits = overLimits || selectedIssues[i]!.draggingRemainingWidth! * chartViewWidth / viewRangeToFitScreen! + selectedIssues[i]!.width + (horizontalController.position.pixels - lastScrollPos) <= chartViewWidth / viewRangeToFitScreen!;
          overLimits = overLimits || selectedIssues[i]!.draggingRemainingWidth! * chartViewWidth / viewRangeToFitScreen! >= viewRange!.length * chartViewWidth / viewRangeToFitScreen!;
          underLimits = underLimits || calculateDistanceToLeftBorder(selectedIssues[i]!.startTime!) * chartViewWidth / viewRangeToFitScreen! + selectedIssues[i]!.width + (horizontalController.position.pixels - lastScrollPos) + (selectedIssues[i]!.draggingRemainingWidth! * chartViewWidth / viewRangeToFitScreen!) <= horizontalController.position.pixels;
        }

        if (overLimits && !underLimits) {
          selectedIssues[i]!.dragPosFactor = 0;
          selectedIssues[i]!.width = (selectedIssues[i]!.draggingRemainingWidth! - 1) * chartViewWidth / viewRangeToFitScreen!;
        }
        else if (underLimits && !overLimits) {
          selectedIssues[i]!.width = -(calculateDistanceToLeftBorder(selectedIssues[i]!.startTime!) * chartViewWidth / viewRangeToFitScreen! - horizontalController.position.pixels);
          Log.show('d', '${selectedIssues[i]!.width}');
        }
        else if (!underLimits && !overLimits)
          selectedIssues[i]!.width += horizontalController.position.pixels - lastScrollPos;
      }
    }

    lastScrollPos = horizontalController.position.pixels;
  }

  initialize() {
    focus = FocusNode(debugLabel: 'Button');
    focus.requestFocus();
    chartController = controllers.addAndGet();
    listController = controllers.addAndGet();
    userColor = randomColorGenerator();
    GanttChartController.instance.horizontalController.removeListener(onScrollChange);
    horizontalController.addListener(onScrollChange);
  }

  setContext(BuildContext context, double issueListWidth) {
    rootContext = context;
    this._issuesListWidth = issueListWidth;

    nodeAttachment = focus.attach(context, onKey: (node, event) {
      if (isAltPressed != event.isAltPressed)
        isAltPressed = event.isAltPressed;

      if (isShiftPressed != event.isShiftPressed)
        isShiftPressed = event.isShiftPressed;

      if (isCtrlPressed != event.isControlPressed)
        isCtrlPressed = event.isControlPressed;

      update();
      return isAltPressed || isShiftPressed || isCtrlPressed;
    });
  }
  
  void update() {
    notifyListeners();
  }

  void onIssueStartUpdate(BuildContext context, DragUpdateDetails details, double chartAreaWidth) {
    detailsValue = details.globalPosition.dx;

    for (int j = 0; j < selectedIssues.length; j++) {
      if (selectedIssues[j]!.remainingWidth! * chartViewWidth / viewRangeToFitScreen! - (details.globalPosition.dx - initX - (selectedIssues[j]!.startPanChartPos - horizontalController.position.pixels)) >= chartViewWidth / viewRangeToFitScreen!) {
        if (calculateDistanceToLeftBorder(selectedIssues[j]!.startTime!) * chartViewWidth / viewRangeToFitScreen! + (details.globalPosition.dx - initX - (selectedIssues[j]!.startPanChartPos - horizontalController.position.pixels)) > 0) {
          selectedIssues[j]!.width = details.globalPosition.dx - initX - (selectedIssues[j]!.startPanChartPos - horizontalController.position.pixels);
          selectedIssues[j]!.dragPosFactor = (details.globalPosition.dx - (MediaQuery.of(context).size.width - chartAreaWidth)) / chartAreaWidth - 0.5;
        }
        else
          return;
      }
      else
        selectedIssues[j]!.width = (selectedIssues[j]!.remainingWidth! - 1) * chartViewWidth / viewRangeToFitScreen!;
    }
  }

  void onIssueEndUpdate(BuildContext context, DragUpdateDetails details, double chartAreaWidth) {
    for (int j = 0; j < selectedIssues.length; j++) {
      if (selectedIssues[j]!.remainingWidth! * chartViewWidth / viewRangeToFitScreen! + (details.globalPosition.dx - initX - (selectedIssues[j]!.startPanChartPos - horizontalController.position.pixels)) >= chartViewWidth / viewRangeToFitScreen!) {
        if (calculateDistanceToLeftBorder(selectedIssues[j]!.startTime!) * chartViewWidth / viewRangeToFitScreen! - (details.globalPosition.dx - initX - (selectedIssues[j]!.startPanChartPos - horizontalController.position.pixels)) < chartViewWidth / viewRangeToFitScreen! * viewRange!.length) {
          selectedIssues[j]!.width = details.globalPosition.dx - initX - (selectedIssues[j]!.startPanChartPos - horizontalController.position.pixels);
          selectedIssues[j]!.dragPosFactor = (details.globalPosition.dx - (MediaQuery.of(context).size.width - chartAreaWidth)) / chartAreaWidth - 0.5;
        }
        else
          return;
      }
      else
        selectedIssues[j]!.width = (selectedIssues[j]!.remainingWidth! - 1) * chartViewWidth / -viewRangeToFitScreen!;
    }
  }

  void onIssueDateUpdate(BuildContext context, DragUpdateDetails details, double chartAreaWidth) {
    for (int j = 0; j < selectedIssues.length; j++) {
      if (calculateDistanceToLeftBorder(selectedIssues[j]!.startTime!) * chartViewWidth / viewRangeToFitScreen! + (details.globalPosition.dx - initX - (selectedIssues[j]!.startPanChartPos - horizontalController.position.pixels)) > 0 &&
        calculateDistanceToLeftBorder(selectedIssues[j]!.startTime!) * chartViewWidth / viewRangeToFitScreen! + (details.globalPosition.dx - initX - (selectedIssues[j]!.startPanChartPos - horizontalController.position.pixels)) < chartViewWidth / viewRangeToFitScreen! * viewRange!.length) {
        selectedIssues[j]!.width = details.globalPosition.dx - initX - (selectedIssues[j]!.startPanChartPos - horizontalController.position.pixels);
        selectedIssues[j]!.dragPosFactor = (details.globalPosition.dx - (MediaQuery.of(context).size.width - chartAreaWidth)) / chartAreaWidth - 0.5;
      }
      else
        return;
    }
  }

  void onIssueStartPan(PanType type, double startMousePos) {
    for (int j = 0; j < selectedIssues.length; j++) {
      selectedIssues[j]!.draggingRemainingWidth = selectedIssues[j]!.remainingWidth!;
      selectedIssues[j]!.startPanChartPos = horizontalController.position.pixels;
    }
    
    switch (type) {
      case PanType.Start:
        isPanStartActive = true;
      break;
      case PanType.End:
        isPanEndActive = true;
      break;
      default:
        isPanMiddleActive = true;
    }

    update();
  }

  void onIssuePanCancel(PanType type) {
    for (int j = 0; j < selectedIssues.length; j++) {
      selectedIssues[j]!.dragPosFactor = 0;
      selectedIssues[j]!.width = 0;
      selectedIssues[j]!.remainingWidth = selectedIssues[j]!.remainingWidth! + dx.toInt();
    }

    switch (type) {
      case PanType.Start:
        isPanStartActive = false;
      break;
      case PanType.End:
        isPanEndActive = false;
      break;
      default:
        isPanMiddleActive = false;
    }

    update();
  }

  void onIssueEndPan(PanType type) {
    for (int j = 0; j < selectedIssues.length; j++) {
      int daysInterval = (selectedIssues[j]!.width / (chartViewWidth / viewRangeToFitScreen!)).abs().round();

      if (daysInterval > 0) {
        if (type == PanType.Start || type == PanType.Middle) {
          if (selectedIssues[j]!.width > (chartViewWidth / viewRangeToFitScreen! * 0.5))
            selectedIssues[j]!.startTime = selectedIssues[j]!.startTime!.add(Duration(days: daysInterval)); 
          else if (selectedIssues[j]!.width < -(chartViewWidth / viewRangeToFitScreen! * 0.5))
            selectedIssues[j]!.startTime = selectedIssues[j]!.startTime!.subtract(Duration(days: daysInterval));
        }

        if (type == PanType.End || type == PanType.Middle) {
          if (selectedIssues[j]!.width > (chartViewWidth / viewRangeToFitScreen! * 0.5))
            selectedIssues[j]!.endTime = selectedIssues[j]!.endTime!.add(Duration(days: daysInterval)); 
          else if (selectedIssues[j]!.width < -(chartViewWidth / viewRangeToFitScreen! * 0.5))
            selectedIssues[j]!.endTime = selectedIssues[j]!.endTime!.subtract(Duration(days: daysInterval));
        }

        selectedIssues[j]!.width = 0;
        selectedIssues[j]!.toggleProcessing();

        gitHub!.updateIssueTime(selectedIssues[j]!).then((value) {
          selectedIssues[j]!.body = value.body;
          selectedIssues[j]!.startTime = value.startTime;
          selectedIssues[j]!.endTime = value.endTime;
          selectedIssues[j]!.state = value.state;
          selectedIssues[j]!.title = value.title;
          selectedIssues[j]!.dragPosFactor = 0;
          selectedIssues[j]!.remainingWidth = selectedIssues[j]!.remainingWidth! + dx.toInt();
          selectedIssues[j]!.toggleProcessing();

          if (j == selectedIssues.length - 1) {
            switch (type) {
              case PanType.Start:
                isPanStartActive = false;
              break;
              case PanType.End:
                isPanEndActive = false;
              break;
              default:
                isPanMiddleActive = false;
            }

            update();
          }
        });
      }
      else {
        switch (type) {
          case PanType.Start:
            isPanStartActive = false;
          break;
          case PanType.End:
            isPanEndActive = false;
          break;
          default:
            isPanMiddleActive = false;
        }

        selectedIssues[j]!.width = 0;
        selectedIssues[j]!.dragPosFactor = 0;
        selectedIssues[j]!.update();
        update();
      }
    }
  }

  void issueSelect(Issue issue, {List<Issue>? issueList}) {
    if (!isShiftPressed && !issue.selected)
      for (int j = 0; j < selectedIssues.length; j++) {
        selectedIssues[j]!.toggleSelect();
        selectedIssues.removeAt(j);
        j--;
      }

    if (isShiftPressed && isCtrlPressed && issueList != null) {
      int start = 0;
      
      if (selectedIssues.length > 0)
        start = issueList.indexOf(selectedIssues[selectedIssues.length - 1]!);
      
      int end = issueList.indexOf(issue);

      for (int j = start; start < end ? j <= end : j >= end; start < end ? j++ : j--) {
        if (!issueList[j].selected) {
          selectedIssues.add(issueList[j]);
          issueList[j].toggleSelect();
        }
      }
    }
    else {
      issue.toggleSelect();

      if (issue.selected)
        selectedIssues.add(issue);
      else
        selectedIssues.remove(issue);
    }
  }
}