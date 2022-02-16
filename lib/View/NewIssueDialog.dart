import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/Controller/GanttChartController.dart';
import 'package:flutter_github_gantt/Model/Assignees.dart';
import 'package:flutter_github_gantt/Model/Issue.dart';
import 'package:flutter_github_gantt/Model/Label.dart';
import 'package:flutter_github_gantt/Model/Milestone.dart';
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
  _NewIssueDialogState createState() => _NewIssueDialogState();
}

class _NewIssueDialogState extends State<NewIssueDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  List<Assignee> _selAssignees = [];
  List<Label> _selLabels = [];
  Milestone? _selMilestone;
  DateTimeRange? _periodoDaTarefa = DateTimeRange(start: DateTime.now(), end: DateTime.now());
  bool _haveTiming = false;
  bool _isClosed = false;

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
      _periodoDaTarefa = DateTimeRange(
        start: DateFormat('yyyy/MM/dd').parse(RegExp(r'(?<=start_date: ).*').stringMatch(widget.issue!.body!)!),
        end: DateFormat('yyyy/MM/dd').parse(RegExp(r'(?<=due_date: ).*').stringMatch(widget.issue!.body!)!),
      );
    }

    super.initState();
  }

  void selectPeriodo() async {
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
          margin: const EdgeInsets.symmetric(
            horizontal: 400.0,
            vertical: 100.0,
          ),
          child: child,
        );
      }
    );

    if (periodo != null)
      setState(() {
        _periodoDaTarefa = periodo;
      });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 400.0,
        vertical: 100.0,
      ),
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
                    decoration: InputDecoration(
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
                      Expanded(
                        child: Text(
                          'Fechada?'
                        ),
                      ),
                      Expanded(
                        flex: 10,
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
                    decoration: InputDecoration(
                      hintText: 'Descrição da tarefa',
                    ),
                  ),
                  DropdownButtonFormField<int>(
                    value: _selMilestone == null ? null : _selMilestone!.id,
                    hint: Text(
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
                          onPointerDown: (details) async {
                            selectPeriodo();
                          },
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
                      Expanded(
                        child: Listener(
                          onPointerDown: (details) async {
                            selectPeriodo();
                          },
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
                  Listener(
                    onPointerUp: (details) async {
                      await showDialog(
                        context: context,
                        builder: (ctx) {
                          return  Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 400.0,
                              vertical: 100.0,
                            ),
                            child: MultiSelectDialog<Assignee>(
                              cancelText: Text(
                                'Cancelar'
                              ),
                              confirmText: Text(
                                'Confirmar'
                              ),
                              selectedColor: Theme.of(context).primaryColor,
                              unselectedColor: Colors.white,
                              searchHint: 'Pesquisar',
                              title: Text('Pesquisar'),
                              itemsTextStyle: TextStyle(color: Colors.white),
                              checkColor: Theme.of(context).primaryColor,
                              selectedItemsTextStyle: TextStyle(color: Theme.of(context).primaryColor),
                              items: widget.assignees!.map<MultiSelectItem<Assignee>>((e) {
                                return MultiSelectItem<Assignee>(
                                  e,
                                  e.login!,
                                );
                              }).toList(),
                              initialValue: _selAssignees,
                              onConfirm: (values) {
                                setState(() {
                                  _selAssignees = values;
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 40,
                      color: Colors.transparent,
                      child: _selAssignees.length > 0 ? MultiSelectChipDisplay<Assignee>(
                        height: 40,
                        scroll: true,
                        items: _selAssignees.map<MultiSelectItem<Assignee>>((e) {
                          return MultiSelectItem<Assignee>(
                            e,
                            e.login!,
                          );
                        }).toList(),
                      ) : Center(
                        child: Text(
                          'Responsáveis'
                        ),
                      ),
                    ),
                  ),
                  Listener(
                    onPointerUp: (details) async {
                      await showDialog(
                        context: context,
                        builder: (ctx) {
                          return  Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 400.0,
                              vertical: 100.0,
                            ),
                            child: MultiSelectDialog<Label>(
                              cancelText: Text(
                                'Cancelar'
                              ),
                              confirmText: Text(
                                'Confirmar'
                              ),
                              searchHint: 'Pesquisar',
                              title: Text('Pesquisar'),
                              selectedColor: Theme.of(context).primaryColor,
                              unselectedColor: Colors.white,
                              itemsTextStyle: TextStyle(color: Colors.white),
                              checkColor: Theme.of(context).primaryColor,
                              selectedItemsTextStyle: TextStyle(color: Theme.of(context).primaryColor),
                              items: widget.labels!.map<MultiSelectItem<Label>>((e) {
                                return MultiSelectItem<Label>(
                                  e,
                                  e.name!,
                                );
                              }).toList(),
                              initialValue: _selLabels,
                              onConfirm: (values) {
                                setState(() {
                                  _selLabels = values;
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 40,
                      color: Colors.transparent,
                      child: _selLabels.length > 0 ? MultiSelectChipDisplay<Label>(
                        height: 40,
                        scroll: true,
                        items: _selLabels.map<MultiSelectItem<Label>>((e) {
                          return MultiSelectItem<Label>(
                            e,
                            e.name!,
                          );
                        }).toList(),
                      ) : Center(
                        child: Text(
                          'Labels'
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
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String metaInfo = '```yaml\nstart_date: ${DateFormat('yyyy/MM/dd').format(_periodoDaTarefa != null ? _periodoDaTarefa!.start : DateTime.now())}\n'+
                            'due_date: ${DateFormat('yyyy/MM/dd').format(_periodoDaTarefa != null ? _periodoDaTarefa!.end : DateTime.now())}\n'+
                            'progress: 0\n'+
                            'parent: 0\n```${_haveTiming ? '' : '\n\n'}';

                          if (widget.issue != null) {
                            await GanttChartController.instance.gitHub!.updateIssue(
                              widget.issue!,
                              _titleController.text,
                              metaInfo + _bodyController.text,
                              _selMilestone == null ? null : _selMilestone!.number,
                              _selAssignees.map<String>((e) => e.login!).toList(),
                              _selLabels.map<String>((e) => e.name!).toList(),
                              isClosed: _isClosed,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tarefa editada com sucesso!')),
                            );
                          }
                          else {
                            await GanttChartController.instance.gitHub!.createIssue(
                              _titleController.text,
                              metaInfo + _bodyController.text,
                              _selMilestone == null ? null : _selMilestone!.number,
                              _selAssignees.map<String>((e) => e.login!).toList(),
                              _selLabels.map<String>((e) => e.name!).toList(),
                              isClosed: _isClosed,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tarefa criada com sucesso!')),
                            );
                          }

                          if (Navigator.of(context).canPop())
                            Navigator.of(context).pop();
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