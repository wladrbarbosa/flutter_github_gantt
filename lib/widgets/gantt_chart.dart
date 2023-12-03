import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/controller/gantt_chart_controller.dart';
import 'package:flutter_github_gantt/model/issue.dart';
import 'package:flutter_github_gantt/widgets/chart_bars.dart';
import 'package:flutter_github_gantt/widgets/chart_bars_dependency_lines.dart';
import 'package:flutter_github_gantt/widgets/chart_grid.dart';
import 'package:flutter_github_gantt/widgets/chart_header.dart';
import 'package:intl/intl.dart';

class GanttChart extends StatelessWidget {
  final Color _backgroundColor;
  final List<Issue> _issuesList;
  
  const GanttChart(
    this._backgroundColor,
    this._issuesList,
    {
      super.key
    }
  );

  static void scale(double deltaX, double deltaY) {
    double percent = GanttChartController.instance.horizontalController.offset * 100 / (GanttChartController.instance.chartColumnsWidth * GanttChartController.instance.viewRange!.length);
    GanttChartController.instance.viewRangeToFitScreen = GanttChartController.instance.viewRangeToFitScreen! + deltaY;

    if (deltaY.sign < 0) {
      GanttChartController.instance.horizontalController.jumpTo(GanttChartController.instance.chartColumnsWidth * GanttChartController.instance.viewRange!.length * percent / 100 + deltaX * GanttChartController.instance.chartColumnsWidth / 2);
      GanttChartController.instance.controllers.jumpTo(GanttChartController.instance.chartBarsController.position.pixels);
    }
    else {
      GanttChartController.instance.horizontalController.jumpTo(GanttChartController.instance.chartColumnsWidth * GanttChartController.instance.viewRange!.length * percent / 100 - deltaX * GanttChartController.instance.chartColumnsWidth / 2);
      GanttChartController.instance.controllers.jumpTo(GanttChartController.instance.chartBarsController.position.pixels);
    }

    GanttChartController.instance.update();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              GanttChartController.instance.removeIssueSelection();
            },
            onScaleStart: (details) {
              GanttChartController.instance.viewRangeOnScale = GanttChartController.instance.viewRangeToFitScreen;
            },
            onScaleUpdate: (details) {
              num scaleFactor = (details.scale - 1).sign;
        
              if ((GanttChartController.instance.viewRangeToFitScreen! > 1 || scaleFactor > 0) &&
                (GanttChartController.instance.viewRangeToFitScreen! <= 55 || scaleFactor < 0)) {
                  scale(scaleFactor / 10, scaleFactor / 10);
              }
            },
            child: PageStorage(
              bucket: GanttChartController.instance.chartBucket,
              child: LayoutBuilder(
                builder: (chartContext, constraints) {
                  GanttChartController.chartPanelWidth = constraints.biggest.width;

                  return Stack(
                    children: [
                      // Não tornar ChartGrid constante, senão zoomin e out não funcioinarão corretamente
                      // ignore: prefer_const_constructors
                      ChartGrid(),
                      SingleChildScrollView(
                        controller: GanttChartController.instance.singleChildScrollController,
                        scrollDirection: Axis.horizontal,
                        physics: GanttChartController.instance.isPanStartActive || GanttChartController.instance.isPanEndActive || GanttChartController.instance.isPanMiddleActive ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
                        child: SizedBox(
                          width: GanttChartController.instance.calculateNumberOfColumnsBetween(GanttChartController.instance.fromDate!, GanttChartController.instance.toDate!).length * GanttChartController.instance.chartColumnsWidth,
                          child: Listener(
                            onPointerSignal: (pointerSignal){
                              if(pointerSignal is PointerScrollEvent && GanttChartController.instance.isAltPressed){
                                  if ((GanttChartController.instance.viewRangeToFitScreen! > 1 || pointerSignal.scrollDelta.dy.sign > 0) &&
                                    (GanttChartController.instance.viewRangeToFitScreen! <= 55 || pointerSignal.scrollDelta.dy.sign < 0)) {
                                      scale(pointerSignal.scrollDelta.dx.sign, pointerSignal.scrollDelta.dy.sign);
                                  }
                              }
                            },
                            onPointerDown: (event) async => await GanttChartController.instance.onPointerDown(event, chartContext),
                            onPointerUp: (event) async => await GanttChartController.instance.onPointerUp(event, chartContext),
                            onPointerMove: (event) async => GanttChartController.instance.onPointerDownTime = null,
                            child: Stack(
                              clipBehavior: Clip.none,
                              fit: StackFit.passthrough,
                              children: <Widget>[
                                ChartBarsDependencyLines(
                                  constraints: constraints,
                                  color: _backgroundColor,
                                  data: _issuesList,
                                ),
                                ChartBars(
                                  constraints: constraints,
                                  color: _backgroundColor,
                                  data: _issuesList,
                                ),
                              ],
                            ),
                          ),
                        )
                      ),
                      ChartHeader(
                        color: _backgroundColor,
                      ),
                    ],
                  );
                }
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Valor total do repositório: ${NumberFormat.currency(locale: 'pt_BR', decimalDigits: 2, name: 'R\$').format(_issuesList.fold(0.0, (previousValue, el) => previousValue + el.value))}'
          ),
        ),
      ],
    );
  }
}