import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/controller/gantt_chart_controller.dart';
import 'package:flutter_github_gantt/model/issue.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class IssuesList extends StatelessWidget {
  final GanttChartController _ganttChartController;
  final Color backgroundColor;
  final List<Issue> _issuesList;
  final List<Issue> _filteredIssuesList;
  
  const IssuesList(
    this._ganttChartController,
    this.backgroundColor,
    this._issuesList,
    this._filteredIssuesList,
    {
      super.key
    }
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _ganttChartController.issuesListWidth,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 30.0,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  color: backgroundColor.withAlpha(255),
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
                    controller: _ganttChartController.listController,
                    scrollDirection: Axis.vertical,
                    itemCount: _filteredIssuesList.length,
                    itemBuilder: (context, index) {
                      return ChangeNotifierProvider<Issue>.value(
                        value: _filteredIssuesList[index],
                        child: Consumer<Issue>(
                          builder: (issuesContext, issuesValue, child) {
                            return GestureDetector(
                              onTap: () {
                                _ganttChartController.issueSelect(issuesValue, _issuesList);
                              },
                              onLongPressEnd: (event) {
                                GanttChartController.instance.onIssueRightButton(context, null, event);
                              },
                              child: Listener(
                                onPointerDown: (event) async {
                                  await _ganttChartController.onIssueRightButton(issuesContext, event);
                                },
                                onPointerUp: (event) async {
                                  await _ganttChartController.onIssueRightButton(issuesContext, event);
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                    top: index == 0 ? 4.0 : 2.0,
                                    bottom: index == _issuesList.length - 1 ? 4.0 : 2.0
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
              _ganttChartController.issuesListWidth += details.globalPosition.dx - _ganttChartController.issuesListWidth;

              if (_ganttChartController.issuesListWidth > MediaQuery.of(context).size.width) {
                _ganttChartController.issuesListWidth = MediaQuery.of(context).size.width;
              }

              if (_ganttChartController.issuesListWidth < 20) {
                _ganttChartController.issuesListWidth = 20;
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
                        _ganttChartController.issuesListWidth = 20;
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
                        _ganttChartController.issuesListWidth = MediaQuery.of(context).size.width;
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
    );
  }
}