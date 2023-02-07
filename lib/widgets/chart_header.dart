import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controller/gantt_chart_controller.dart';

class ChartHeader extends StatelessWidget {
  final Color color;

  const ChartHeader({
    Key? key,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> headerDays = <Widget>[];
    List<Widget> headerHours = <Widget>[];
    DateTime tempDate = GanttChartController.instance.fromDate!;

    for (int i = 0; i < GanttChartController.instance.viewRange!.length; i++) {
      if (i % 8 == 0) {
        headerDays.add(Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Colors.white.withAlpha(400),
                width: 0.5,
              ),
            )
          ),
          width: GanttChartController.instance.chartViewByViewRange * 8,
          child: Text(
            DateFormat('dd/MM/yyyy').format(tempDate),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.0,
            ),
          ),
        ));
      }

      headerHours.add(Container(
        decoration: BoxDecoration(
          border: Border(
            left: i % 8 == 0 ? BorderSide(
              color: Colors.white.withAlpha(400),
              width: 0.5,
            ) : BorderSide.none,
          )
        ),
        width: GanttChartController.instance.chartViewByViewRange,
        child: Text(
          '${DateFormat('HH').format(tempDate)}h',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10.0,
          ),
        ),
      ));
      tempDate = tempDate.add(const Duration(hours: 3));
    }

    return Container(
      height: 30.0,
      color: color.withAlpha(255),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: headerDays,
          ),
          Row(
            children: headerHours,
          ),
        ],
      ),
    );
  }
}