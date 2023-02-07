import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/widgets/gantt_chart.dart';
import 'package:intl/intl.dart';
import '../controller/gantt_chart_controller.dart';

class ChartGrid extends StatelessWidget {
  const ChartGrid({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> gridColumns = <Widget>[];
    double width = GanttChartController.instance.chartViewByViewRange;

    for (int i = 0; i < GanttChartController.instance.viewRange!.length; i++) {
      gridColumns.add(Container(
        width: width,
        decoration: BoxDecoration(
          color: DateFormat('yyyy-MM-dd').format(GanttChartController.instance.viewRange![i]) == DateFormat('yyyy-MM-dd').format(DateTime.now()) ? Colors.blue.withAlpha(100) : GanttChartController.instance.viewRange![i].weekday > 5 ? Colors.grey[800] : null,
          border: Border(
            right: BorderSide(
              color: Colors.white.withAlpha(100),
              width: 1.0
            )
          )
        ),
      ));
    }

    return Listener(
      onPointerSignal: (pointerSignal){
        if(pointerSignal is PointerScrollEvent && GanttChartController.instance.isAltPressed){
          if (GanttChartController.instance.viewRangeToFitScreen! > 1 || pointerSignal.scrollDelta.dy.sign > 0) {
            GanttChart.scale(pointerSignal.scrollDelta.dx, pointerSignal.scrollDelta.dy);
          }
        }
      },
      onPointerDown: (event) async => await GanttChartController.instance.onPointerDown(event, context),
      onPointerUp: (event) async => await GanttChartController.instance.onPointerUp(event, context),
      onPointerMove: (event) async => GanttChartController.instance.onPointerDownTime = null,
      child: Row(
        children: gridColumns,
      ),
    );
  }
}