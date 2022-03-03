import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/Controller/GanttChartController.dart';
import 'package:flutter_github_gantt/Model/RateLimit.dart';
import 'package:intl/intl.dart';

class About extends StatelessWidget {
  const About({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 200.0,
        horizontal: 600.0,
      ),
      child: Center(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              width: 400,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'Github Gantt\n\n',
                      children: [
                        TextSpan(
                          text: 'Aplicação para organizar tarefas (issues) do GitHub em um gráfico de gantt, usando a descrição das próprias tarefas como forma de persistir informações pertinentes a ele. Além disso, foi usada a API do GitHub para facilitar o acesso à funções como edição, criação e deleção de tarefas diretamente por aqui através do uso de tokens de acesso.\n\n',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1!.color,
                            fontWeight: FontWeight.w500,
                            fontSize: 14
                          )
                        ),
                        TextSpan(
                          text: 'Versão: v1.3.11',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14
                          )
                        ),
                      ],
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 18
                      )
                    )
                  ),
                  Divider(),
                  UsageItem(
                    title: 'Core',
                    limitInfo: GanttChartController.instance.rateLimit!.resources!.core!,
                  ),
                  Divider(),
                  UsageItem(
                    title: 'Search',
                    limitInfo: GanttChartController.instance.rateLimit!.resources!.search!,
                  ),
                  Divider(),
                  UsageItem(
                    title: 'GraphQL',
                    limitInfo: GanttChartController.instance.rateLimit!.resources!.graphql!,
                  ),
                  UsageItem(
                    title: 'Integration Manifest',
                    limitInfo: GanttChartController.instance.rateLimit!.resources!.integrationManifest!,
                  ),
                  Divider(),
                  UsageItem(
                    title: 'Source Import',
                    limitInfo: GanttChartController.instance.rateLimit!.resources!.sourceImport!,
                  ),
                  Divider(),
                  UsageItem(
                    title: 'Code Scanning Upload',
                    limitInfo: GanttChartController.instance.rateLimit!.resources!.codeScanningUpload!,
                  ),
                  Divider(),
                  UsageItem(
                    title: 'Actions Runner Registration',
                    limitInfo: GanttChartController.instance.rateLimit!.resources!.actionsRunnerRegistration!,
                  ),
                  Divider(),
                  UsageItem(
                    title: 'Scim',
                    limitInfo: GanttChartController.instance.rateLimit!.resources!.scim!,
                  ),
                  Divider(),
                  UsageItem(
                    title: 'Rate',
                    limitInfo: GanttChartController.instance.rateLimit!.rate!,
                  ),
                  Divider(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UsageItem extends StatelessWidget {
  final String title;
  final Core limitInfo;
  final bool showLimit;
  final bool showUsed;
  final bool showRemaining;
  final bool showReset;
  
  const UsageItem({
    Key? key,
    required this.title,
    required this.limitInfo,
    this.showLimit = true,
    this.showUsed = true,
    this.showRemaining = true,
    this.showReset = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> subItems = [];

    if (showLimit)
      subItems.add(
        Text.rich(
          TextSpan(
            text: 'Limite: ',
            children: [
              TextSpan(
                text: '${limitInfo.limit}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor
                )
              ),
            ],
          )
        ),
      );

    if (showUsed)
      subItems.add(
        Text.rich(
          TextSpan(
            text: 'Usado: ',
            children: [
              TextSpan(
                text: '${limitInfo.used}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor
                )
              ),
            ],
          )
        ),
      );

    if (showRemaining)
      subItems.add(
        Text.rich(
          TextSpan(
            text: 'Restante: ',
            children: [
              TextSpan(
                text: '${limitInfo.remaining}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor
                )
              ),
            ],
          )
        ),
      );

    if (showReset)
      subItems.add(
        Text.rich(
          TextSpan(
            text: 'Reinicia em: ',
            children: [
              TextSpan(
                text: '${DateFormat('dd/MM/yyyy HH:mm:ss', 'pt-BR').format(DateTime.fromMillisecondsSinceEpoch((limitInfo.reset! * 1000) - 3600000))}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor
                )
              ),
            ],
          )
        ),
      );

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20.0
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: subItems,
            ),
          )
        ],
      ),
    );
  }
}