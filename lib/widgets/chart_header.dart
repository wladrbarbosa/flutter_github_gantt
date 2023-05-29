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
    double columnsPerDay = (24 / Configs.graphColumnsPeriod.inHours);

    return SizedBox(
      height: 30.0,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              cacheExtent: 10,
              controller: GanttChartController.instance.daysScrollController,
              itemCount: GanttChartController.instance.viewRange!.length ~/ (24 / Configs.graphColumnsPeriod.inHours),
              itemExtent: GanttChartController.instance.chartViewByViewRange * (24 / Configs.graphColumnsPeriod.inHours),
              scrollDirection: Axis.horizontal,
              itemBuilder:(context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: color.withAlpha(255),
                    border: Border(
                      left: BorderSide(
                        color: Colors.white.withAlpha(400),
                        width: 0.5,
                      ),
                    )
                  ),
                  width: GanttChartController.instance.chartViewByViewRange * (24 / Configs.graphColumnsPeriod.inHours),
                  child: Text(
                    DateFormat('dd/MM/yyyy').format(GanttChartController.instance.viewRange![index * 12]),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
                );
              }
            ),
          ),
          Expanded(
            child: ListView.builder(
              cacheExtent: 10,
              controller: GanttChartController.instance.hoursScrollController,
              itemCount: GanttChartController.instance.viewRange!.length,
              itemExtent: GanttChartController.instance.chartViewByViewRange,
              scrollDirection: Axis.horizontal,
              itemBuilder:(context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: color.withAlpha(255),
                    border: Border(
                      left: index % columnsPerDay == 0 ? BorderSide(
                        color: Colors.white.withAlpha(400),
                        width: 0.5,
                      ) : BorderSide.none,
                    )
                  ),
                  width: GanttChartController.instance.chartViewByViewRange,
                  child: Text(
                    '${DateFormat('HH:mm').format(GanttChartController.instance.viewRange![index])}h',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}