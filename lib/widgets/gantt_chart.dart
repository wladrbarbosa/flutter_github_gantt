import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/controller/gantt_chart_controller.dart';
import 'package:flutter_github_gantt/model/issue.dart';
import 'package:flutter_github_gantt/widgets/chart_bars.dart';
import 'package:flutter_github_gantt/widgets/chart_bars_dependency_lines.dart';
import 'package:flutter_github_gantt/widgets/chart_grid.dart';
import 'package:flutter_github_gantt/widgets/chart_header.dart';

class GanttChart extends StatelessWidget {
  final GanttChartController _ganttChartController;
  final Color _backgroundColor;
  final List<Issue> _issuesList;
  
  const GanttChart(
    this._ganttChartController,
    this._backgroundColor,
    this._issuesList,
    {
      super.key
    }
  );

  static void scale(double deltaX, double deltaY) {
    double percent = GanttChartController.instance.horizontalController.position.pixels * 100 / (GanttChartController.instance.chartViewByViewRange * GanttChartController.instance.viewRange!.length);
    GanttChartController.instance.viewRangeToFitScreen = GanttChartController.instance.viewRangeToFitScreen! + deltaY.sign;

    if (deltaY.sign < 0) {
      GanttChartController.instance.horizontalController.jumpTo(GanttChartController.instance.chartViewByViewRange * GanttChartController.instance.viewRange!.length * percent / 100 + deltaX.sign * GanttChartController.instance.chartViewByViewRange / 2);
      GanttChartController.instance.controllers.jumpTo(GanttChartController.instance.chartBarsController.position.pixels);
    }
    else {
      GanttChartController.instance.horizontalController.jumpTo(GanttChartController.instance.chartViewByViewRange * GanttChartController.instance.viewRange!.length * percent / 100 - deltaX.sign * GanttChartController.instance.chartViewByViewRange / 2);
      GanttChartController.instance.controllers.jumpTo(GanttChartController.instance.chartBarsController.position.pixels);
    }

    GanttChartController.instance.update();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _ganttChartController.removeIssueSelection();
        },
        onScaleStart: (details) {
          GanttChartController.instance.viewRangeOnScale = GanttChartController.instance.viewRangeToFitScreen;
        },
        onScaleUpdate: (details) {
          if (GanttChartController.instance.viewRangeToFitScreen! > 1 || details.scale < 1) {
            scale(details.scale, details.scale);
          }
        },
        child: LayoutBuilder(
          builder: (chartContext, constraints) {
            return SingleChildScrollView(
              controller: _ganttChartController.horizontalController,
              scrollDirection: Axis.horizontal,
              physics: _ganttChartController.isPanStartActive || _ganttChartController.isPanEndActive || _ganttChartController.isPanMiddleActive ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
              child: Stack(
                children: [
                  SizedBox(
                    width: _ganttChartController.calculateNumberOfDaysBetween(_ganttChartController.fromDate!, _ganttChartController.toDate!).length * _ganttChartController.chartViewByViewRange,
                    child: Listener(
                      onPointerSignal: (pointerSignal){
                        if(pointerSignal is PointerScrollEvent && _ganttChartController.isAltPressed){
                          if (_ganttChartController.viewRangeToFitScreen! > 1 || pointerSignal.scrollDelta.dy.sign > 0) {
                            scale(pointerSignal.scrollDelta.dx, pointerSignal.scrollDelta.dy);
                          }
                        }
                      },
                      onPointerDown: (event) async => await _ganttChartController.onPointerDown(event, chartContext),
                      onPointerUp: (event) async => await _ganttChartController.onPointerUp(event, chartContext),
                      onPointerMove: (event) async => _ganttChartController.onPointerDownTime = null,
                      child: Stack(
                        clipBehavior: Clip.none,
                        fit: StackFit.passthrough,
                        children: <Widget>[
                          // Não tornar ChartGrid constante, senão zoomin e out não funcioinarão corretamente
                          // ignore: prefer_const_constructors
                          ChartGrid(),
                          ChartBarsDependencyLines(
                            gantChartController: _ganttChartController,
                            constraints: constraints,
                            color: _backgroundColor,
                            data: _issuesList,
                          ),
                          ChartBars(
                            gantChartController: _ganttChartController,
                            constraints: constraints,
                            color: _backgroundColor,
                            data: _issuesList,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ChartHeader(color: _backgroundColor),
                ],
              )
            );
          }
        ),
      ),
    );
  }
}