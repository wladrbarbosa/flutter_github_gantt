import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/Model/Assignees.dart';
import 'package:flutter_github_gantt/Model/Label.dart';
import 'package:flutter_github_gantt/Model/Milestone.dart';
import 'package:flutter_github_gantt/View/NewIssueDialog.dart';
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
    GanttChartController.instance.issueListFuture = GanttChartController.instance.gitHub!.getIssuesList().then((value) => GanttChartController.instance.issueList = value);
    GanttChartController.instance.assigneesListFuture = GanttChartController.instance.gitHub!.getRepoassigneesListFuture();
    GanttChartController.instance.labelsListFuture = GanttChartController.instance.gitHub!.getRepolabelsListFuture();
    GanttChartController.instance.milestoneListFuture = GanttChartController.instance.gitHub!.getRepoMilestonesList();
    chartScrollListener();
    GanttChartController.instance.horizontalController.addListener(() {
      GanttChartController.instance.lastHorizontalPos = GanttChartController.instance.horizontalController.position.pixels;
    });
    GanttChartController.instance.chartController.addListener(() {
      GanttChartController.instance.lastVerticalPos = GanttChartController.instance.chartController.position.pixels;
    });
  }

  @override
  void dispose() {
    GanttChartController.instance.focus.dispose();
    super.dispose();
  }

  @override                               
  void didUpdateWidget(GanttChartApp oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.repo != oldWidget.repo || widget.token != oldWidget.token || GanttChartController.instance.gitHub!.refreshIssuesList) {
      GanttChartController.instance.issueListFuture = GanttChartController.instance.gitHub!.getIssuesList().then((value) => GanttChartController.instance.issueList = value);
      GanttChartController.instance.assigneesListFuture = GanttChartController.instance.gitHub!.getRepoassigneesListFuture();
      GanttChartController.instance.labelsListFuture = GanttChartController.instance.gitHub!.getRepolabelsListFuture();
      GanttChartController.instance.milestoneListFuture = GanttChartController.instance.gitHub!.getRepoMilestonesList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<Issue>>(
            future: GanttChartController.instance.issueListFuture,
            builder: (issuesContext, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  GanttChartController.instance.rememberScrollPositions();
                  return GanttChart(snapshot.data!, issuesContext, Colors.blueAccent);
                }
                else
                  return Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Não possui tarefas'
                        ),
                        TextButton(
                          onPressed: () async {
                            List<Assignee>? assignees = await GanttChartController.instance.assigneesListFuture;
                            List<Label>? labels = await GanttChartController.instance.labelsListFuture;
                            List<Milestone>? milestones = await GanttChartController.instance.milestoneListFuture;

                            await showDialog(
                              context: issuesContext,
                              builder: (NewIssueDialogContext) {
                                return NewIssueDialog(
                                  assignees: assignees,
                                  labels: labels,
                                  milestones: milestones,
                                );
                              }
                            );
                          },
                          child: Text(
                            'Criar a primeira agora'
                          ),
                        ),
                      ],
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