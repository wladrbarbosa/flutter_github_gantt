import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/configs.dart';
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
    double columnsPerDay = (24 * 60 / Configs.graphColumnsPeriod.inMinutes);
    List<Widget> headerDays = <Widget>[];
    List<Widget> headerHours = <Widget>[];

    for (int i = 0; i < GanttChartController.instance.viewRange!.length; i++) {
      if (i % columnsPerDay == 0) {
        headerDays.add(Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Colors.white.withAlpha(400),
                width: 0.5,
              ),
            )
          ),
          width: GanttChartController.instance.chartViewByViewRange * (24 * 60 / Configs.graphColumnsPeriod.inMinutes),
          child: Text(
            DateFormat('dd/MM/yyyy').format(GanttChartController.instance.viewRange![i]),
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
            left: i % columnsPerDay == 0 ? BorderSide(
              color: Colors.white.withAlpha(400),
              width: 0.5,
            ) : BorderSide.none,
          )
        ),
        width: GanttChartController.instance.chartViewByViewRange,
        child: Text(
          '${DateFormat('HH:mm').format(GanttChartController.instance.viewRange![i])}h',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10.0,
          ),
        ),
      ));
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