import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_github_gantt/configs.dart';
import 'package:flutter_github_gantt/controller/repos_controller.dart';
import 'package:flutter_github_gantt/controller/repository.dart';
import 'package:flutter_github_gantt/externals/github_api.dart';
import 'package:flutter_github_gantt/model/rate_limit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/user.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import '../externals/log.dart';
import '../model/issue.dart';

enum PanType {
  start,
  middle,
  end,
}

class GanttChartController extends ChangeNotifier {
  double _issuesListWidth = 520;
  double? viewRangeOnScale = 0;
  double? viewRangeToFitScreen = 20;
  static double chartPanelWidth = 0;
  PageStorageBucket chartBucket = PageStorageBucket();
  PageStorageBucket listBucket = PageStorageBucket();
  PageStorageKey listStorageKey = const PageStorageKey('list');
  List<DateTime>? viewRange;
  Color? userColor;
  double initX = 0;
  double initY = 0;
  double dx = 0;
  double dy = 0;
  // Para uma movimentação mais flúida
  double get deltaScrollPos => horizontalController.offset - lastScrollPos;
  bool isPanUpdateActive = false;
  bool isPanStartActive = false;
  bool isPanMiddleActive = false;
  bool isPanEndActive = false;
  GitHubAPI? gitHub;
  LinkedScrollControllerGroup controllers = LinkedScrollControllerGroup();
  bool isTodayJumped = false;
  LinkedScrollControllerGroup horizontalController = LinkedScrollControllerGroup();
  List<Issue?> selectedIssues = [];
  double lastScrollPos = 0;
  double chartViewWidth = 1000;
  bool isAltPressed = false;
  bool isShiftPressed = false;
  bool isCtrlPressed = false;
  ScrollController columnsScrollController = ScrollController();
  ScrollController hoursScrollController = ScrollController();
  ScrollController daysScrollController = ScrollController();
  ScrollController singleChildScrollController = ScrollController();
  ScrollController chartBarsController = ScrollController();
  ScrollController chartDependencyLinesController = ScrollController();
  ScrollController listController = ScrollController();
  BuildContext? rootContext;
  static ReposController reposController = ReposController();
  late FocusNode focus;
  FocusAttachment? nodeAttachment;
  User? user;
  DateTime? fromDate;
  DateTime? toDate;
  double currentDragX = 0;
  SharedPreferences? prefs;
  static Future<List<Issue>>? issueListFuture;
  static List<Issue>? issueList;
  RateLimit? rateLimit;
  double lastVerticalPos = 0;
  double lastHorizontalPos = 0;
  // Ao tocar com botão direito na grid, se for espaço vazio seta -1
  // senão seta o indice da issue abaixo do ponteiro/toque
  int contextIssueIndex = -1;
  DateTime? onPointerDownTime;
  TextEditingController filterController = TextEditingController();
  static List<Repository> selRepos = [];

  // torna esta classe singleton
  GanttChartController._privateConstructor();
  static final GanttChartController instance = GanttChartController._privateConstructor();

  double get chartColumnsWidth {
    return (chartViewWidth / viewRangeToFitScreen!).roundToDouble();
  }

  Color randomColorGenerator() {
    Random? r = Random();
    return Color.fromRGBO(r.nextInt(256), r.nextInt(256), r.nextInt(256), 0.75);
  }

  static DateTimeRange parseIssueBody(Issue issue) {
    DateTimeRange? periodoDaTarefa = DateTimeRange(start: DateTime.now(), end: DateTime.now());
    
    try {
      periodoDaTarefa = DateTimeRange(
        start: DateFormat('yyyy/MM/dd HH:mm:ss').parse(RegExp(r'(?<=start_date: ).*').stringMatch(issue.body!)!),
        end: DateFormat('yyyy/MM/dd HH:mm:ss').parse(RegExp(r'(?<=due_date: ).*').stringMatch(issue.body!)!),
      );  
    } catch (e) {
      periodoDaTarefa = DateTimeRange(
        start: DateFormat('yyyy/MM/dd').parse(RegExp(r'(?<=start_date: ).*').stringMatch(issue.body!)!),
        end: DateFormat('yyyy/MM/dd').parse(RegExp(r'(?<=due_date: ).*').stringMatch(issue.body!)!),
      );
    }

    return periodoDaTarefa;
  }

  void rememberScrollPositions() {
    try {
      GanttChartController.instance.controllers.jumpTo(GanttChartController.instance.lastVerticalPos);
      
      if (GanttChartController.instance.columnsScrollController.hasClients) {
        GanttChartController.instance.columnsScrollController.jumpTo(GanttChartController.instance.lastHorizontalPos);
      }
    } catch (e) {
      Future.delayed(const Duration(milliseconds: 100), rememberScrollPositions);
    }
  }

  double get issuesListWidth => _issuesListWidth;
  set issuesListWidth(double value) {
    _issuesListWidth = value;
    update();
  }

  Future<void> onPointerDown(PointerDownEvent event, BuildContext context) async {
    Future.delayed(const Duration(milliseconds: 50), () async {
      onPointerDownTime = DateTime.now();

      if (contextIssueIndex != -1) {
        await onIssueRightButton(context, event);
      }
      else {
        _onGridPointerDown(event, context);
      }

      contextIssueIndex = -1;
    });
  }

  Future<void> onPointerUp(PointerUpEvent event, BuildContext context) async {
    Future.delayed(const Duration(milliseconds: 50), () async {
      if (contextIssueIndex != -1) {
        await onIssueRightButton(context, event);
      }
      else {
        _onGridPointerDown(event, context);
      }

      contextIssueIndex = -1;
    });
  }

  void _onGridPointerDown(PointerEvent event, BuildContext context) {
    // Check if right mouse button clicked
    if ((event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) || (onPointerDownTime != null && DateTime.now().difference(onPointerDownTime!).inMilliseconds >= 750)) {
      RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
      showMenu<int>(
        context: context,
        items: [
          const PopupMenuItem(value: 1, child: Text('+3 dias no início')),
          const PopupMenuItem(value: 2, child: Text('+3 dias no final')),
          const PopupMenuItem(value: 3, child: Text('Nova tarefa')),
        ],
        position: RelativeRect.fromSize(
          event.position & const Size(48.0, 48.0), overlay.size
        )
      ).then((menuItem) async {
        // Check if menu item clicked
        switch (menuItem) {
          case 1:
            addDaysOnStart();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('+3 dias no início'),
              behavior: SnackBarBehavior.floating,
            ));
          break;
          case 2:
            addDaysOnEnd();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('+3 dias no final'),
                behavior: SnackBarBehavior.floating));
          break;
          case 3:
            context.go('/newIssue');
          break;
        }
      });
    }
  }

  List<DateTime> calculateNumberOfColumnsBetween(DateTime from, DateTime to) {
    List<DateTime> period = [];
    DateTime currentDate = from;

    do {
      period.add(currentDate);
      currentDate = currentDate.add(Configs.graphColumnsPeriod);
    } while (currentDate.compareTo(to) < 0);
    
    return period;
  }

  void launchURL(String url) async {
    Uri encodedUrl = Uri.parse(Uri.encodeFull(url));
    
    if (await canLaunchUrl(encodedUrl)) {
      await launchUrl(encodedUrl, mode: LaunchMode.inAppWebView);
    }
    
    return;
  }

  Future<void> onIssueRightButton(BuildContext context, [PointerEvent? event, LongPressEndDetails? longPressDetails]) async {
    // Check if right mouse button clicked
    if (selectedIssues.isNotEmpty && ((event != null && event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) || longPressDetails != null)) {
      onPointerDownTime = null;

      List<PopupMenuEntry<int>> items = [
        const PopupMenuItem(value: 2, child: Text('Excluir tarefas selecionadas')),
        const PopupMenuItem(value: 3, child: Text('Inverter estado (aberta/fechada) das tarefas selecionadas')),
      ];

      if (selectedIssues.length == 1) {
        items.insert(0, PopupMenuItem(value: 1, child: Text('Editar tarefa #${selectedIssues[0]!.number}')));
      }

      RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
      await showMenu<int>(
        context: context,
        items: items,
        position: RelativeRect.fromSize(
          (event != null ? event.position : longPressDetails!.globalPosition) & const Size(48.0, 48.0),
          overlay.size
        )
      ).then((menuItem) async {
        // Check if menu item clicked
        switch (menuItem) {
          // Default precisa estar vazio por conta da não escolha
          case 1:
            context.go('/updateIssue');
          break;
          case 2:
            gitHub!.deleteSelectedIssues();
          break;
          case 3:
            await gitHub!.changeSelectedIssuesState();
          break;
        }
      });
    }
  }

  void addDaysOnStart() {
    fromDate = fromDate!.subtract(const Duration(days: 3));
    viewRange = calculateNumberOfColumnsBetween(fromDate!, toDate!);
  }

  void addDaysOnEnd() {
    toDate = toDate!.add(const Duration(days: 3));
    viewRange = calculateNumberOfColumnsBetween(fromDate!, toDate!);
  }

  int calculateWidthInColumns(
      DateTime projectStartedAt, DateTime projectEndedAt) {
    int projectLength = calculateNumberOfColumnsBetween(projectStartedAt, projectEndedAt).length;
    if (projectStartedAt.compareTo(fromDate!) >= 0 && projectStartedAt.compareTo(toDate!) <= 0) {
      if (projectLength <= viewRange!.length) {
        return projectLength;
      } else {
        return viewRange!.length - calculateNumberOfColumnsBetween(fromDate!, projectStartedAt).length;
      }
    } else if (projectStartedAt.isBefore(fromDate!) && projectEndedAt.isBefore(fromDate!)) {
      return 0;
    } else if (projectStartedAt.isBefore(fromDate!) && projectEndedAt.isBefore(toDate!)) {
      return projectLength - calculateNumberOfColumnsBetween(projectStartedAt, fromDate!).length;
    } else if (projectStartedAt.isBefore(instance.fromDate!) && projectEndedAt.isAfter(toDate!)) {
      return viewRange!.length;
    }
    return 0;
  }

  int calculateColumnsToLeftBorder(DateTime projectStartedAt) {
    if (projectStartedAt.compareTo(fromDate!) <= 0) {
      return 0;
    } else {
      return calculateNumberOfColumnsBetween(fromDate!, projectStartedAt).length;
    }
  }

  int calculateColumnsToRightBorder(DateTime projectEndedAt) {
    if (projectEndedAt.compareTo(toDate!) > 0) {
      return 0;
    } else {
      return calculateNumberOfColumnsBetween(projectEndedAt, toDate!).length;
    }
  }

  void onScrollChange() {
    for (int i = 0; i < selectedIssues.length; i++) {
      bool overChartLimits = false;
      bool underChartLimits = false;

      if (selectedIssues[i]!.dragPosFactor.abs() >= 0.4 && selectedIssues[i] != null) {
        if (isPanStartActive && selectedIssues[i]!.dragPosFactor.sign < 0) {
          underChartLimits = calculateColumnsToLeftBorder(selectedIssues[i]!.startTime!) * chartColumnsWidth + selectedIssues[i]!.deltaWidth + deltaScrollPos < horizontalController.offset;

          if (underChartLimits) {
            Log.show('d', 'isPanStartActive && selectedIssues[i]!.dragPosFactor.sign < 0 - underChartLimits');
            selectedIssues[i]!.deltaWidth = horizontalController.offset - calculateColumnsToLeftBorder(selectedIssues[i]!.startTime!) * chartColumnsWidth;
          }
          else {
            Log.show('d', 'isPanStartActive && selectedIssues[i]!.dragPosFactor.sign < 0 - none');
            selectedIssues[i]!.deltaWidth += deltaScrollPos;
          }
        }
        else if (isPanStartActive && selectedIssues[i]!.dragPosFactor.sign > 0) {
          overChartLimits = calculateColumnsToLeftBorder(selectedIssues[i]!.startTime!) * chartColumnsWidth + selectedIssues[i]!.deltaWidth + deltaScrollPos > horizontalController.offset + chartPanelWidth;

          if (overChartLimits) {
            Log.show('d', 'isPanStartActive && selectedIssues[i]!.dragPosFactor.sign > 0 - overChartLimits');
            selectedIssues[i]!.deltaWidth = (horizontalController.offset + chartPanelWidth) - calculateColumnsToLeftBorder(selectedIssues[i]!.startTime!) * chartColumnsWidth - chartColumnsWidth;
          }
          else {
            Log.show('d', 'isPanStartActive && selectedIssues[i]!.dragPosFactor.sign > 0 - none');
            selectedIssues[i]!.deltaWidth += deltaScrollPos;
          }
        }
        else if (isPanEndActive && selectedIssues[i]!.dragPosFactor.sign < 0) {
          underChartLimits = calculateColumnsToLeftBorder(selectedIssues[i]!.endTime!) * chartColumnsWidth + selectedIssues[i]!.deltaWidth + deltaScrollPos < horizontalController.offset;

          if (underChartLimits) {
            Log.show('d', 'isPanEndActive && selectedIssues[i]!.dragPosFactor.sign < 0 - underChartLimits');
            selectedIssues[i]!.deltaWidth = horizontalController.offset - calculateColumnsToLeftBorder(selectedIssues[i]!.endTime!) * chartColumnsWidth + chartColumnsWidth;
          }
          else {
            Log.show('d', 'isPanEndActive && selectedIssues[i]!.dragPosFactor.sign < 0 - none');
            selectedIssues[i]!.deltaWidth += deltaScrollPos;
          }
        }
        else if (isPanEndActive && selectedIssues[i]!.dragPosFactor.sign > 0) {
          overChartLimits = calculateColumnsToLeftBorder(selectedIssues[i]!.endTime!) * chartColumnsWidth + selectedIssues[i]!.deltaWidth + deltaScrollPos > horizontalController.offset + chartPanelWidth;

          if (overChartLimits) {
            Log.show('d', 'isPanEndActive && selectedIssues[i]!.dragPosFactor.sign > 0 - overChartLimits');
            selectedIssues[i]!.deltaWidth = (horizontalController.offset + chartPanelWidth) - calculateColumnsToLeftBorder(selectedIssues[i]!.endTime!) * chartColumnsWidth;
          }
          else {
            Log.show('d', 'isPanEndActive && selectedIssues[i]!.dragPosFactor.sign > 0 - none');
            selectedIssues[i]!.deltaWidth += deltaScrollPos;
          }
        }
        else if (isPanMiddleActive) {
          selectedIssues[i]!.deltaWidth += deltaScrollPos;
        }
        /*else if (isPanMiddleActive && selectedIssues[i]!.dragPosFactor.sign < 0) {
          underChartLimits = calculateColumnsToLeftBorder(selectedIssues[i]!.startTime!) * chartColumnsWidth + selectedIssues[i]!.deltaWidth + deltaScrollPos < horizontalController.offset;

          if (underChartLimits) {
            Log.show('d', 'isPanMiddleActive && selectedIssues[i]!.dragPosFactor.sign < 0 - underChartLimits');
            selectedIssues[i]!.deltaWidth = horizontalController.offset - calculateColumnsToLeftBorder(selectedIssues[i]!.startTime!) * chartColumnsWidth;
          }
          else {
            Log.show('d', 'isPanMiddleActive && selectedIssues[i]!.dragPosFactor.sign < 0 - none');
            selectedIssues[i]!.deltaWidth += deltaScrollPos;
          }

          bool overChartMaxLimits = calculateColumnsToLeftBorder(selectedIssues[i]!.endTime!) * chartColumnsWidth + selectedIssues[i]!.deltaWidth + deltaScrollPos > horizontalController.offset + chartPanelWidth
            && horizontalController.offset + chartPanelWidth == calculateNumberOfColumnsBetween(fromDate!, toDate!).length * chartColumnsWidth;

          if (overChartMaxLimits) {
            Log.show('d', 'isPanMiddleActive && selectedIssues[i]!.dragPosFactor.sign < 0 - overChartMaxLimits');
            selectedIssues[i]!.deltaWidth = (horizontalController.offset + chartPanelWidth) - calculateColumnsToLeftBorder(selectedIssues[i]!.endTime!) * chartColumnsWidth;
          }
        }
        else if (isPanMiddleActive && selectedIssues[i]!.dragPosFactor.sign > 0) {
          overChartLimits = calculateColumnsToLeftBorder(selectedIssues[i]!.endTime!) * chartColumnsWidth + selectedIssues[i]!.deltaWidth + deltaScrollPos > horizontalController.offset + chartPanelWidth;

          if (overChartLimits) {
            Log.show('d', 'isPanMiddleActive && selectedIssues[i]!.dragPosFactor.sign > 0 - overChartLimits');
            selectedIssues[i]!.deltaWidth = (horizontalController.offset + chartPanelWidth) - calculateColumnsToLeftBorder(selectedIssues[i]!.endTime!) * chartColumnsWidth;
          }
          else {
            Log.show('d', 'isPanMiddleActive && selectedIssues[i]!.dragPosFactor.sign > 0 - none');
            selectedIssues[i]!.deltaWidth += deltaScrollPos;
          }

          bool underChartMaxLimits = calculateColumnsToLeftBorder(selectedIssues[i]!.startTime!) * chartColumnsWidth + selectedIssues[i]!.deltaWidth + deltaScrollPos <= 0;

          if (underChartMaxLimits) {
            Log.show('d', 'isPanMiddleActive && selectedIssues[i]!.dragPosFactor.sign > 0 - underChartMaxLimits');
            selectedIssues[i]!.deltaWidth = horizontalController.offset - calculateColumnsToLeftBorder(selectedIssues[i]!.startTime!) * chartColumnsWidth;
          }
        }*/
      }
    }

    lastScrollPos = horizontalController.offset;
  }

  initialize() {
    columnsScrollController = horizontalController.addAndGet();
    hoursScrollController = horizontalController.addAndGet();
    daysScrollController = horizontalController.addAndGet();
    singleChildScrollController = horizontalController.addAndGet();
    chartBarsController = controllers.addAndGet();
    chartDependencyLinesController = controllers.addAndGet();
    listController = controllers.addAndGet();
    userColor = randomColorGenerator();
    GanttChartController.instance.horizontalController.removeOffsetChangedListener(onScrollChange);
    horizontalController.addOffsetChangedListener(onScrollChange);
  }

  refreshFocusAttachment(BuildContext context) {
    if (nodeAttachment != null && nodeAttachment!.isAttached) {
      nodeAttachment!.detach();
    }

    nodeAttachment = focus.attach(context, onKeyEvent: (node, event) {
      if (event.physicalKey == PhysicalKeyboardKey.altLeft) {
        isAltPressed = event is! KeyUpEvent;
      }

      if (event.logicalKey == LogicalKeyboardKey.shiftLeft) {
        isShiftPressed = event is! KeyUpEvent;
      }

      if (event.physicalKey == PhysicalKeyboardKey.controlLeft) {
        isCtrlPressed = event is! KeyUpEvent;
      }

      update();
      return KeyEventResult.handled;
    });
  }

  setContext(BuildContext context, double issueListFutureWidth) {
    rootContext = context;
    _issuesListWidth = issueListFutureWidth;
  }
  
  void update() {
    notifyListeners();
  }

  void onIssueStartUpdate(BuildContext context, DragUpdateDetails details, double chartAreaWidth) {
    currentDragX = details.globalPosition.dx;
    isPanUpdateActive = true;

    for (int j = 0; j < selectedIssues.length; j++) {
      if (selectedIssues[j]!.widthInColumns! * chartColumnsWidth - (details.globalPosition.dx - initX - (selectedIssues[j]!.startPanChartPos - horizontalController.offset)) >= chartColumnsWidth) {
        if (calculateColumnsToLeftBorder(selectedIssues[j]!.startTime!) * chartColumnsWidth + (details.globalPosition.dx - initX - (selectedIssues[j]!.startPanChartPos - horizontalController.offset)) > 0) {
          selectedIssues[j]!.deltaWidth = details.globalPosition.dx - initX - (selectedIssues[j]!.startPanChartPos - horizontalController.offset);
          selectedIssues[j]!.dragPosFactor = (details.globalPosition.dx - (MediaQuery.of(context).size.width - chartAreaWidth)) / chartAreaWidth - 0.5;
        }
        else {
          return;
        }
      }
      else {
        selectedIssues[j]!.dragPosFactor = 0;
        selectedIssues[j]!.deltaWidth = (selectedIssues[j]!.widthInColumns! - 1) * chartColumnsWidth;
      }
    }
  }

  void onIssueEndUpdate(BuildContext context, DragUpdateDetails details, double chartAreaWidth) {
    currentDragX = details.globalPosition.dx;
    isPanUpdateActive = true;

    for (int j = 0; j < selectedIssues.length; j++) {
      if (selectedIssues[j]!.widthInColumns! * chartColumnsWidth + (details.globalPosition.dx - initX - (selectedIssues[j]!.startPanChartPos - horizontalController.offset)) >= chartColumnsWidth) {
        if (calculateColumnsToRightBorder(selectedIssues[j]!.endTime!) * chartColumnsWidth - (details.globalPosition.dx - initX - (selectedIssues[j]!.startPanChartPos - horizontalController.offset)) > 0) {
          selectedIssues[j]!.deltaWidth = details.globalPosition.dx - initX - (selectedIssues[j]!.startPanChartPos - horizontalController.offset);
          selectedIssues[j]!.dragPosFactor = (details.globalPosition.dx - (MediaQuery.of(context).size.width - chartAreaWidth)) / chartAreaWidth - 0.5;
        }
        else {
          return;
        }
      }
      else {
        selectedIssues[j]!.dragPosFactor = 0;
        selectedIssues[j]!.deltaWidth = (selectedIssues[j]!.widthInColumns! - 1) * chartColumnsWidth;
      }
    }
  }

  void onIssueDateUpdate(BuildContext context, DragUpdateDetails details, double chartAreaWidth) {
    currentDragX = details.globalPosition.dx;
    isPanUpdateActive = true;

    for (int j = 0; j < selectedIssues.length; j++) {
      Log.show('d', '${selectedIssues[j]!.deltaWidth}');

      if (calculateColumnsToLeftBorder(selectedIssues[j]!.startTime!) * chartColumnsWidth + (details.globalPosition.dx - initX - (selectedIssues[j]!.startPanChartPos - horizontalController.offset)) > 0 &&
        calculateColumnsToLeftBorder(selectedIssues[j]!.startTime!) * chartColumnsWidth + (details.globalPosition.dx - initX - (selectedIssues[j]!.startPanChartPos - horizontalController.offset)) < chartColumnsWidth * viewRange!.length &&
        calculateColumnsToRightBorder(selectedIssues[j]!.endTime!) * chartColumnsWidth - (details.globalPosition.dx - initX - (selectedIssues[j]!.startPanChartPos - horizontalController.offset)) > 0) {
        selectedIssues[j]!.deltaWidth = details.globalPosition.dx - initX - (selectedIssues[j]!.startPanChartPos - horizontalController.offset);
        selectedIssues[j]!.dragPosFactor = (details.globalPosition.dx - (MediaQuery.of(context).size.width - chartAreaWidth)) / chartAreaWidth - 0.5;
      }
      else {
        return;
      }
    }
  }

  void onIssueStartPan(PanType type, double startMousePos) {
    for (int j = 0; j < selectedIssues.length; j++) {
      selectedIssues[j]!.draggingRemainingWidth = selectedIssues[j]!.widthInColumns!;
      selectedIssues[j]!.startPanChartPos = horizontalController.offset;
    }
    
    if (selectedIssues.isNotEmpty) {
      switch (type) {
        case PanType.start:
          isPanStartActive = true;
        break;
        case PanType.end:
          isPanEndActive = true;
        break;
        default:
          isPanMiddleActive = true;
      }

      update();
    }
  }

  void onIssuePanCancel(PanType type) {
    for (int j = 0; j < selectedIssues.length; j++) {
      selectedIssues[j]!.dragPosFactor = 0;
      selectedIssues[j]!.deltaWidth = 0;
      selectedIssues[j]!.widthInColumns = selectedIssues[j]!.widthInColumns! + dx.toInt();
    }

    isPanStartActive = false;
    isPanEndActive = false;
    isPanMiddleActive = false;
    isPanUpdateActive = false;
    update();
  }

  void onIssueEndPan(PanType type) {
    for (int j = 0; j < selectedIssues.length; j++) {
      int triHoursInterval = (selectedIssues[j]!.deltaWidth / (chartColumnsWidth)).abs().round() * Configs.graphColumnsPeriod.inHours;

      if (triHoursInterval > 0) {
        if (type == PanType.start || type == PanType.middle) {
          if (selectedIssues[j]!.deltaWidth > (chartColumnsWidth * 0.5)) {
            selectedIssues[j]!.startTime = selectedIssues[j]!.startTime!.add(Duration(hours: triHoursInterval));
          } else if (selectedIssues[j]!.deltaWidth < -(chartColumnsWidth * 0.5)) {
            selectedIssues[j]!.startTime = selectedIssues[j]!.startTime!.subtract(Duration(hours: triHoursInterval));
          }
        }

        if (type == PanType.end || type == PanType.middle) {
          if (selectedIssues[j]!.deltaWidth > (chartColumnsWidth * 0.5)) {
            selectedIssues[j]!.endTime = selectedIssues[j]!.endTime!.add(Duration(hours: triHoursInterval));
          } else if (selectedIssues[j]!.deltaWidth < -(chartColumnsWidth * 0.5)) {
            selectedIssues[j]!.endTime = selectedIssues[j]!.endTime!.subtract(Duration(hours: triHoursInterval));
          }
        }

        selectedIssues[j]!.deltaWidth = 0;
        selectedIssues[j]!.toggleProcessing();

        gitHub!.updateIssueTime(selectedIssues[j]!).then((value) async {
          if (value != null) {
            Issue? temp = selectedIssues.singleWhereOrNull((el) => el!.nodeId == value.nodeId);

            if (temp != null) {
              temp.body = value.body;
              temp.startTime = value.startTime;
              temp.endTime = value.endTime;
              temp.state = value.state;
              temp.title = value.title;
              temp.value = value.value;
              temp.dragPosFactor = 0;
              temp.widthInColumns = temp.widthInColumns! + dx.toInt();
              temp.toggleProcessing();

              if (j == selectedIssues.length - 1) {
                isPanStartActive = false;
                isPanEndActive = false;
                isPanMiddleActive = false;
                isPanUpdateActive = false;
                update();
              }
            }
            else {
              Log.show('d', 'Issue #${value.number} não está mais selecionada.');
            }
          }
        });
      }
      else {
        isPanStartActive = false;
        isPanEndActive = false;
        isPanMiddleActive = false;
        isPanUpdateActive = false;
        selectedIssues[j]!.deltaWidth = 0;
        selectedIssues[j]!.dragPosFactor = 0;
        selectedIssues[j]!.update();
        update();
      }
    }
  }

  Future<void> removeIssueSelection() async {
    for (int i = 0; i < selectedIssues.length; i++) {
      if (selectedIssues[i]!.selected) {
        selectedIssues[i]!.toggleSelect();
      }

      if (selectedIssues[i]!.processing) {
        Log.show('d', 'Processando issue #${selectedIssues[i]!.number}. Aguardando 100 ms para tentar novamente...');
        return await Future.delayed(const Duration(milliseconds: 100), () => removeIssueSelection());
      }
      
      selectedIssues.remove(selectedIssues[i]!);
      i--;
    }
  }

  void issueSelect(Issue issue, List<Issue> pIssueList) {
    if (!isShiftPressed && !issue.selected) {
      removeIssueSelection();
    }

    if (isShiftPressed && isCtrlPressed) {
      int start = 0;
      
      if (selectedIssues.isNotEmpty) {
        start = pIssueList.indexOf(selectedIssues[selectedIssues.length - 1]!);
      }
      
      int end = pIssueList.indexOf(issue);

      for (int j = start; start < end ? j <= end : j >= end; start < end ? j++ : j--) {
        if (!pIssueList[j].selected) {
          selectedIssues.add(pIssueList[j]);
          pIssueList[j].toggleSelect();
        }
      }
    }
    else {
      issue.toggleSelect();

      if (issue.selected) {
        horizontalController.animateTo(
          GanttChartController.instance.calculateColumnsToLeftBorder(issue.startTime!.subtract(Duration(hours: Configs.graphColumnsPeriod.inHours * 3))) * GanttChartController.instance.chartColumnsWidth,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 1000),
        );
        selectedIssues.add(issue);
      }
      else {
        selectedIssues.remove(issue);
      }
    }
  }
}