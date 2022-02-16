import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Controller/GanttChartController.dart';
import 'package:provider/provider.dart';
import '../Model/Issue.dart';

class ChartBars extends StatelessWidget {
  final List<Issue> data;
  final Color color;
  final GanttChartController gantChartController;
  final BoxConstraints constraints;

  ChartBars({
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
      margin: EdgeInsets.only(top: 30.0),
      child: ListView.builder(
        physics: gantChartController.isAltPressed ? NeverScrollableScrollPhysics() : ClampingScrollPhysics(),
        controller: gantChartController.chartController,
        itemCount: data.length,
        itemBuilder: (listContext, index) {
          return ChangeNotifierProvider<Issue>.value(
            value: data[index],
            child: Consumer<Issue>(
              builder: (issuesContext, issuesValue, child) {
                issuesValue.remainingWidth = GanttChartController.instance.calculateRemainingWidth(issuesValue.startTime!, issuesValue.endTime!);

                if (issuesValue.remainingWidth! > 0)
                  return GestureDetector(
                    onTap: () {
                      GanttChartController.instance.issueSelect(issuesValue, data);
                    },
                    child: Listener(
                      onPointerDown: (event) async {
                        GanttChartController.instance.contextIssueIndex = index;
                        
                        if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton && !issuesValue.selected)
                          GanttChartController.instance.issueSelect(issuesValue, GanttChartController.instance.issueList!);
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
                                GanttChartController.instance.onIssueStartUpdate(issuesContext, details, constraints.biggest.width);
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
                                  GanttChartController.instance.onIssueDateUpdate(issuesContext, details, constraints.biggest.width);
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
                                GanttChartController.instance.onIssueEndUpdate(issuesContext, details, constraints.biggest.width);
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
          );
        },
      ),
    );
  }
}