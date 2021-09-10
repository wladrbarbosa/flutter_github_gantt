import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/View/ChartBars.dart';
import 'package:flutter_github_gantt/View/ChartHeader.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../Model/Issue.dart';
import '../Controller/GanttChartController.dart';
import 'ChartGrid.dart';
import 'package:universal_html/html.dart';

class GanttChart extends StatelessWidget {
  final List<Issue> userData;
  final BuildContext context;
  final Color color;

  GanttChart(
    this.userData,
    this.context,
    this.color,
    {
      Key? key
    }
  ) : super(key: key);

  Future<void> _onPointerDown(PointerDownEvent event) async {
    // Check if right mouse button clicked
    if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
      RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
      showMenu<int>(
        context: context,
        items: [
          PopupMenuItem(child: Text('+3 dias no início'), value: 1),
          PopupMenuItem(child: Text('+3 dias no final'), value: 2),
          PopupMenuItem(child: Text('Nova tarefa pra hoje'), value: 3),
        ],
        position: RelativeRect.fromSize(
          event.position & Size(48.0, 48.0), overlay.size
        )
      ).then((menuItem) {
        // Check if menu item clicked
        switch (menuItem) {
          case 1:
            GanttChartController.instance.addDaysOnStart();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('+3 dias no início'),
              behavior: SnackBarBehavior.floating,
            ));
          break;
          case 2:
            GanttChartController.instance.addDaysOnEnd();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('+3 dias no final'),
                behavior: SnackBarBehavior.floating));
          break;
          case 3:
            GanttChartController.instance.launchURL("https://github.com/${GanttChartController.instance.user!.login}/${GanttChartController.instance.repo!.name}/issues/new?assignees=${GanttChartController.instance.user!.login}&body=```yaml\nstart_date: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}\ndue_date: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}\nprogress: 0.0\nparent: 0\n```");
          break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    GanttChartController.instance.nodeAttachment.reparent();
    document.onContextMenu.listen((event) => event.preventDefault());

    return ChangeNotifierProvider<GanttChartController>.value(
      value: GanttChartController.instance,
      child: Consumer<GanttChartController>(
        builder: (ganttChartContext, ganttChartValue, child) {
          userData.sort((a, b) {
            int startOrder = a.startTime!.compareTo(b.startTime!);

            if (startOrder == 0) {
              startOrder = a.endTime!.compareTo(b.endTime!);

              if (startOrder == 0) {
                startOrder = a.state.compareTo(b.state);

                if (startOrder == 0)
                  return a.number!.compareTo(b.number!);
                else
                  return startOrder;
              }
              else
                return startOrder;    
            }
            else
              return startOrder;
          });

          return Container(
            width: MediaQuery.of(ganttChartContext).size.width,
            child: Row(
              children: [
                Container(
                  width: ganttChartValue.issuesListWidth,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              height: 30.0,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              color: color.withAlpha(255),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Id'
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
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
                                itemCount: userData.length,
                                itemBuilder: (context, index) {
                                  return ChangeNotifierProvider<Issue>.value(
                                    value: userData[index],
                                    child: Consumer<Issue>(
                                      builder: (issuesContext, issuesValue, child) {
                                        return GestureDetector(
                                          onTap: () {
                                            ganttChartValue.issueSelect(issuesValue, issueList: userData);
                                          },
                                          child: Listener(
                                            onPointerDown: (event) async {
                                              await ganttChartValue.onIssueRightButton(issuesContext, event, issuesValue);
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                top: index == 0 ? 4.0 : 2.0,
                                                bottom: index == userData.length - 1 ? 4.0 : 2.0
                                              ),
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: issuesValue.state == 'open' ? Colors.red.withAlpha(100) : Colors.green.withAlpha(100),
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
                                              padding: EdgeInsets.symmetric(horizontal: 10),
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
                                                    flex: 3,
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
                                                        issuesValue.assignees!.fold<String>('', (previousValue, el) => previousValue == '' ? el : '$previousValue, $el'),
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

                          if (ganttChartValue.issuesListWidth > MediaQuery.of(ganttChartContext).size.width)
                            ganttChartValue.issuesListWidth = MediaQuery.of(ganttChartContext).size.width;

                          if (ganttChartValue.issuesListWidth < 20)
                            ganttChartValue.issuesListWidth = 20;
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
                                  padding: EdgeInsets.all(0),
                                  icon: Center(
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
                                  padding: EdgeInsets.all(0),
                                  icon: Icon(
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
                  flex: 9,
                  child: GestureDetector(
                    onTap: () {
                      for (int i = 0; i < ganttChartValue.selectedIssues.length; i++) {
                        ganttChartValue.selectedIssues[i]!.toggleSelect();
                        ganttChartValue.selectedIssues.removeAt(i);
                        i--;
                      }
                    },
                    child: LayoutBuilder(
                      builder: (chartContext, constraints) {
                        return SingleChildScrollView(
                          controller: ganttChartValue.horizontalController,
                          scrollDirection: Axis.horizontal,
                          physics: ganttChartValue.isPanStartActive || ganttChartValue.isPanEndActive || ganttChartValue.isPanMiddleActive ? NeverScrollableScrollPhysics() : ClampingScrollPhysics(),
                          child: Stack(
                            children: [
                              SingleChildScrollView(
                                controller: ganttChartValue.chartController,
                                physics: ganttChartValue.isAltPressed ? NeverScrollableScrollPhysics() : ClampingScrollPhysics(),
                                child: Container(
                                  width: ganttChartValue.calculateNumberOfDaysBetween(ganttChartValue.fromDate!, ganttChartValue.toDate!).length * ganttChartValue.chartViewWidth / ganttChartValue.viewRangeToFitScreen!,
                                  height: (userData.length * 34) + 34 + (MediaQuery.of(context).size.height - (userData.length * 34) + 34).clamp(0, double.infinity),
                                  child: Stack(
                                      fit: StackFit.loose,
                                      children: <Widget>[
                                      Listener(
                                        onPointerSignal: (pointerSignal){
                                          if(pointerSignal is PointerScrollEvent && ganttChartValue.isAltPressed){
                                            if (ganttChartValue.viewRangeToFitScreen! > 1 || pointerSignal.scrollDelta.dy.sign > 0) {
                                              double percent = ganttChartValue.horizontalController.position.pixels * 100 / (ganttChartValue.chartViewWidth / ganttChartValue.viewRangeToFitScreen! * ganttChartValue.viewRange!.length);
                                              ganttChartValue.viewRangeToFitScreen = ganttChartValue.viewRangeToFitScreen! + pointerSignal.scrollDelta.dy.sign.toInt();

                                              if (pointerSignal.scrollDelta.dy.sign < 0) {
                                                ganttChartValue.horizontalController.jumpTo(ganttChartValue.chartViewWidth / ganttChartValue.viewRangeToFitScreen! * ganttChartValue.viewRange!.length * percent / 100 + pointerSignal.position.dx.sign * ganttChartValue.chartViewWidth / ganttChartValue.viewRangeToFitScreen! / 2);
                                                ganttChartValue.chartController.jumpTo(ganttChartValue.chartController.position.pixels);
                                              }
                                              else {
                                                ganttChartValue.horizontalController.jumpTo(ganttChartValue.chartViewWidth / ganttChartValue.viewRangeToFitScreen! * ganttChartValue.viewRange!.length * percent / 100 - pointerSignal.position.dx.sign * ganttChartValue.chartViewWidth / ganttChartValue.viewRangeToFitScreen! / 2);
                                                ganttChartValue.chartController.jumpTo(ganttChartValue.chartController.position.pixels);
                                              }

                                              ganttChartValue.update();
                                            }
                                          }
                                        },
                                        onPointerDown: (event) async => await _onPointerDown(event),
                                        child: ChartGrid()
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 30.0),
                                        child: ChartBars(data: userData, color: color, chartAreaWidth: constraints.biggest.width),
                                      ),
                                    ]
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