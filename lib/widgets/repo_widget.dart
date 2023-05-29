import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/view/new_issue_dialog.dart';
import '../controller/gantt_chart_controller.dart';
import '../model/issue.dart';
import '../view/chart_page.dart';

class RepoWidget extends StatefulWidget {
  final String? repo;
  final String token;

  const RepoWidget({
    super.key,
    this.repo,
    this.token = ''
  });

  @override
  RepoWidgetState createState() => RepoWidgetState();
}

class IncrementIntent extends Intent {
  const IncrementIntent();
}

class DecrementIntent extends Intent {
  const DecrementIntent();
}

class RepoWidgetState extends State<RepoWidget> with TickerProviderStateMixin {
  Future<void> chartScrollListener() async {
    for (int i = 0; i < GanttChartController.instance.selectedIssues.length; i++) {
      if (GanttChartController.instance.selectedIssues[i]!.dragPosFactor.abs() >= 0.4) {
        GanttChartController.instance.horizontalController.animateTo(
          GanttChartController.instance.horizontalController.offset +
            (
              GanttChartController.instance.selectedIssues[i]!.dragPosFactor.sign *
              (GanttChartController.instance.selectedIssues[i]!.dragPosFactor.abs() - 0.4)
            ) /
            0.001, duration: const Duration(milliseconds: 25), curve: Curves.easeIn
        );
      }
    }

    Future.delayed(const Duration(milliseconds: 25), chartScrollListener);
  }

  @override
  void initState() {
    super.initState();
    GanttChartController.issueListFuture = GanttChartController.instance.gitHub!.getIssuesList().then((value) => GanttChartController.issueList = value);
    GanttChartController.instance.assigneesListFuture = GanttChartController.instance.gitHub!.getRepoassigneesListFuture();
    GanttChartController.instance.labelsListFuture = GanttChartController.instance.gitHub!.getRepolabelsListFuture();
    GanttChartController.instance.milestoneListFuture = GanttChartController.instance.gitHub!.getRepoMilestonesList();
    chartScrollListener();
    GanttChartController.instance.horizontalController.addOffsetChangedListener(() {
      GanttChartController.instance.lastHorizontalPos = GanttChartController.instance.horizontalController.offset;
    });
    GanttChartController.instance.chartBarsController.addListener(() {
      GanttChartController.instance.lastVerticalPos = GanttChartController.instance.chartBarsController.position.pixels;
    });
  }

  @override
  void dispose() {
    GanttChartController.instance.focus.dispose();
    super.dispose();
  }

  @override                               
  void didUpdateWidget(RepoWidget oldWidget) {
    if (widget.repo != oldWidget.repo || widget.token != oldWidget.token || GanttChartController.instance.gitHub!.refreshIssuesList) {
      GanttChartController.issueListFuture = GanttChartController.instance.gitHub!.getIssuesList().then((value) => GanttChartController.issueList = value);
      GanttChartController.instance.assigneesListFuture = GanttChartController.instance.gitHub!.getRepoassigneesListFuture();
      GanttChartController.instance.labelsListFuture = GanttChartController.instance.gitHub!.getRepolabelsListFuture();
      GanttChartController.instance.milestoneListFuture = GanttChartController.instance.gitHub!.getRepoMilestonesList();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Issue>>(
      future: GanttChartController.issueListFuture,
      builder: (issuesContext, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            GanttChartController.instance.rememberScrollPositions();

            return ChartPage(
              GanttChartController.issueList!,
              issuesContext,
              Colors.blueAccent
            );
          }
          else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Não possui tarefas'
                ),
                TextButton(
                  onPressed: () {
                    Future.wait<dynamic>(
                      [
                        GanttChartController.instance.assigneesListFuture!,
                        GanttChartController.instance.labelsListFuture!,
                        GanttChartController.instance.milestoneListFuture!
                      ]
                    ).then((value) async {
                      await showDialog(
                        context: issuesContext,
                        builder: (newIssueDialogContext) {
                          return NewIssueDialog(
                            assignees: value[0],
                            labels: value[1],
                            milestones: value[2],
                          );
                        }
                      );
                    });
                  },
                  child: const Text(
                    'Criar a primeira agora'
                  ),
                ),
              ],
            );
          }
        }
        else {
          return const Center(
            child: CircularProgressIndicator()
          );
        }
      }
    );
  }
}