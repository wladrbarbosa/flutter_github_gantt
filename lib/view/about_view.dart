import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/controller/gantt_chart_controller.dart';
import 'package:flutter_github_gantt/model/rate_limit.dart';
import 'package:intl/intl.dart';

class About extends StatelessWidget {
  const About({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: mediaQuery.size.height / 4,
        horizontal: mediaQuery.size.width / 4,
      ),
      child: Center(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: GanttChartController.instance.rateLimit != null ? Column(
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
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                            fontWeight: FontWeight.w500,
                            fontSize: 14
                          )
                        ),
                        TextSpan(
                          text: 'Versão: v1.5.0',
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
                  const Divider(),
                  UsageItem(
                    title: 'Core',
                    limitInfo: GanttChartController.instance.rateLimit!.resources!.core!,
                  ),
                  const Divider(),
                  UsageItem(
                    title: 'Search',
                    limitInfo: GanttChartController.instance.rateLimit!.resources!.search!,
                  ),
                  const Divider(),
                  UsageItem(
                    title: 'GraphQL',
                    limitInfo: GanttChartController.instance.rateLimit!.resources!.graphql!,
                  ),
                  UsageItem(
                    title: 'Integration Manifest',
                    limitInfo: GanttChartController.instance.rateLimit!.resources!.integrationManifest!,
                  ),
                  const Divider(),
                  UsageItem(
                    title: 'Source Import',
                    limitInfo: GanttChartController.instance.rateLimit!.resources!.sourceImport!,
                  ),
                  const Divider(),
                  UsageItem(
                    title: 'Code Scanning Upload',
                    limitInfo: GanttChartController.instance.rateLimit!.resources!.codeScanningUpload!,
                  ),
                  const Divider(),
                  UsageItem(
                    title: 'Actions Runner Registration',
                    limitInfo: GanttChartController.instance.rateLimit!.resources!.actionsRunnerRegistration!,
                  ),
                  const Divider(),
                  UsageItem(
                    title: 'Scim',
                    limitInfo: GanttChartController.instance.rateLimit!.resources!.scim!,
                  ),
                  const Divider(),
                  UsageItem(
                    title: 'Rate',
                    limitInfo: GanttChartController.instance.rateLimit!.rate!,
                  ),
                  const Divider(),
                ],
              ) : const Center(
                child: Text(
                  'Nenhum repositório conectado.'
                ),
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

    if (showLimit) {
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
    }

    if (showUsed) {
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
    }

    if (showRemaining) {
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
    }

    if (showReset) {
      subItems.add(
        Text.rich(
          TextSpan(
            text: 'Reinicia em: ',
            children: [
              TextSpan(
                text: DateFormat('dd/MM/yyyy HH:mm:ss', 'pt-BR').format(DateTime.fromMillisecondsSinceEpoch((limitInfo.reset! * 1000) - 3600000)),
                style: TextStyle(
                  color: Theme.of(context).primaryColor
                )
              ),
            ],
          )
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: subItems,
          ),
        )
      ],
    );
  }
}