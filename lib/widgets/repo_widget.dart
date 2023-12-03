import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../controller/gantt_chart_controller.dart';
import '../model/issue.dart';
import '../view/chart_page.dart';

class RepoWidget extends StatefulWidget {
  final List<String> repos;
  final String token;

  const RepoWidget({
    super.key,
    this.repos = const [],
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
        await GanttChartController.instance.horizontalController.animateTo(
          GanttChartController.instance.horizontalController.offset +
            (
              GanttChartController.instance.selectedIssues[i]!.dragPosFactor.sign *
              (GanttChartController.instance.selectedIssues[i]!.dragPosFactor.abs() - 0.4)
            ) /
            0.001, duration: const Duration(milliseconds: 15), curve: Curves.easeIn
        );
      }
    }

    Future.delayed(const Duration(milliseconds: 15), chartScrollListener);
  }

  @override
  void initState() {
    super.initState();
    GanttChartController.issueListFuture = GanttChartController.instance.gitHub!.getIssuesList().then((value) => GanttChartController.issueList = value);
    chartScrollListener();
    GanttChartController.instance.horizontalController.addOffsetChangedListener(() {
      GanttChartController.instance.lastHorizontalPos = GanttChartController.instance.horizontalController.offset;
    });
    GanttChartController.instance.chartBarsController.addListener(() {
      GanttChartController.instance.lastVerticalPos = GanttChartController.instance.chartBarsController.position.pixels;
    });
  }

  @override
  void didUpdateWidget(RepoWidget oldWidget) {
    if (!widget.repos.equals(oldWidget.repos) || widget.token != oldWidget.token || GanttChartController.instance.gitHub!.refreshIssuesList) {
      GanttChartController.issueListFuture = GanttChartController.instance.gitHub!.getIssuesList().then((value) => GanttChartController.issueList = value);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Issue>>(
      future: GanttChartController.issueListFuture,
      builder: (issuesContext, snapshot) {
        if (snapshot.connectionState == ConnectionState.done || GanttChartController.issueList != null) {
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
                    context.go('/newIssue');
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