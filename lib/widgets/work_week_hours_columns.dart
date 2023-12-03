import 'package:flutter/material.dart';
import 'package:flutter_github_gantt/configs.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class WorkWeekHoursColumns extends StatelessWidget {
  final Map<int, List<int?>> hoursByWeek;
  final Function(List<int?>, int index)? onTap;

  const WorkWeekHoursColumns({
    Key? key,
    this.hoursByWeek = const {},
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    List<int> daysDivision = [];
    List<Widget> weekWidgets = [];

    for (int i = 0; i < 24 / Configs.graphColumnsPeriod.inHours; i++) {
      daysDivision.add(i);
    }

    for (int i = 0; i < 7; i++) {
      weekWidgets.add(SizedBox(
        width: 120,
        child: Column(
          children: [
            Text(
              DateFormat('EEE', 'pt_BR').format(DateTime(2023, 06, 05 + i))
            ),
            SizedBox(
              height: 200,
              child: SingleChildScrollView(
                child: MultiSelectChipField<int?>(
                  showHeader: false,
                  scroll: false,
                  chipWidth: mediaQuery.size.width / 16,
                  textStyle: const TextStyle(color: Colors.white),
                  initialValue: hoursByWeek[i]!,
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
                      '${DateFormat('HH').format(hora.add(Duration(hours: e * Configs.graphColumnsPeriod.inHours)))}h á ${DateFormat('HH').format(hora.add(Duration(hours: e * Configs.graphColumnsPeriod.inHours + Configs.graphColumnsPeriod.inHours)))}h',
                    );
                  }).toList(),
                ),
              ),
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