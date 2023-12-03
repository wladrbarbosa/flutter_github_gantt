import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/configs.dart';
import 'package:flutter_github_gantt/controller/repos_controller.dart';
import 'package:intl/intl.dart';
import '../controller/gantt_chart_controller.dart';
import 'package:provider/provider.dart';
import '../model/issue.dart';

class ChartBars extends StatelessWidget {
  final List<Issue> data;
  final Color color;
  final BoxConstraints constraints;

  const ChartBars({
    Key? key,
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
    DateTime now = DateTime.now();
    now = now.subtract(
      Duration(
        hours: now.hour % Configs.graphColumnsPeriod.inHours,
        minutes: now.minute,
        seconds: now.second,
        milliseconds: now.millisecond,
        microseconds: now.microsecond,
      )
    );

    return Container(
      margin: const EdgeInsets.only(top: 30.0),
      child: ListView.builder(
        physics: GanttChartController.instance.isAltPressed ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
        controller: GanttChartController.instance.chartBarsController,
        itemCount: data.length,
        itemBuilder: (listContext, index) {
          TextStyle textStyle = data[index].state == 'open'
            ? data[index].startTime!.compareTo(DateFormat('yyyy/MM/dd HH:mm:ss').parse(DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now()))) < 0
              ? TextStyle(fontSize: 14, color: Colors.redAccent.shade700, fontWeight: FontWeight.w700)
              : const TextStyle(fontSize: 14, color: Colors.white)
            : TextStyle(fontSize: 14, color: Colors.lightGreenAccent.shade700, fontWeight: FontWeight.w700);

          return ChangeNotifierProvider<Issue>.value(
            value: data[index],
            child: Consumer<Issue>(
              builder: (issuesContext, _, child) {
                data[index].widthInColumns = GanttChartController.instance.calculateWidthInColumns(data[index].startTime!, data[index].endTime!);

                List<Widget> barsColumns = [];

                for (int i = 0; i < data[index].widthInColumns!; i++) {
                  int weekDayStartTime = data[index].startTime!.add(Duration(hours: i * Configs.graphColumnsPeriod.inHours)).weekday - 1;
                  int hourIndex = data[index].startTime!.add(Duration(hours: i * Configs.graphColumnsPeriod.inHours)).hour ~/ Configs.graphColumnsPeriod.inHours;    
                  bool? specificDayHourOn;

                  if (ReposController.getRepoWorkSpecificDaysHoursById(data[index].repo.nodeId!).isNotEmpty) {
                    DateTime temp = data[index].startTime!.add(Duration(hours: i * Configs.graphColumnsPeriod.inHours));
                    DateTime currentDate = DateTime(
                      temp.year,
                      temp.month,
                      temp.day
                    );
                    specificDayHourOn = ReposController.getRepoWorkSpecificDaysHoursById(data[index].repo.nodeId!)[currentDate] != null
                      && ReposController.getRepoWorkSpecificDaysHoursById(data[index].repo.nodeId!)[currentDate]!.isNotEmpty
                      && ReposController.getRepoWorkSpecificDaysHoursById(data[index].repo.nodeId!)[currentDate]!.contains(hourIndex);
                  }
                  
                  bool weekHourOn = ReposController.getRepoWorkWeekHoursById(data[index].repo.nodeId!)[weekDayStartTime]!.isNotEmpty &&
                    ReposController.getRepoWorkWeekHoursById(data[index].repo.nodeId!)[weekDayStartTime]!.contains(hourIndex);

                  if (!weekHourOn && specificDayHourOn != true || specificDayHourOn == false) {
                    List<Widget> dashedBarsColumns = [];
                    int dashNumber = 5;

                    for (int dashIndex = 0; dashIndex < dashNumber * 2; dashIndex++) {
                      dashedBarsColumns.add(Container(
                        decoration: BoxDecoration(
                          color: dashIndex.isEven
                            ? ReposController.getRepoColorById(data[index].repo.nodeId!)
                            : null,
                        ),
                        margin: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        width: (data[index].widthInColumns! > 1
                          ? i == 0 || i == data[index].widthInColumns! - 1
                            ? GanttChartController.instance.chartColumnsWidth - 18
                            : GanttChartController.instance.chartColumnsWidth
                          : GanttChartController.instance.chartColumnsWidth - 36) / (dashNumber * 2),
                      ));
                    }

                    barsColumns.add(Row(
                        children: dashedBarsColumns,
                      ) 
                    );
                  }
                  else {
                    barsColumns.add(Container(
                      decoration: BoxDecoration(
                        color: ReposController.getRepoColorById(data[index].repo.nodeId!),
                      ),
                      width: data[index].widthInColumns! > 1
                        ? i == 0 || i == data[index].widthInColumns! - 1
                          ? GanttChartController.instance.chartColumnsWidth - 18
                          : GanttChartController.instance.chartColumnsWidth
                        : GanttChartController.instance.chartColumnsWidth - 36,
                    ));
                  }
                }

                if (data[index].widthInColumns! > 0) {
                  return GestureDetector(
                    onTap: () {
                      GanttChartController.instance.issueSelect(data[index], data);
                    },
                    onLongPressEnd: (event) {
                      GanttChartController.instance.onIssueRightButton(context, null, event);
                    },
                    child: Listener(
                      onPointerDown: (event) async {
                        GanttChartController.instance.contextIssueIndex = index;
                        
                        if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton && !data[index].selected) {
                          GanttChartController.instance.issueSelect(data[index], data);
                        }
                      },
                      child: Container(
                        height: 30.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: GanttChartController.instance.isPanUpdateActive
                              ? GanttChartController.instance.isPanEndActive || GanttChartController.instance.isPanStartActive
                                ? Colors.lightBlue
                                : GanttChartController.instance.isPanMiddleActive
                                  ? Colors.red
                                  : Colors.yellow
                              : Colors.yellow,
                            width: 1,
                            style: data[index].selected ? BorderStyle.solid : BorderStyle.none,
                          )
                        ),
                        margin: EdgeInsets.only(
                          left: GanttChartController.instance.calculateColumnsToLeftBorder(data[index].startTime!) *
                              GanttChartController.instance.chartColumnsWidth + (GanttChartController.instance.isPanStartActive || GanttChartController.instance.isPanMiddleActive
                                ? GanttChartController.instance.calculateColumnsToLeftBorder(data[index].startTime!) * GanttChartController.instance.chartColumnsWidth + data[index].deltaWidth <= 0
                                  ? GanttChartController.instance.calculateColumnsToLeftBorder(data[index].startTime!) * -GanttChartController.instance.chartColumnsWidth
                                  : data[index].deltaWidth
                                : 0) + 2,
                          right: GanttChartController.instance.calculateColumnsToRightBorder(data[index].endTime!) *
                              GanttChartController.instance.chartColumnsWidth - (GanttChartController.instance.isPanEndActive || GanttChartController.instance.isPanMiddleActive
                                ? GanttChartController.instance.calculateColumnsToRightBorder(data[index].endTime!) * GanttChartController.instance.chartColumnsWidth - data[index].deltaWidth <= 0
                                  ? GanttChartController.instance.calculateColumnsToRightBorder(data[index].endTime!) * GanttChartController.instance.chartColumnsWidth
                                  : data[index].deltaWidth
                                : 0) + 2,
                          top: index == 0 ? 4.0 : 2.0,
                          bottom: index == data.length - 1 ? 4.0 : 2.0
                        ),
                        child: data[index].processing ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                          child: const Center(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: CircularProgressIndicator()
                            ),
                          )
                        ) : Stack(
                          alignment: Alignment.center,
                          children: [
                            Row(
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
                                    width: (data[index].widthInColumns! * GanttChartController.instance.chartColumnsWidth - (GanttChartController.instance.isPanStartActive ? data[index].deltaWidth : GanttChartController.instance.isPanEndActive ? -data[index].deltaWidth : 0)) / 2 - 1 < 15 ? (data[index].widthInColumns! * GanttChartController.instance.chartColumnsWidth - (GanttChartController.instance.isPanStartActive ? data[index].deltaWidth : GanttChartController.instance.isPanEndActive ? -data[index].deltaWidth : 0)) / 2 - 1 : 15,
                                    decoration: BoxDecoration(
                                      color: ReposController.getRepoColorById(data[index].repo.nodeId!),
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
                                    child: data[index].selected && GanttChartController.instance.isPanUpdateActive && (GanttChartController.instance.isPanStartActive ||
                                      GanttChartController.instance.isPanEndActive ||
                                      GanttChartController.instance.isPanMiddleActive)
                                        ? Container()
                                        : Row(
                                          children: barsColumns,
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
                                    width: (data[index].widthInColumns! * GanttChartController.instance.chartColumnsWidth - (GanttChartController.instance.isPanStartActive ? data[index].deltaWidth : GanttChartController.instance.isPanEndActive ? -data[index].deltaWidth : 0)) / 2 - 1 < 15 ? (data[index].widthInColumns! * GanttChartController.instance.chartColumnsWidth - (GanttChartController.instance.isPanStartActive ? data[index].deltaWidth : GanttChartController.instance.isPanEndActive ? -data[index].deltaWidth : 0)) / 2 - 1 : 15,
                                    decoration: BoxDecoration(
                                      color: ReposController.getRepoColorById(data[index].repo.nodeId!),
                                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(10), topRight: Radius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            IgnorePointer(
                              child: Text(
                                data[index].title!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              }
            ),
          );
        },
      ),
    );
  }
}