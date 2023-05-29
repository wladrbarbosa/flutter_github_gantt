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
    double width = GanttChartController.instance.chartViewByViewRange;
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

    return ListView.builder(
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
              Colors.blue.withAlpha(100) :
              GanttChartController.instance.viewRange![index].weekday > 5 ?
                Colors.grey[800] :
                null,
            border: Border(
              right: BorderSide(
                color: Colors.white.withAlpha(100),
                width: 1.0
              )
            )
          ),
        );
      },
    );
  }
}