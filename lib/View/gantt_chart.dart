//Only on web
//import 'dart:html';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/view/chart_bars.dart';
import 'package:flutter_github_gantt/view/chart_bars_dependency_lines.dart';
import 'package:flutter_github_gantt/view/chart_grid.dart';
import 'package:flutter_github_gantt/view/chart_header.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/issue.dart';
import '../controller/gantt_chart_controller.dart';

class GanttChart extends StatelessWidget {
  final List<Issue> userData;
  final BuildContext context;
  final Color color;

  const GanttChart(
    this.userData,
    this.context,
    this.color,
    {
      Key? key
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Issue> filteredUserData = [];
    GanttChartController.instance.nodeAttachment.reparent();
    lineColors.clear();

    for (int i = 0; i < userData.length; i++) {
      lineColors.add(Color.fromARGB(255, Random().nextInt(256), Random().nextInt(256), Random().nextInt(256)));
    }
    //Only on web
    //document.onContextMenu.listen((event) => event.preventDefault());

    return ChangeNotifierProvider<GanttChartController>.value(
      value: GanttChartController.instance,
      child: Consumer<GanttChartController>(
        builder: (ganttChartContext, ganttChartValue, child) {
          userData.sort((a, b) {
            int startOrder = a.startTime!.compareTo(b.startTime!);

            if (startOrder == 0) {
              startOrder = a.endTime!.compareTo(b.endTime!);

              if (startOrder == 0) {
                startOrder = a.state!.compareTo(b.state!);

                if (startOrder == 0) {
                  return a.number!.compareTo(b.number!);
                } else {
                  return startOrder;
                }
              }
              else {
                return startOrder;
              }    
            }
            else {
              return startOrder;
            }
          });

          filteredUserData = userData.where((el) => el.title!.contains(GanttChartController.instance.filterController.text)).toList();

          return SizedBox(
            width: MediaQuery.of(ganttChartContext).size.width,
            child: Row(
              children: [
                SizedBox(
                  width: ganttChartValue.issuesListWidth,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              height: 30.0,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              color: color.withAlpha(255),
                              child: Row(
                                children: const [
                                  Expanded(
                                    child: Text(
                                      'Id'
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'Título'
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Responsável'
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                controller: ganttChartValue.listController,
                                scrollDirection: Axis.vertical,
                                itemCount: filteredUserData.length,
                                itemBuilder: (context, index) {
                                  return ChangeNotifierProvider<Issue>.value(
                                    value: filteredUserData[index],
                                    child: Consumer<Issue>(
                                      builder: (issuesContext, issuesValue, child) {
                                        return GestureDetector(
                                          onTap: () {
                                            ganttChartValue.issueSelect(issuesValue, userData);
                                          },
                                          onLongPressEnd: (event) {
                                            GanttChartController.instance.onIssueRightButton(context, null, event);
                                          },
                                          child: Listener(
                                            onPointerDown: (event) async {
                                              await ganttChartValue.onIssueRightButton(issuesContext, event);
                                            },
                                            onPointerUp: (event) async {
                                              await ganttChartValue.onIssueRightButton(issuesContext, event);
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                top: index == 0 ? 4.0 : 2.0,
                                                bottom: index == userData.length - 1 ? 4.0 : 2.0
                                              ),
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: issuesValue.state == 'open' ? issuesValue.startTime!.compareTo(DateFormat('yyyy/MM/dd').parse(DateFormat('yyyy/MM/dd').format(DateTime.now()))) < 0 && issuesValue.endTime!.compareTo(DateFormat('yyyy/MM/dd').parse(DateFormat('yyyy/MM/dd').format(DateTime.now()))) < 0 ? Colors.purple.withAlpha(100) : Colors.red.withAlpha(100) : Colors.green.withAlpha(100),
                                                border: issuesValue.selected ? Border.all(
                                                  color: Colors.yellow,
                                                  width: 1,
                                                ) : Border.symmetric(
                                                  horizontal: BorderSide(
                                                    color: Colors.grey.withAlpha(100),
                                                    width: 1.0
                                                  )
                                                )
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text(
                                                        '#${issuesValue.number!}',
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text(
                                                        issuesValue.title!,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      alignment: Alignment.centerRight,
                                                      child: Text(
                                                        issuesValue.assignees!.fold<String>('', (previousValue, el) => previousValue == '' ? el.login! : '$previousValue, ${el.login}'),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onPanUpdate: (details) {
                          ganttChartValue.issuesListWidth += details.globalPosition.dx - ganttChartValue.issuesListWidth;

                          if (ganttChartValue.issuesListWidth > MediaQuery.of(ganttChartContext).size.width) {
                            ganttChartValue.issuesListWidth = MediaQuery.of(ganttChartContext).size.width;
                          }

                          if (ganttChartValue.issuesListWidth < 20) {
                            ganttChartValue.issuesListWidth = 20;
                          }
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: 20,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  )
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    ganttChartValue.issuesListWidth = 20;
                                  },
                                  padding: const EdgeInsets.all(0),
                                  icon: const Center(
                                    child: Icon(
                                      Icons.keyboard_arrow_left_rounded,
                                      size: 15,
                                    ),
                                  ),
                                  iconSize: 15,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: 20,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  )
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    ganttChartValue.issuesListWidth = MediaQuery.of(ganttChartContext).size.width;
                                  },
                                  padding: const EdgeInsets.all(0),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_right_rounded,
                                    size: 15,
                                  ),
                                  iconSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ganttChartValue.removeIssueSelection();
                    },
                    onScaleStart: (details) {
                      GanttChartController.instance.viewRangeOnScale = GanttChartController.instance.viewRangeToFitScreen;
                    },
                    onScaleUpdate: (details) {
                      if (GanttChartController.instance.viewRangeToFitScreen! > 1 || details.scale < 1) {
                        double percent = GanttChartController.instance.horizontalController.position.pixels * 100 / (GanttChartController.instance.chartViewWidth / GanttChartController.instance.viewRangeToFitScreen! * GanttChartController.instance.viewRange!.length);
                        GanttChartController.instance.viewRangeToFitScreen = (GanttChartController.instance.viewRangeOnScale! ~/ details.scale).toInt();

                        if (details.scale > 1) {
                          GanttChartController.instance.horizontalController.jumpTo(GanttChartController.instance.chartViewWidth / GanttChartController.instance.viewRangeToFitScreen! * GanttChartController.instance.viewRange!.length * percent / 100);
                          GanttChartController.instance.controllers.jumpTo(GanttChartController.instance.chartBarsController.position.pixels);
                        }
                        else {
                          GanttChartController.instance.horizontalController.jumpTo(GanttChartController.instance.chartViewWidth / GanttChartController.instance.viewRangeToFitScreen! * GanttChartController.instance.viewRange!.length * percent / 100);
                          GanttChartController.instance.controllers.jumpTo(GanttChartController.instance.chartBarsController.position.pixels);
                        }

                        GanttChartController.instance.update();
                      }
                    },
                    child: LayoutBuilder(
                      builder: (chartContext, constraints) {
                        return SingleChildScrollView(
                          controller: ganttChartValue.horizontalController,
                          scrollDirection: Axis.horizontal,
                          physics: ganttChartValue.isPanStartActive || ganttChartValue.isPanEndActive || ganttChartValue.isPanMiddleActive ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
                          child: Stack(
                            children: [
                              SizedBox(
                                width: ganttChartValue.calculateNumberOfDaysBetween(ganttChartValue.fromDate!, ganttChartValue.toDate!).length * ganttChartValue.chartViewWidth / ganttChartValue.viewRangeToFitScreen!,
                                child: Listener(
                                  onPointerSignal: (pointerSignal){
                                    if(pointerSignal is PointerScrollEvent && ganttChartValue.isAltPressed){
                                      if (ganttChartValue.viewRangeToFitScreen! > 1 || pointerSignal.scrollDelta.dy.sign > 0) {
                                        double percent = ganttChartValue.horizontalController.position.pixels * 100 / (ganttChartValue.chartViewWidth / ganttChartValue.viewRangeToFitScreen! * ganttChartValue.viewRange!.length);
                                        ganttChartValue.viewRangeToFitScreen = ganttChartValue.viewRangeToFitScreen! + pointerSignal.scrollDelta.dy.sign.toInt();

                                        if (pointerSignal.scrollDelta.dy.sign < 0) {
                                          ganttChartValue.horizontalController.jumpTo(ganttChartValue.chartViewWidth / ganttChartValue.viewRangeToFitScreen! * ganttChartValue.viewRange!.length * percent / 100 + pointerSignal.position.dx.sign * ganttChartValue.chartViewWidth / ganttChartValue.viewRangeToFitScreen! / 2);
                                          ganttChartValue.controllers.jumpTo(ganttChartValue.chartBarsController.position.pixels);
                                        }
                                        else {
                                          ganttChartValue.horizontalController.jumpTo(ganttChartValue.chartViewWidth / ganttChartValue.viewRangeToFitScreen! * ganttChartValue.viewRange!.length * percent / 100 - pointerSignal.position.dx.sign * ganttChartValue.chartViewWidth / ganttChartValue.viewRangeToFitScreen! / 2);
                                          ganttChartValue.controllers.jumpTo(ganttChartValue.chartBarsController.position.pixels);
                                        }

                                        ganttChartValue.update();
                                      }
                                    }
                                  },
                                  onPointerDown: (event) async => await ganttChartValue.onPointerDown(event, chartContext),
                                  onPointerUp: (event) async => await ganttChartValue.onPointerUp(event, chartContext),
                                  onPointerMove: (event) async => ganttChartValue.onPointerDownTime = null,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    fit: StackFit.passthrough,
                                    children: <Widget>[
                                      // Não tornar ChartGrid constante, senão zoomin e out não funcioinarão corretamente
                                      ChartGrid(),
                                      ChartBarsDependencyLines(
                                        gantChartController: ganttChartValue,
                                        constraints: constraints,
                                        color: color,
                                        data: filteredUserData,
                                      ),
                                      ChartBars(
                                        gantChartController: ganttChartValue,
                                        constraints: constraints,
                                        color: color,
                                        data: filteredUserData,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ChartHeader(color: color),
                            ],
                          )
                        );
                      }
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}