import 'dart:async';
import 'package:flutter/material.dart';
import 'Controller/GanttChartController.dart';
import 'Model/Issue.dart';
import 'View/GanttChart.dart';

class GanttChartApp extends StatefulWidget {
  final String? repo;
  final String token;

  GanttChartApp({
    this.repo,
    this.token = ''
  });

  @override
  GanttChartAppState createState() => GanttChartAppState();
}

class IncrementIntent extends Intent {
  const IncrementIntent();
}

class DecrementIntent extends Intent {
  const DecrementIntent();
}

class GanttChartAppState extends State<GanttChartApp> with TickerProviderStateMixin {
  Future<List<Issue>>? _issueList;

  Future<void> chartScrollListener() async {
    for (int i = 0; i < GanttChartController.instance.selectedIssues.length; i++) {
      if (GanttChartController.instance.selectedIssues[i]!.dragPosFactor.abs() >= 0.4)
        GanttChartController.instance.horizontalController.animateTo(GanttChartController.instance.horizontalController.position.pixels + (GanttChartController.instance.selectedIssues[i]!.dragPosFactor.sign * (GanttChartController.instance.selectedIssues[i]!.dragPosFactor.abs() - 0.4)) / 0.001, duration: Duration(milliseconds: 100), curve: Curves.easeIn);
    }

    Future.delayed(Duration(milliseconds: 100), chartScrollListener);
  }

  @override
  void initState() {
    super.initState();
    _issueList = GanttChartController.instance.gitHub!.getIssuesList();
    chartScrollListener();
  }

  @override
  void dispose() {
    GanttChartController.instance.focus.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GanttChartApp oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.repo != oldWidget.repo || widget.token != oldWidget.token || GanttChartController.instance.gitHub!.refreshIssuesList)
      _issueList = GanttChartController.instance.gitHub!.getIssuesList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<Issue>>(
            future: _issueList,
            builder: (issuesContext, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData)
                  return GanttChart(snapshot.data!, issuesContext, Colors.blueAccent);
                else
                  return Center(
                    child: Text(
                      'Não possui tarefas'
                    ),
                  );
              }
              else
                return Center(
                  child: CircularProgressIndicator()
                );
            }
          )
        ),
      ],
    );
  }
}