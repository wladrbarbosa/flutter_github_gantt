import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/configs.dart';
import 'package:flutter_github_gantt/controller/gantt_chart_controller.dart';
import 'package:flutter_github_gantt/controller/repos_controller.dart';
import 'package:flutter_github_gantt/controller/repository.dart';
import 'package:flutter_github_gantt/model/assignees.dart';
import 'package:flutter_github_gantt/model/issue.dart';
import 'package:flutter_github_gantt/model/label.dart';
import 'package:flutter_github_gantt/model/milestone.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class NewIssueDialog extends StatefulWidget {
  final bool isUpdate;
  
  const NewIssueDialog({
    Key? key,
    this.isUpdate = false
  }) : super(key: key);

  @override
  NewIssueDialogState createState() => NewIssueDialogState();
}

class NewIssueDialogState extends State<NewIssueDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  List<Assignee> _selAssignees = [];
  List<Label> _selLabels = [];
  List<int> _selDepIssues = [];
  Milestone? _selMilestone;
  DateTimeRange? _periodoDaTarefa = DateTimeRange(start: DateTime.now(), end: DateTime.now());
  late TimeOfDay _horaInicioDaTarefa;
  late TimeOfDay _horaFimDaTarefa;
  bool _haveTiming = false;
  bool _isClosed = false;
  bool touchMoves = false;
  Repository? selRepo;
  Issue? issue;

  @override
  void initState() {
    if (widget.isUpdate && GanttChartController.instance.selectedIssues.isNotEmpty) {
      issue = GanttChartController.instance.selectedIssues[0];
    }
    
    _titleController = TextEditingController(text: issue != null ? issue!.title : '');
    _bodyController = TextEditingController(text: issue != null ? issue!.body!.replaceAll(RegExp(r'```.*```', dotAll: true), '').replaceAll('\n', '') : '');

    if (issue != null) {
      _haveTiming = RegExp(r'```yaml(\n.*)*```').hasMatch(issue!.body!);
      _selAssignees = issue!.assignees!;
      _selLabels = issue!.labels!;
      _selMilestone = issue!.milestone;
      _isClosed = issue!.state == 'closed';
      _selDepIssues = issue!.dependencies;
      _periodoDaTarefa = GanttChartController.parseIssueBody(issue!);
      _horaInicioDaTarefa = TimeOfDay.fromDateTime(_periodoDaTarefa!.start);
      _horaFimDaTarefa = TimeOfDay.fromDateTime(_periodoDaTarefa!.end);
      selRepo = issue!.repo;
    }
    else {
      _horaInicioDaTarefa = TimeOfDay.now();
      _horaFimDaTarefa = TimeOfDay.now();

      _horaInicioDaTarefa = _horaInicioDaTarefa.replacing(
        hour: _horaInicioDaTarefa.hour - (_horaInicioDaTarefa.hour % Configs.graphColumnsPeriod.inHours),
        minute: 0,
      );

      int horaFimDaTarefaTemp = _horaInicioDaTarefa.hour + Configs.graphColumnsPeriod.inHours;

      if (horaFimDaTarefaTemp == 24) {
        horaFimDaTarefaTemp = 0;
      }

      _horaFimDaTarefa = _horaFimDaTarefa.replacing(
        hour: horaFimDaTarefaTemp,
        minute: 0,
      );
    }

    // Para resolver problema em criar tarefa próximo das 00h
    if (_periodoDaTarefa!.start.difference(_periodoDaTarefa!.end).inDays == 0 && _horaFimDaTarefa.hour < _horaInicioDaTarefa.hour) {
      _periodoDaTarefa = DateTimeRange(start: _periodoDaTarefa!.start, end: _periodoDaTarefa!.start.add(const Duration(days: 1)));
    }

    super.initState();
  }

  void selectPeriodo(MediaQueryData mediaQuery) async {
    DateTime today = DateTime.now();

    DateTimeRange? periodo = await showDateRangePicker(
      context: context,
      currentDate: today,
      initialDateRange: _periodoDaTarefa,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: DateTime(today.year - 20, today.month, today.day),
      lastDate: DateTime(today.year + 100, today.month, today.day),
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: mediaQuery.size.width / 10,
            vertical: mediaQuery.size.height / 10,
          ),
          child: child,
        );
      }
    );

    if (periodo != null) {
      setState(() {
        _periodoDaTarefa = periodo;
      });
    }
  }

  Future<TimeOfDay?> selectHora(MediaQueryData mediaQuery) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dialOnly,
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: mediaQuery.size.width / 10,
        vertical: mediaQuery.size.height / 10,
      ),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Material(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 20.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Nome da tarefa',
                    ),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'O nome da tarefa é obrigatório.';
                      }
                      return null;
                    },
                  ),
                  issue != null ? Row(
                    children: [
                      const Text(
                        'Fechada?'
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Switch(
                            activeColor: Theme.of(context).primaryColor,
                            value: _isClosed,
                            onChanged: (value) {
                              setState(() {
                                _isClosed = value;
                              });
                            }
                          ),
                        ),
                      ),
                    ],
                  ) : Container(),
                  TextFormField(
                    controller: _bodyController,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText: 'Descrição da tarefa',
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Repo:'
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: selRepo == null ? null : selRepo!.id,
                          onChanged: (newValue) {
                            setState(() {
                              GanttChartController.instance.isTodayJumped = false;
                              selRepo = ReposController.repos.singleWhereOrNull((e) => e.id == newValue);
                              _selAssignees.clear();
                              _selAssignees.addAll(selRepo!.assigneesList ?? []);
                            });
                          },
                          disabledHint: const Text(
                            'Selecione o repositório...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          hint: const Text(
                            'Selecione o repositório...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          items: GanttChartController.selRepos.map<DropdownMenuItem<int>>((e) => DropdownMenuItem<int>(
                            value: e.id,
                            child: Text(
                              e.name!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )).toList()
                        ),
                      ),
                    ],
                  ),
                  DropdownButtonFormField<int>(
                    value: _selMilestone == null
                      ? selRepo != null && selRepo!.milestoneList != null && selRepo!.milestoneList!.isNotEmpty
                        ? selRepo!.milestoneList![0].id
                        : null
                      : _selMilestone!.id,
                    hint: const Text(
                      'Milestone',
                    ),
                    items: (selRepo != null ? GanttChartController.selRepos.singleWhere((el) => el.nodeId == selRepo!.nodeId).milestoneList : [])!.map<DropdownMenuItem<int>>((e) {
                      return DropdownMenuItem<int>(
                        value: e.id,
                        child: Text(
                          e.title!,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selMilestone = selRepo!.milestoneList!.firstWhere((el) => el.id == value);
                      });
                    }
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Listener(
                          onPointerUp: (details) async {
                            if (!touchMoves) {
                              selectPeriodo(mediaQuery);
                            }

                            touchMoves = false;
                          },
                          onPointerMove: (details) => touchMoves = true,
                          child: Container(
                            height: 40,
                            color: Colors.transparent,
                            child: Center(
                              child: Text(
                                _periodoDaTarefa != null ? DateFormat('dd/MM/yyyy').format(_periodoDaTarefa!.start) : 'Início'
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Text(
                        'à'
                      ),
                      Expanded(
                        child: Listener(
                          onPointerUp: (details) async {
                            if (!touchMoves) {
                              selectPeriodo(mediaQuery);
                            }

                            touchMoves = false;
                          },
                          onPointerMove: (details) => touchMoves = true,
                          child: Container(
                            height: 40,
                            color: Colors.transparent,
                            child: Center(
                              child: Text(
                                _periodoDaTarefa != null ? DateFormat('dd/MM/yyyy').format(_periodoDaTarefa!.end) : 'Fim'
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Listener(
                          onPointerUp: (details) async {
                            if (!touchMoves) {
                              selectHora(mediaQuery).then((value) {
                                if (value != null) {
                                  setState(() {
                                    _horaInicioDaTarefa = value;
                                  });
                                }
                              });
                            }

                            touchMoves = false;
                          },
                          onPointerMove: (details) => touchMoves = true,
                          child: Container(
                            height: 40,
                            color: Colors.transparent,
                            child: Center(
                              child: Text(
                                DateFormat('HH:mm:ss').format(DateTime(2023, 1, 8, _horaInicioDaTarefa.hour, _horaInicioDaTarefa.minute, 0))
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Listener(
                          onPointerUp: (details) async {
                            if (!touchMoves) {
                              selectHora(mediaQuery).then((value) {
                                if (value != null) {
                                  setState(() {
                                    _horaFimDaTarefa = value;
                                  });
                                }
                              });
                            }

                            touchMoves = false;
                          },
                          onPointerMove: (details) => touchMoves = true,
                          child: Container(
                            height: 40,
                            color: Colors.transparent,
                            child: Center(
                              child: Text(
                                DateFormat('HH:mm:ss').format(DateTime(2023, 1, 8, _horaFimDaTarefa.hour, _horaFimDaTarefa.minute, 0))
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Listener(
                    onPointerUp: (details) async {
                      if (!touchMoves) {
                        await showDialog(
                          context: context,
                          builder: (ctx) {
                            return  Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: mediaQuery.size.width / 10,
                                vertical: mediaQuery.size.height / 10,
                              ),
                              child: MultiSelectDialog<int>(
                                cancelText: const Text(
                                  'Cancelar'
                                ),
                                confirmText: const Text(
                                  'Confirmar'
                                ),
                                selectedColor: Theme.of(context).primaryColor,
                                unselectedColor: Colors.white,
                                searchHint: 'Pesquisar',
                                title: const Text('Pesquisar'),
                                itemsTextStyle: const TextStyle(color: Colors.white),
                                checkColor: Theme.of(context).primaryColor,
                                selectedItemsTextStyle: TextStyle(color: Theme.of(context).primaryColor),
                                items: (selRepo != null ? GanttChartController.selRepos.singleWhere((el) => el.nodeId == selRepo!.nodeId).assigneesList ?? [] : []).map<MultiSelectItem<int>>((e) {
                                  return MultiSelectItem<int>(
                                    e.id!,
                                    e.login!,
                                  );
                                }).toList(),
                                initialValue: _selAssignees.map<int>((e) => e.id!).toList(),
                                onConfirm: (values) {
                                  setState(() {
                                    _selAssignees = (selRepo != null ? GanttChartController.selRepos.singleWhere((el) => el.nodeId == selRepo!.nodeId).assigneesList ?? [] : <Assignee>[]).where((el) => values.contains(el.id)).toList();
                                  });
                                },
                              ),
                            );
                          },
                        );
                      }

                      touchMoves = false;
                    },
                    onPointerMove: (details) => touchMoves = true,
                    child: Container(
                      height: 40,
                      color: Colors.transparent,
                      child: _selAssignees.isNotEmpty ? MultiSelectChipDisplay<Assignee>(
                        height: 40,
                        scroll: true,
                        items: (selRepo != null ? GanttChartController.selRepos.singleWhere((el) => el.nodeId == selRepo!.nodeId).assigneesList ?? [] : []).map<MultiSelectItem<Assignee>>((e) {
                          return MultiSelectItem<Assignee>(
                            e,
                            e.login!,
                          );
                        }).toList(),
                      ) : const Center(
                        child: Text(
                          'Responsáveis'
                        ),
                      ),
                    ),
                  ),
                  Listener(
                    onPointerUp: (details) async {
                      if (!touchMoves) {
                        await showDialog(
                          context: context,
                          builder: (ctx) {
                            return  Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: mediaQuery.size.width / 10,
                                vertical: mediaQuery.size.height / 10,
                              ),
                              child: MultiSelectDialog<int>(
                                cancelText: const Text(
                                  'Cancelar'
                                ),
                                confirmText: const Text(
                                  'Confirmar'
                                ),
                                searchHint: 'Pesquisar',
                                title: const Text('Pesquisar'),
                                selectedColor: Theme.of(context).primaryColor,
                                unselectedColor: Colors.white,
                                itemsTextStyle: const TextStyle(color: Colors.white),
                                checkColor: Theme.of(context).primaryColor,
                                selectedItemsTextStyle: TextStyle(color: Theme.of(context).primaryColor),
                                items: (selRepo != null ? GanttChartController.selRepos.singleWhere((el) => el.nodeId == selRepo!.nodeId).labelsList ?? [] : []).map<MultiSelectItem<int>>((e) {
                                  return MultiSelectItem<int>(
                                    e.id!,
                                    e.name!,
                                  );
                                }).toList(),
                                initialValue: _selLabels.map<int>((e) => e.id!).toList(),
                                onConfirm: (values) {
                                  setState(() {
                                    _selLabels = (selRepo != null ? GanttChartController.selRepos.singleWhere((el) => el.nodeId == selRepo!.nodeId).labelsList ?? [] : <Label>[]).where((el) => values.contains(el.id)).toList();
                                  });
                                },
                              ),
                            );
                          },
                        );
                      }

                      touchMoves = false;
                    },
                    onPointerMove: (details) => touchMoves = true,
                    child: Container(
                      height: 40,
                      color: Colors.transparent,
                      child: _selLabels.isNotEmpty ? MultiSelectChipDisplay<Label>(
                        height: 40,
                        scroll: true,
                        items: (selRepo != null ? GanttChartController.selRepos.singleWhere((el) => el.nodeId == selRepo!.nodeId).labelsList ?? [] : []).map<MultiSelectItem<Label>>((e) {
                          return MultiSelectItem<Label>(
                            e,
                            e.name!,
                          );
                        }).toList(),
                      ) : const Center(
                        child: Text(
                          'Labels'
                        ),
                      ),
                    ),
                  ),
                  Listener(
                    onPointerUp: (details) async {
                      if (!touchMoves) {
                        await showDialog(
                          context: context,
                          builder: (ctx) {
                            return  Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: mediaQuery.size.width / 10,
                                vertical: mediaQuery.size.height / 10,
                              ),
                              child: MultiSelectDialog<int>(
                                cancelText: const Text(
                                  'Cancelar'
                                ),
                                confirmText: const Text(
                                  'Confirmar'
                                ),
                                searchHint: 'Pesquisar',
                                title: const Text('Pesquisar'),
                                selectedColor: Theme.of(context).primaryColor,
                                unselectedColor: Colors.white,
                                itemsTextStyle: const TextStyle(color: Colors.white),
                                checkColor: Theme.of(context).primaryColor,
                                selectedItemsTextStyle: TextStyle(color: Theme.of(context).primaryColor),
                                items: GanttChartController.issueList!.map<MultiSelectItem<int>>((e) {
                                  return MultiSelectItem<int>(
                                    e.number!,
                                    '${e.number!} - ${e.title!}',
                                  );
                                }).toList(),
                                initialValue: _selDepIssues,
                                onConfirm: (values) {
                                  setState(() {
                                    _selDepIssues = values;
                                  });
                                },
                              ),
                            );
                          },
                        );
                      }

                      touchMoves = false;
                    },
                    onPointerMove: (details) => touchMoves = true,
                    child: Container(
                      height: 40,
                      color: Colors.transparent,
                      child: _selDepIssues.isNotEmpty ? MultiSelectChipDisplay<int>(
                        height: 40,
                        scroll: true,
                        items: _selDepIssues.map<MultiSelectItem<int>>((e) {
                          return MultiSelectItem<int>(
                            e,
                            e.toString(),
                          );
                        }).toList(),
                      ) : const Center(
                        child: Text(
                          'Dependências'
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        alignment: Alignment.center,
                        minimumSize: Size(mediaQuery.size.width, 40.0)
                      ),
                      onPressed: () {
                        void closeDialog(String msg) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg)),
                          );

                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        }

                        if (_formKey.currentState!.validate()) {
                          DateTime inicio = DateTime(
                            _periodoDaTarefa!.start.year,
                            _periodoDaTarefa!.start.month,
                            _periodoDaTarefa!.start.day,
                            _horaInicioDaTarefa.hour
                          );
                          DateTime fim = DateTime(
                            _periodoDaTarefa!.end.year,
                            _periodoDaTarefa!.end.month,
                            _periodoDaTarefa!.end.day,
                            _horaFimDaTarefa.hour
                          );

                          _periodoDaTarefa = DateTimeRange(start: inicio, end: fim);
                          String metaInfo = '```yaml\nstart_date: ${DateFormat('yyyy/MM/dd HH:mm:ss').format(_periodoDaTarefa != null ? _periodoDaTarefa!.start : inicio)}\ndue_date: ${DateFormat('yyyy/MM/dd HH:mm:ss').format(_periodoDaTarefa != null ? _periodoDaTarefa!.end : fim)}\nprogress: 0\nparent: ${_selDepIssues.fold('', (previousValue, el) => '$previousValue${previousValue != '' ? ',' : ''}$el')}\n```${_haveTiming ? '' : '\n\n'}';

                          if (issue != null) {
                            GanttChartController.instance.gitHub!.updateIssue(
                              _titleController.text,
                              metaInfo + _bodyController.text,
                              _selMilestone == null ? null : _selMilestone!.number,
                              _selAssignees,
                              _selLabels,
                              _selDepIssues,
                              isClosed: _isClosed,
                            ).whenComplete(() {
                              closeDialog('Tarefa editada com sucesso!');
                            });
                          }
                          else {
                            GanttChartController.instance.gitHub!.createIssue(
                              _titleController.text,
                              metaInfo + _bodyController.text,
                              selRepo!,
                              _selMilestone == null ? null : _selMilestone!.number,
                              _selAssignees.map<String>((e) => e.login!).toList(),
                              _selLabels.map<String>((e) => e.name!).toList(),
                              isClosed: _isClosed,
                            ).whenComplete(() {
                              closeDialog('Tarefa criada com sucesso!');
                            });
                          }
                        }
                      },
                      child: const Text('Confirmar'),
                    ),
                  ),
                ],
              )
            ),
          ),
        ),
      ),
    );
  }
}