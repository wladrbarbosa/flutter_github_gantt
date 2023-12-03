import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_github_gantt/controller/gantt_chart_controller.dart';
import 'package:flutter_github_gantt/controller/repos_controller.dart';
import 'package:flutter_github_gantt/controller/repository.dart';
import 'package:flutter_github_gantt/widgets/fgc_text_field.dart';
import 'package:flutter_github_gantt/widgets/work_specific_days_columns.dart';
import 'package:flutter_github_gantt/widgets/work_week_hours_columns.dart';

class RepoConfig extends StatefulWidget {
  final Repository repo;
  
  const RepoConfig({
    Key? key,
    required this.repo,
  }) : super(key: key);

  @override
  RepoConfigState createState() => RepoConfigState();
}

class RepoConfigState extends State<RepoConfig> {
  late TextEditingController _perHourValueController;
  late Color _tempColor;
  late Map<int, List<int?>> _reposWorkWeekHours;
  late Map<DateTime, List<int?>> _reposWorkSpecificDaysHours;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _perHourValueController = TextEditingController(text: ReposController.getRepoPerHourValueById(widget.repo.nodeId!).toString());
    _tempColor = ReposController.getRepoColorById(widget.repo.nodeId!);
    _reposWorkWeekHours = ReposController.getRepoWorkWeekHoursById(widget.repo.nodeId!);
    _reposWorkSpecificDaysHours = ReposController.getRepoWorkSpecificDaysHoursById(widget.repo.nodeId!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: mediaQuery.size.width / 5,
        vertical: mediaQuery.size.height / 5,
      ),
      alignment: Alignment.center,
      child: Material(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 20.0,
          ),
          child: Column(
            children: [
              Expanded(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Configurações do Repositório "${widget.repo.name}"',
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Selecione uma cor para o repositório "${widget.repo.name!}"'),
                                    content: SingleChildScrollView(
                                      child: ColorPicker(
                                        pickerColor: _tempColor,
                                        onColorChanged: (value) {
                                          _tempColor = value;
                                        },
                                      ),
                                    ),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        child: const Text('Escolher'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                    
                              setState(() {});
                            },
                            child: Row(
                              children: [
                                const Text(
                                  'Cor: ',
                                ),
                                Expanded(
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    color: _tempColor,
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          FGCTextField(
                            _perHourValueController,
                            'Valor por hora',
                            'Valor por hora',
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Horários de trabalho de dias da semana:',
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: WorkWeekHoursColumns(
                              hoursByWeek: _reposWorkWeekHours,
                              onTap: (value, index) {
                                setState(() {
                                  Map<int, List<int?>> temp = Map.from(_reposWorkWeekHours);
                                  temp[index] = value;
                                  _reposWorkWeekHours = temp;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Text(
                                'Horários de trabalho de dias específicos:',
                              ),
                              TextButton(
                                onPressed: () async {
                                  DateTime? date = await showDatePicker(
                                    context: context,
                                    initialEntryMode: DatePickerEntryMode.input,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                    lastDate: DateTime.now().add(const Duration(days: 365))
                                  );

                                  if (date != null) {
                                    setState(() {
                                      Map<DateTime, List<int?>> temp = Map.from(_reposWorkSpecificDaysHours);
                                      temp.addEntries([MapEntry(date, <int?>[])]);
                                      _reposWorkSpecificDaysHours = temp;
                                    });
                                  }
                                },
                                child: const Text(
                                  'Adicionar dia',
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: WorkSpecificDaysColumns(
                              hoursSpecificDates: _reposWorkSpecificDaysHours,
                              onDeleteColumn: (index) {
                                setState(() {
                                  Map<DateTime, List<int?>> temp = Map.from(_reposWorkSpecificDaysHours);
                                  temp.remove(temp.entries.elementAt(index).key);
                                  _reposWorkSpecificDaysHours = temp;
                                });
                              },
                              onTap: (value, index) {
                                setState(() {
                                  Map<DateTime, List<int?>> temp = Map.from(_reposWorkSpecificDaysHours);
                                  temp[temp.entries.elementAt(index).key] = value;
                                  _reposWorkSpecificDaysHours = temp;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text(
                        'Cancelar'
                      )
                    ),
                    TextButton(
                      onPressed: () {
                        ReposController.setRepoConfigs(
                          widget.repo.nodeId!,
                          _tempColor,
                          double.parse(_perHourValueController.text),
                          _reposWorkWeekHours,
                          _reposWorkSpecificDaysHours,
                        );
                        GanttChartController.reposController.update();
                
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text(
                        'Confirmar'
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}