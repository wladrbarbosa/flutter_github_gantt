import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/configs.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class WorkSpecificDaysColumns extends StatelessWidget {
  final Map<DateTime, List<int?>> hoursSpecificDates;
  final Function(List<int?>, int index)? onTap;
  final Function(int)? onDeleteColumn;

  const WorkSpecificDaysColumns({
    Key? key,
    this.hoursSpecificDates = const {},
    this.onTap,
    this.onDeleteColumn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    List<int?> daysDivision = [];
    List<Widget> weekWidgets = [];

    for (int i = 0; i < 24 / Configs.graphColumnsPeriod.inHours; i++) {
      daysDivision.add(i);
    }

    for (int i = 0; i < hoursSpecificDates.length; i++) {
      weekWidgets.add(SizedBox(
        width: 120,
        child: Column(
          children: [
            Text(
              DateFormat('EEE, dd/MM/yyyy', 'pt_BR').format(hoursSpecificDates.entries.elementAt(i).key)
            ),
            SizedBox(
              height: 200,
              child: SingleChildScrollView(
                child: MultiSelectChipField<int?>(
                  showHeader: false,
                  scroll: false,
                  chipWidth: mediaQuery.size.width / 16,
                  textStyle: const TextStyle(color: Colors.white),
                  initialValue: hoursSpecificDates[hoursSpecificDates.entries.elementAt(i).key]!,
                  decoration: BoxDecoration(
                    border: Border.all(style: BorderStyle.none),
                  ),
                  onTap: (value) {
                    if (onTap != null) {
                      onTap!(value, i);
                    }
                  },
                  items: daysDivision.map<MultiSelectItem<int?>>((e) {
                    DateTime hora = DateTime(2023, 06, 11);
          
                    return MultiSelectItem<int?>(
                      e,
                      '${DateFormat('HH').format(hora.add(Duration(hours: e! * Configs.graphColumnsPeriod.inHours)))}h á ${DateFormat('HH').format(hora.add(Duration(hours: e * Configs.graphColumnsPeriod.inHours + Configs.graphColumnsPeriod.inHours)))}h',
                    );
                  }).toList(),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (onDeleteColumn != null) {
                  onDeleteColumn!(i);
                }
              },
              child: const Text(
                'Apagar'
              )
            ),
          ],
        ),
      ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: weekWidgets,
      ),
    );
  }
}