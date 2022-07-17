import 'dart:math';

import 'package:flutter/material.dart';
import '../controller/gantt_chart_controller.dart';
import 'package:provider/provider.dart';
import '../model/issue.dart';

List<Map<String, num>> lineHorPos = [];
List<Color> lineColors = [];

class DependencyLine extends CustomPainter {
  const DependencyLine({
    Key? key,
    required this.allIssue,
    required this.issue,
    required this.depIssuesNumbers,
    required this.index,
    required this.color,
  });

  final Issue issue;
  final List<int> depIssuesNumbers;
  final List<Issue> allIssue;
  final int index;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    lineHorPos.removeWhere((el) => el['index'] == index);

    double getAvailablePath(double value) {
      if (lineHorPos.indexWhere((el) => el['pos'] == value) > -1) {
        return getAvailablePath(value - 4);
      }
      else {
        return value;
      }
    }

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
            ) - 20;

          double leftPos = getAvailablePath(-(issueLeft - depIssueLeft));

          canvas.drawPath(
            Path()..moveTo(
              issueLeft + 7.5,
              15 + 2)
              ..relativeLineTo(leftPos, 0)
              ..relativeLineTo(0, (-30 - 4) * indexDif.toDouble())
              ..relativeLineTo(-(issueLeft - depIssueLeft) - leftPos + 15, 0),
            Paint()..color = color
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeWidth = 1,
          );
          lineHorPos.add({'index': index, 'pos': leftPos});
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
  bool shouldRepaint(DependencyLine oldDelegate) => false;
}

class ChartBarsDependencyLines extends StatelessWidget {
  final List<Issue> data;
  final Color color;
  final GanttChartController gantChartController;
  final BoxConstraints constraints;

  const ChartBarsDependencyLines({
    Key? key,
    required this.gantChartController,
    required this.constraints,
    this.color = Colors.blue,
    this.data = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    lineColors.clear();

    for (int i = 0; i < data.length; i++) {
      lineColors.add(Color.fromARGB(255, Random().nextInt(256), Random().nextInt(256), Random().nextInt(256)));
    }

    return Container(
      margin: const EdgeInsets.only(top: 30.0),
      child: SingleChildScrollView(
        controller: gantChartController.chartDependencyLinesController,
        child: Column(
          children: List.generate(data.length, (index) {
            return ChangeNotifierProvider<Issue>.value(
              value: data[index],
              child: Consumer<Issue>(
                builder: (issuesContext, issuesValue, child) {
                  if (issuesValue.dependencies.isNotEmpty) {
                    issuesValue.remainingWidth = GanttChartController.instance.calculateRemainingWidth(issuesValue.startTime!, issuesValue.endTime!);

                    if (issuesValue.remainingWidth! > 0) {
                      return Container(
                        margin: EdgeInsets.only(
                          top: index == 0 ? 4.0 : 2.0,
                          bottom: index == data.length - 1 ? 4.0 : 2.0
                        ),
                        height: 30.0,
                        child: CustomPaint(
                          painter: DependencyLine(
                            allIssue: data,
                            issue: issuesValue,
                            depIssuesNumbers: issuesValue.dependencies,
                            index: index,
                            color: lineColors.removeAt(0)
                          ),
                          child: SizedBox(
                            width: GanttChartController.instance.calculateNumberOfDaysBetween(
                              GanttChartController.instance.fromDate!,
                              GanttChartController.instance.toDate!
                            ).length * GanttChartController.instance.chartViewWidth / GanttChartController.instance.viewRangeToFitScreen!,
                            height: (data.length * 34) - 4,
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }
                  else {
                    return Container(
                      margin: EdgeInsets.only(
                        top: index == 0 ? 4.0 : 2.0,
                        bottom: index == data.length - 1 ? 4.0 : 2.0
                      ),
                      height: 30.0,
                    );
                  }
                }
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}