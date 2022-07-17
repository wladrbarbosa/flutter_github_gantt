import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Controller/gantt_chart_controller.dart';

class ChartHeader extends StatelessWidget {
  final Color color;

  const ChartHeader({
    Key? key,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> headerItems = <Widget>[];
    DateTime tempDate = GanttChartController.instance.fromDate!;

    for (int i = 0; i < GanttChartController.instance.viewRange!.length; i++) {
      headerItems.add(SizedBox(
        width: GanttChartController.instance.chartViewWidth / GanttChartController.instance.viewRangeToFitScreen!,
        child: Text(
          DateFormat('dd/MM/yyyy').format(tempDate),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10.0,
          ),
        ),
      ));
      tempDate = tempDate.add(const Duration(days: 1));
    }

    return Container(
      height: 30.0,
      color: color.withAlpha(255),
      child: Row(
        children: headerItems,
      ),
    );
  }
}