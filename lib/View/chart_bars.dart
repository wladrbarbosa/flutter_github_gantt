import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller/gantt_chart_controller.dart';
import 'package:provider/provider.dart';
import '../model/issue.dart';

class DependencyLine extends CustomPainter {
  const DependencyLine({
    Key? key,
    required this.allIssue,
    required this.issue,
    required this.depIssuesNumbers,
  });

  final Issue issue;
  final List<int> depIssuesNumbers;
  final List<Issue> allIssue;

  @override
  void paint(Canvas canvas, Size size) {
    if (depIssuesNumbers.isNotEmpty) {
      List<Issue> depIssues = depIssuesNumbers.map<Issue>((e) => allIssue.singleWhere((el) => el.number == e)).toList();
      for (var el in depIssues) {
        int indexDif = allIssue.indexOf(issue) - allIssue.indexOf(el);
        
        if (indexDif > 0) {
          double issueLeft = GanttChartController.instance.calculateDistanceToLeftBorder(issue.startTime!) *
            GanttChartController.instance.chartViewWidth /
            GanttChartController.instance.viewRangeToFitScreen! + (
              GanttChartController.instance.isPanStartActive ||
              GanttChartController.instance.isPanMiddleActive ?
                issue.width :
                0
            );
          double depIssueLeft = GanttChartController.instance.calculateDistanceToLeftBorder(el.startTime!) *
            GanttChartController.instance.chartViewWidth /
            GanttChartController.instance.viewRangeToFitScreen! + (
              GanttChartController.instance.isPanStartActive ||
              GanttChartController.instance.isPanMiddleActive ?
                el.width :
                0
            );
          canvas.drawPath(
            Path()..moveTo(
              issueLeft + 7.5,
              15 + 2)
              ..relativeLineTo(-(issueLeft - depIssueLeft), 0)
              ..relativeLineTo(0, (-30 - 4) * indexDif.toDouble() + 14),
            Paint()..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeWidth = 1,
          );
        }
      }
    }
  }

  // Since this Sky painter has no fields, it always paints
  // the same thing and semantics information is the same.
  // Therefore we return false here. If we had fields (set
  // from the constructor) then we would return true if any
  // of them differed from the same fields on the oldDelegate.
  @override
  bool shouldRepaint(DependencyLine oldDelegate) => true;
}

class ChartBars extends StatelessWidget {
  final List<Issue> data;
  final Color color;
  final GanttChartController gantChartController;
  final BoxConstraints constraints;

  const ChartBars({
    Key? key,
    required this.gantChartController,
    required this.constraints,
    this.color = Colors.blue,
    this.data = const [],
  }) : super(key: key);

  _handleDrag(details) {
    GanttChartController.instance.initX = details.globalPosition.dx;
    GanttChartController.instance.initY = details.globalPosition.dy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30.0),
      child: Stack(
        children: [
          ListView.builder(
            physics: gantChartController.isAltPressed ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
            controller: gantChartController.chartController,
            itemCount: data.length,
            itemBuilder: (listContext, index) {
              return ChangeNotifierProvider<Issue>.value(
                value: data[index],
                child: Consumer<Issue>(
                  builder: (issuesContext, issuesValue, child) {
                    issuesValue.remainingWidth = GanttChartController.instance.calculateRemainingWidth(issuesValue.startTime!, issuesValue.endTime!);

                    if (issuesValue.remainingWidth! > 0) {
                      return Stack(
                        clipBehavior: Clip.none,
                        fit: StackFit.passthrough,
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: CustomPaint(
                              painter: DependencyLine(
                                allIssue: data,
                                issue: issuesValue,
                                depIssuesNumbers: issuesValue.dependencies
                              ),
                              child: SizedBox(
                                width: GanttChartController.instance.calculateNumberOfDaysBetween(
                                  GanttChartController.instance.fromDate!,
                                  GanttChartController.instance.toDate!
                                ).length * GanttChartController.instance.chartViewWidth / GanttChartController.instance.viewRangeToFitScreen!,
                                height: (data.length * 34) - 4,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              GanttChartController.instance.issueSelect(issuesValue, data);
                            },
                            onLongPressEnd: (event) {
                              GanttChartController.instance.onIssueRightButton(context, null, event);
                            },
                            child: Listener(
                              onPointerDown: (event) async {
                                GanttChartController.instance.contextIssueIndex = index;
                                
                                if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton && !issuesValue.selected) {
                                  GanttChartController.instance.issueSelect(issuesValue, GanttChartController.instance.issueList!);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: issuesValue.state == 'open' ? issuesValue.startTime!.compareTo(DateFormat('yyyy/MM/dd').parse(DateFormat('yyyy/MM/dd').format(DateTime.now()))) < 0 && issuesValue.endTime!.compareTo(DateFormat('yyyy/MM/dd').parse(DateFormat('yyyy/MM/dd').format(DateTime.now()))) < 0 ? Colors.purple.withAlpha(100) : Colors.red.withAlpha(100) : Colors.green.withAlpha(100),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: Colors.yellow,
                                    width: 1,
                                    style: issuesValue.selected ? BorderStyle.solid : BorderStyle.none,
                                  )
                                ),
                                height: 30.0,
                                width: issuesValue.remainingWidth! * GanttChartController.instance.chartViewWidth / GanttChartController.instance.viewRangeToFitScreen! - (GanttChartController.instance.isPanStartActive ? issuesValue.width : GanttChartController.instance.isPanEndActive ? -issuesValue.width : 0),
                                margin: EdgeInsets.only(
                                  left: GanttChartController.instance.calculateDistanceToLeftBorder(issuesValue.startTime!) *
                                      GanttChartController.instance.chartViewWidth /
                                      GanttChartController.instance.viewRangeToFitScreen! + (GanttChartController.instance.isPanStartActive || GanttChartController.instance.isPanMiddleActive ? issuesValue.width : 0),
                                  right: GanttChartController.instance.calculateDistanceToRightBorder(issuesValue.endTime!) *
                                      GanttChartController.instance.chartViewWidth /
                                      GanttChartController.instance.viewRangeToFitScreen! - (GanttChartController.instance.isPanEndActive || GanttChartController.instance.isPanMiddleActive ? issuesValue.width : 0),
                                  top: index == 0 ? 4.0 : 2.0,
                                  bottom: index == data.length - 1 ? 4.0 : 2.0
                                ),
                                child: issuesValue.processing ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                                  child: const Center(
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: CircularProgressIndicator()
                                    ),
                                  )
                                ) : Row(
                                  children: [
                                    GestureDetector(
                                      onPanStart: _handleDrag,
                                      onPanUpdate: (details) {
                                        GanttChartController.instance.onIssueStartUpdate(issuesContext, details, constraints.biggest.width);
                                      },
                                      onPanDown: (details) {
                                        GanttChartController.instance.onIssueStartPan(PanType.start, details.globalPosition.dx);
                                      },
                                      onPanCancel: () {
                                        GanttChartController.instance.onIssuePanCancel(PanType.start);
                                      },
                                      onPanEnd: (details) async {
                                        GanttChartController.instance.onIssueEndPan(PanType.start);
                                      },
                                      child: Container(
                                        width: (issuesValue.remainingWidth! * GanttChartController.instance.chartViewWidth / GanttChartController.instance.viewRangeToFitScreen! - (GanttChartController.instance.isPanStartActive ? issuesValue.width : GanttChartController.instance.isPanEndActive ? -issuesValue.width : 0)) / 2 - 1 < 15 ? (issuesValue.remainingWidth! * GanttChartController.instance.chartViewWidth / GanttChartController.instance.viewRangeToFitScreen! - (GanttChartController.instance.isPanStartActive ? issuesValue.width : GanttChartController.instance.isPanEndActive ? -issuesValue.width : 0)) / 2 - 1 : 15,
                                        decoration: BoxDecoration(
                                          color: issuesValue.state == 'open' ? issuesValue.startTime!.compareTo(DateFormat('yyyy/MM/dd').parse(DateFormat('yyyy/MM/dd').format(DateTime.now()))) < 0 ? Colors.purple : Colors.red : Colors.green,
                                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), topLeft: Radius.circular(10)),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onPanStart: _handleDrag,
                                        onPanUpdate: (details) {
                                          GanttChartController.instance.onIssueDateUpdate(issuesContext, details, constraints.biggest.width);
                                        },
                                        onPanDown: (details) {
                                          GanttChartController.instance.onIssueStartPan(PanType.middle, details.globalPosition.dx);
                                        },
                                        onPanCancel: () {
                                          GanttChartController.instance.onIssuePanCancel(PanType.middle);
                                        },
                                        onPanEnd: (details) async {
                                          GanttChartController.instance.onIssueEndPan(PanType.middle);
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: Text(
                                            issuesValue.title!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 10.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onPanStart: _handleDrag,
                                      onPanUpdate: (details) {
                                        GanttChartController.instance.onIssueEndUpdate(issuesContext, details, constraints.biggest.width);
                                      },
                                      onPanDown: (details) {
                                        GanttChartController.instance.onIssueStartPan(PanType.end, details.globalPosition.dx);
                                      },
                                      onPanCancel: () {
                                        GanttChartController.instance.onIssuePanCancel(PanType.end);
                                      },
                                      onPanEnd: (details) async {
                                        GanttChartController.instance.onIssueEndPan(PanType.end);
                                      },
                                      child: Container(
                                        width: (issuesValue.remainingWidth! * GanttChartController.instance.chartViewWidth / GanttChartController.instance.viewRangeToFitScreen! - (GanttChartController.instance.isPanStartActive ? issuesValue.width : GanttChartController.instance.isPanEndActive ? -issuesValue.width : 0)) / 2 - 1 < 15 ? (issuesValue.remainingWidth! * GanttChartController.instance.chartViewWidth / GanttChartController.instance.viewRangeToFitScreen! - (GanttChartController.instance.isPanStartActive ? issuesValue.width : GanttChartController.instance.isPanEndActive ? -issuesValue.width : 0)) / 2 - 1 : 15,
                                        decoration: BoxDecoration(
                                          color: issuesValue.state == 'open' ? issuesValue.endTime!.compareTo(DateFormat('yyyy/MM/dd').parse(DateFormat('yyyy/MM/dd').format(DateTime.now()))) < 0 ? Colors.purple : Colors.red : Colors.green,
                                          borderRadius: const BorderRadius.only(bottomRight: Radius.circular(10), topRight: Radius.circular(10)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  }
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}