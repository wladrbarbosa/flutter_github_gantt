//Only on web
//import 'dart:html';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/widgets/chart_bars_dependency_lines.dart';
import 'package:flutter_github_gantt/widgets/gantt_chart.dart';
import 'package:flutter_github_gantt/widgets/issues_list.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:provider/provider.dart';
import '../model/issue.dart';
import '../controller/gantt_chart_controller.dart';

class ChartPage extends StatelessWidget {
  final List<Issue> userData;
  final BuildContext context;
  final Color color;

  const ChartPage(
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

          MultiSplitView multiSplitView = MultiSplitView(
            children: [
              IssuesList(
                color,
                userData,
                filteredUserData,
              ),
              GanttChart(
                color,
                filteredUserData,
              ),
            ],
          );

          MultiSplitViewTheme theme = MultiSplitViewTheme(
            data: MultiSplitViewThemeData(
              dividerPainter: DividerPainters.dashed(
                color: Colors.white,
                highlightedColor: Colors.blueAccent,
              ),
            ),
            child: multiSplitView,
          );
          
          return SizedBox(
            width: MediaQuery.of(ganttChartContext).size.width,
            child: theme,
          );
        }
      ),
    );
  }
}