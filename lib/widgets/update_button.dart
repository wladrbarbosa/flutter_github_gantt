import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/controller/gantt_chart_controller.dart';

class UpdateButton extends StatelessWidget {
  const UpdateButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        GanttChartController.instance.gitHub!.reloadIssues();
      },
      child: const Text(
        'Atualizar',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}