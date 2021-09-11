import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Controller/GanttChartController.dart';
import 'package:provider/provider.dart';
import '../Model/Issue.dart';

class ChartBars extends StatelessWidget {
  final List<Issue> data;
  final Color color;
  final double chartAreaWidth;

  ChartBars({
    Key? key,
    this.color = Colors.blue,
    this.data = const [],
    this.chartAreaWidth = 0,
  }) : super(key: key);

  _handleDrag(details) {
    GanttChartController.instance.initX = details.globalPosition.dx;
    GanttChartController.instance.initY = details.globalPosition.dy;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> chartBars = <Widget>[];

    for(int i = 0; i < data.length; i++) {
      chartBars.add(ChangeNotifierProvider<Issue>.value(
        value: data[i],
        child: Consumer<Issue>(
          builder: (issuesContext, issuesValue, child) {
            issuesValue.remainingWidth = GanttChartController.instance.calculateRemainingWidth(issuesValue.startTime!, issuesValue.endTime!);
            
            if (issuesValue.remainingWidth! > 0)
              return GestureDetector(
                onTap: () {
                  GanttChartController.instance.issueSelect(issuesValue);
                },
                child: Listener(
                  onPointerDown: (event) async {
                    await GanttChartController.instance.onIssueRightButton(issuesContext, event, issuesValue);
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
                      top: i == 0 ? 4.0 : 2.0,
                      bottom: i == data.length - 1 ? 4.0 : 2.0
                    ),
                    child: issuesValue.processing ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
                      child: Center(
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
                            GanttChartController.instance.onIssueStartUpdate(issuesContext, details, chartAreaWidth);
                          },
                          onPanDown: (details) {
                            GanttChartController.instance.onIssueStartPan(PanType.Start, details.globalPosition.dx);
                          },
                          onPanCancel: () {
                            GanttChartController.instance.onIssuePanCancel(PanType.Start);
                          },
                          onPanEnd: (details) async {
                            GanttChartController.instance.onIssueEndPan(PanType.Start);
                          },
                          child: Container(
                            width: 15,
                            decoration: BoxDecoration(
                              color: issuesValue.state == 'open' ? issuesValue.startTime!.compareTo(DateFormat('yyyy/MM/dd').parse(DateFormat('yyyy/MM/dd').format(DateTime.now()))) < 0 ? Colors.purple : Colors.red : Colors.green,
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), topLeft: Radius.circular(10)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onPanStart: _handleDrag,
                            onPanUpdate: (details) {
                              GanttChartController.instance.onIssueDateUpdate(issuesContext, details, chartAreaWidth);
                            },
                            onPanDown: (details) {
                              GanttChartController.instance.onIssueStartPan(PanType.Middle, details.globalPosition.dx);
                            },
                            onPanCancel: () {
                              GanttChartController.instance.onIssuePanCancel(PanType.Middle);
                            },
                            onPanEnd: (details) async {
                              GanttChartController.instance.onIssueEndPan(PanType.Middle);
                            },
                            child: Container(
                              height: 30.0,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(
                                issuesValue.title!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 10.0),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onPanStart: _handleDrag,
                          onPanUpdate: (details) {
                            GanttChartController.instance.onIssueEndUpdate(issuesContext, details, chartAreaWidth);
                          },
                          onPanDown: (details) {
                            GanttChartController.instance.onIssueStartPan(PanType.End, details.globalPosition.dx);
                          },
                          onPanCancel: () {
                            GanttChartController.instance.onIssuePanCancel(PanType.End);
                          },
                          onPanEnd: (details) async {
                            GanttChartController.instance.onIssueEndPan(PanType.End);
                          },
                          child: Container(
                            width: 15,
                            decoration: BoxDecoration(
                              color: issuesValue.state == 'open' ? issuesValue.endTime!.compareTo(DateFormat('yyyy/MM/dd').parse(DateFormat('yyyy/MM/dd').format(DateTime.now()))) < 0 ? Colors.purple : Colors.red : Colors.green,
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), topRight: Radius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            else
              return Container();
          }
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: chartBars
    );
  }
}