import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/configs.dart';
import 'package:intl/intl.dart';
import '../controller/gantt_chart_controller.dart';

class ChartGrid extends StatelessWidget {
  const ChartGrid({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = GanttChartController.instance.chartColumnsWidth;
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

    if (!GanttChartController.instance.isTodayJumped) {
      GanttChartController.instance.isTodayJumped = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GanttChartController.instance.horizontalController.jumpTo(GanttChartController.instance.calculateColumnsToLeftBorder(DateTime.now().subtract(const Duration(hours: 8))) * GanttChartController.instance.chartColumnsWidth);
      });
    }

    return ListView.builder(
      key: const PageStorageKey('chart'),
      cacheExtent: 10,
      controller: GanttChartController.instance.columnsScrollController,
      scrollDirection: Axis.horizontal,
      itemCount: GanttChartController.instance.viewRange!.length,
      itemExtent: width,
      itemBuilder:(context, index) {
        return Container(
          width: width,
          decoration: BoxDecoration(
            color: DateFormat('yyyy-MM-dd HH:mm:ss').format(GanttChartController.instance.viewRange![index]) == DateFormat('yyyy-MM-dd HH:mm:ss').format(now) ?
              Colors.yellowAccent.withAlpha(100) :
              GanttChartController.instance.viewRange![index].weekday > 5 ?
                Colors.lightBlue.withAlpha(50) :
                null,
            border: Border(
              right: BorderSide(
                color: Colors.white.withAlpha(50),
                width: 1.0
              )
            )
          ),
        );
      },
    );
  }
}