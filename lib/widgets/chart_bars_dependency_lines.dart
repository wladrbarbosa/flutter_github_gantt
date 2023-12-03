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

    double getAvailablePath(double value, Issue issue, double distanceToLeftBorderIssue) {
      if (lineHorPos.indexWhere((el) => (el['pos'] == distanceToLeftBorderIssue + value)) > -1) {
        return getAvailablePath(value - 4, issue, distanceToLeftBorderIssue);
      }
      else {
        return value;
      }
    }

    if (depIssuesNumbers.isNotEmpty) {
      List<Issue> depIssues = allIssue.where((el) => depIssuesNumbers.contains(el.number)).toList();
      for (var el in depIssues) {
        int indexDif = allIssue.indexOf(issue) - allIssue.indexOf(el);
        double distanceToLeftBorderDep = GanttChartController.instance.calculateColumnsToLeftBorder(el.startTime!) * GanttChartController.instance.chartColumnsWidth;
        double distanceToLeftBorderIssue = GanttChartController.instance.calculateColumnsToLeftBorder(issue.startTime!) * GanttChartController.instance.chartColumnsWidth;
        
        if (indexDif > 0) {
          double issueLeft = distanceToLeftBorderIssue + (
              GanttChartController.instance.isPanStartActive ||
              GanttChartController.instance.isPanMiddleActive ?
                issue.deltaWidth :
                0
            );
          double depIssueLeft = distanceToLeftBorderDep + (
              GanttChartController.instance.isPanStartActive ||
              GanttChartController.instance.isPanMiddleActive ?
                el.deltaWidth :
                0
            ) - 20;

          double leftPos = getAvailablePath(-(issueLeft - depIssueLeft), el, distanceToLeftBorderIssue);

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
          lineHorPos.add({'index': index, 'pos': distanceToLeftBorderIssue + leftPos});
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
  final BoxConstraints constraints;

  const ChartBarsDependencyLines({
    Key? key,
    required this.constraints,
    this.color = Colors.blue,
    this.data = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30.0),
      child: SingleChildScrollView(
        controller: GanttChartController.instance.chartDependencyLinesController,
        child: Column(
          children: List.generate(data.length, (index) {
            return ChangeNotifierProvider<Issue>.value(
              value: data[index],
              child: Consumer<Issue>(
                builder: (issuesContext, issuesValue, child) {
                  if (issuesValue.dependencies.isNotEmpty) {
                    issuesValue.widthInColumns = GanttChartController.instance.calculateWidthInColumns(issuesValue.startTime!, issuesValue.endTime!);

                    if (issuesValue.widthInColumns! > 0) {
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
                            color: lineColors[index]
                          ),
                          child: SizedBox(
                            width: GanttChartController.instance.calculateNumberOfColumnsBetween(
                              GanttChartController.instance.fromDate!,
                              GanttChartController.instance.toDate!
                            ).length * GanttChartController.instance.chartColumnsWidth,
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