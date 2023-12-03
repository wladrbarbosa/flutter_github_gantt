import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/configs.dart';
import 'package:flutter_github_gantt/controller/gantt_chart_controller.dart';
import 'package:flutter_github_gantt/controller/repos_controller.dart';
import 'package:flutter_github_gantt/model/issue.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class IssuesList extends StatelessWidget {
  final Color backgroundColor;
  final List<Issue> _issuesList;
  final List<Issue> _filteredIssuesList;
  
  const IssuesList(
    this.backgroundColor,
    this._issuesList,
    this._filteredIssuesList,
    {
      super.key
    }
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                height: 30.0,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                color: backgroundColor.withAlpha(255),
                child: const Row(
                  children: [
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
                      flex: 2,
                      child: Text(
                        'Responsável'
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Duração total'
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Duração efetiva'
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Valor'
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageStorage(
                  bucket: GanttChartController.instance.listBucket,
                  child: ListView.builder(
                    key: GanttChartController.instance.listStorageKey,
                    controller: GanttChartController.instance.listController,
                    scrollDirection: Axis.vertical,
                    itemCount: _filteredIssuesList.length,
                    itemBuilder: (context, index) {
                      return ChangeNotifierProvider<Issue>.value(
                        value: _filteredIssuesList[index],
                        child: Consumer<Issue>(
                          builder: (issuesContext, issuesValue, child) {
                            TextStyle textStyle = issuesValue.state == 'open'
                              ? issuesValue.startTime!.compareTo(DateFormat('yyyy/MM/dd HH:mm:ss').parse(DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now()))) < 0
                                ? TextStyle(fontSize: 14, color: Colors.redAccent.shade700, fontWeight: FontWeight.w700)
                                : const TextStyle(fontSize: 14, color: Colors.white)
                              : TextStyle(fontSize: 14, color: Colors.lightGreenAccent.shade700, fontWeight: FontWeight.w700);

                            return GestureDetector(
                              onTap: () {
                                GanttChartController.instance.issueSelect(issuesValue, _issuesList);
                              },
                              onLongPressEnd: (event) {
                                GanttChartController.instance.onIssueRightButton(context, null, event);
                              },
                              child: Listener(
                                onPointerDown: (event) async {
                                  await GanttChartController.instance.onIssueRightButton(issuesContext, event);
                                },
                                onPointerUp: (event) async {
                                  await GanttChartController.instance.onIssueRightButton(issuesContext, event);
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                    top: index == 0 ? 4.0 : 2.0,
                                    bottom: index == _issuesList.length - 1 ? 4.0 : 2.0
                                  ),
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: ReposController.getRepoColorById(issuesValue.repo.nodeId!),
                                    border: issuesValue.selected ? Border.all(
                                      color: GanttChartController.instance.isPanUpdateActive
                                        ? GanttChartController.instance.isPanEndActive || GanttChartController.instance.isPanStartActive
                                          ? Colors.lightBlue
                                          : GanttChartController.instance.isPanMiddleActive
                                            ? Colors.red
                                            : Colors.yellow
                                        : Colors.yellow,
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
                                            style: textStyle,
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
                                            style: textStyle,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            issuesValue.assignees!.fold<String>('', (previousValue, el) => previousValue == '' ? el.login! : '$previousValue, ${el.login}'),
                                            style: textStyle,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '${(issuesValue.widthInColumns ?? 0) * Configs.graphColumnsPeriod.inHours} horas',
                                            style: textStyle,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '${(issuesValue.value / ReposController.getRepoPerHourValueById(issuesValue.repo.nodeId!)).round()} horas',
                                            style: textStyle,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            NumberFormat.currency(locale: 'pt_BR', decimalDigits: 2, name: 'R\$').format(issuesValue.value),
                                            style: textStyle,
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
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(),
              ),
              Expanded(
                flex: 4,
                child: Container(),
              ),
              Expanded(
                flex: 2,
                child: Container(),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_filteredIssuesList.fold(0, (previousValue, el) => previousValue + (el.widthInColumns ?? 0)) * Configs.graphColumnsPeriod.inHours} horas',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_filteredIssuesList.fold<double>(0, (previousValue, el) => previousValue + (el.value / ReposController.getRepoPerHourValueById(el.repo.nodeId!))).round()} horas',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    NumberFormat.currency(locale: 'pt_BR', decimalDigits: 2, name: 'R\$').format(_filteredIssuesList.fold<num>(0, (previousValue, el) => previousValue + el.value)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}