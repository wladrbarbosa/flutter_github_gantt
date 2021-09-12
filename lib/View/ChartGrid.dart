import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Controller/GanttChartController.dart';

class ChartGrid extends StatelessWidget {
  const ChartGrid({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> gridColumns = <Widget>[];

    for (int i = 0; i < GanttChartController.instance.viewRange!.length; i++) {
      gridColumns.add(Container(
        width: GanttChartController.instance.chartViewWidth / GanttChartController.instance.viewRangeToFitScreen!,
        decoration: BoxDecoration(
          color: DateFormat('yyyy-MM-dd').format(GanttChartController.instance.viewRange![i]) == DateFormat('yyyy-MM-dd').format(DateTime.now()) ? Colors.blue.withAlpha(100) : GanttChartController.instance.viewRange![i].weekday > 5 ? Colors.grey[800] : null,
          border: Border(
            right: BorderSide(
              color: Colors.grey.withAlpha(100),
              width: 1.0
            )
          )
        ),
      ));
    }

    return Row(
      children: gridColumns,
    );
  }
}