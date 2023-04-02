import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/controller/gantt_chart_controller.dart';
import 'package:flutter_github_gantt/model/assignees.dart';
import 'package:flutter_github_gantt/model/issue.dart';
import 'package:flutter_github_gantt/model/label.dart';
import 'package:flutter_github_gantt/model/milestone.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

class NewIssueDialog extends StatefulWidget {
  final List<Assignee>? assignees;
  final List<Label>? labels;
  final List<Milestone>? milestones;
  final Issue? issue;

  const NewIssueDialog({
    Key? key,
    this.assignees,
    this.labels,
    required this.milestones,
    this.issue,
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

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.issue != null ? widget.issue!.title : '');
    _bodyController = TextEditingController(text: widget.issue != null ? widget.issue!.body!.replaceAll(RegExp(r'```.*```', dotAll: true), '') : '');

    if (widget.issue != null) {
      _haveTiming = RegExp(r'```yaml(\n.*)*```').hasMatch(widget.issue!.body!);
      _selAssignees = widget.issue!.assignees!;
      _selLabels = widget.issue!.labels!;
      _selMilestone = widget.issue!.milestone;
      _isClosed = widget.issue!.state == 'closed';
      _selDepIssues = widget.issue!.dependencies;
      
      _periodoDaTarefa = DateTimeRange(
        start: DateFormat('yyyy/MM/dd HH:mm:ss').parse(RegExp(r'(?<=start_date: ).*').stringMatch(widget.issue!.body!)!),
        end: DateFormat('yyyy/MM/dd HH:mm:ss').parse(RegExp(r'(?<=due_date: ).*').stringMatch(widget.issue!.body!)!),
      );
      _horaInicioDaTarefa = TimeOfDay.fromDateTime(_periodoDaTarefa!.start);
      _horaFimDaTarefa = TimeOfDay.fromDateTime(_periodoDaTarefa!.end);
    }
    else {
      _selAssignees.add(widget.assignees!.singleWhere((el) => el.login == GanttChartController.instance.user!.login));
      _horaInicioDaTarefa = TimeOfDay.now();
      _horaFimDaTarefa = TimeOfDay.now();
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
                  widget.issue != null ? Row(
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
                  DropdownButtonFormField<int>(
                    value: _selMilestone == null ? widget.milestones!.isNotEmpty ? widget.milestones![0].id : null : _selMilestone!.id,
                    hint: const Text(
                      'Milestone',
                    ),
                    items: widget.milestones!.map<DropdownMenuItem<int>>((e) {
                      return DropdownMenuItem<int>(
                        value: e.id,
                        child: Text(
                          e.title!,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selMilestone = widget.milestones!.firstWhere((el) => el.id == value);
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
                                items: widget.assignees!.map<MultiSelectItem<int>>((e) {
                                  return MultiSelectItem<int>(
                                    e.id!,
                                    e.login!,
                                  );
                                }).toList(),
                                initialValue: _selAssignees.map<int>((e) => e.id!).toList(),
                                onConfirm: (values) {
                                  setState(() {
                                    _selAssignees = widget.assignees!.where((el) => values.contains(el.id)).toList();
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
                        items: _selAssignees.map<MultiSelectItem<Assignee>>((e) {
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
                                items: widget.labels!.map<MultiSelectItem<int>>((e) {
                                  return MultiSelectItem<int>(
                                    e.id!,
                                    e.name!,
                                  );
                                }).toList(),
                                initialValue: _selLabels.map<int>((e) => e.id!).toList(),
                                onConfirm: (values) {
                                  setState(() {
                                    _selLabels = widget.labels!.where((el) => values.contains(el.id)).toList();
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
                        items: _selLabels.map<MultiSelectItem<Label>>((e) {
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
                                items: GanttChartController.instance.issueList!.map<MultiSelectItem<int>>((e) {
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
                          DateTime inicio = DateTime.now();
                          inicio = inicio.subtract(
                            Duration(
                              hours: inicio.hour % 3,
                              minutes: inicio.minute,
                              seconds: inicio.second,
                              milliseconds: inicio.millisecond,
                              microseconds: inicio.microsecond,
                            )
                          );
                          DateTime fim = inicio;
                          fim = fim.subtract(
                            Duration(
                              hours: -(3 - inicio.hour % 3),
                              minutes: fim.minute,
                              seconds: fim.second,
                              milliseconds: fim.millisecond,
                              microseconds: fim.microsecond,
                            )
                          );

                          _periodoDaTarefa = DateTimeRange(start: inicio, end: fim);
                          String metaInfo = '```yaml\nstart_date: ${DateFormat('yyyy/MM/dd HH:mm:ss').format(_periodoDaTarefa != null ? _periodoDaTarefa!.start : inicio)}\ndue_date: ${DateFormat('yyyy/MM/dd HH:mm:ss').format(_periodoDaTarefa != null ? _periodoDaTarefa!.end : fim)}\nprogress: 0\nparent: ${_selDepIssues.fold('', (previousValue, el) => '$previousValue${previousValue != '' ? ',' : ''}$el')}\n```${_haveTiming ? '' : '\n\n'}';

                          if (widget.issue != null) {
                            GanttChartController.instance.gitHub!.updateIssue(
                              widget.issue!,
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