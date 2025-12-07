import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:cid_retranslator/theme/constants.dart';
import 'package:cid_retranslator/providers/event_provider.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({super.key});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  int? _sortColumnIndex;
  bool _sortAscending = false; // Default descending (newest first)
  final DateFormat _dateFormat = DateFormat('HH:mm:ss yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        if (eventProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.win11Accent),
          );
        }

        if (eventProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.win11Error,
                ),
                SizedBox(height: 16),
                Text(
                  'Помилка завантаження подій',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.win11TextPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  eventProvider.error!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.win11TextSecondary,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => eventProvider.loadEvents(),
                  child: Text('Повторити спробу'),
                ),
              ],
            ),
          );
        }

        if (eventProvider.events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_note,
                  size: 64,
                  color: AppColors.win11TextSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'Немає подій',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.win11TextSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          color: AppColors.win11Background,
          padding: EdgeInsets.all(8),
          child: DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 800,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            headingRowColor: WidgetStateProperty.all(
              AppColors.win11CardBackground,
            ),
            columns: [
              DataColumn2(
                label: Text(
                  'Час',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                size: ColumnSize.M,
                onSort: (columnIndex, ascending) {
                  _sort('time', columnIndex, ascending, eventProvider);
                },
              ),
              DataColumn2(
                label: Text(
                  'ППК',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                size: ColumnSize.S,
                onSort: (columnIndex, ascending) {
                  _sort('device', columnIndex, ascending, eventProvider);
                },
              ),
              DataColumn2(
                label: Text(
                  'Код',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                size: ColumnSize.S,
                onSort: (columnIndex, ascending) {
                  _sort('code', columnIndex, ascending, eventProvider);
                },
              ),
              DataColumn2(
                label: Text(
                  'Тип',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                size: ColumnSize.M,
                onSort: (columnIndex, ascending) {
                  _sort('type', columnIndex, ascending, eventProvider);
                },
              ),
              DataColumn2(
                label: Text(
                  'Опис',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                size: ColumnSize.L,
              ),
              DataColumn2(
                label: Text(
                  'Зона/Група',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                size: ColumnSize.M,
              ),
            ],
            rows: eventProvider.events.map((event) {
              final colors = _getEventColors(event.priority);

              return DataRow2(
                color: WidgetStateProperty.all(colors.background),
                cells: [
                  DataCell(
                    Text(
                      _dateFormat.format(event.time ?? DateTime(1970)),
                      style: TextStyle(color: colors.text),
                    ),
                  ),
                  DataCell(
                    Text(
                      event.device ?? '',
                      style: TextStyle(color: colors.text),
                    ),
                  ),
                  DataCell(
                    Text(
                      event.code ?? '',
                      style: TextStyle(color: colors.text),
                    ),
                  ),
                  DataCell(
                    Text(
                      event.type ?? '',
                      style: TextStyle(color: colors.text),
                    ),
                  ),
                  DataCell(
                    Text(
                      event.desc ?? '',
                      style: TextStyle(color: colors.text),
                    ),
                  ),
                  DataCell(
                    Text(
                      event.zone ?? '',
                      style: TextStyle(color: colors.text),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _sort(
    String column,
    int columnIndex,
    bool ascending,
    EventProvider provider,
  ) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    provider.sortEvents(column, ascending);
  }

  EventColors _getEventColors(int priority) {
    switch (priority) {
      case EventPriority.unknown:
        return EventColors(
          background: AppColors.unknownEventBg,
          text: AppColors.unknownEventText,
        );
      case EventPriority.guard:
        return EventColors(
          background: AppColors.guardEventBg,
          text: AppColors.guardEventText,
        );
      case EventPriority.disguard:
        return EventColors(
          background: AppColors.disguardEventBg,
          text: AppColors.disguardEventText,
        );
      case EventPriority.ok:
        return EventColors(
          background: AppColors.okEventBg,
          text: AppColors.okEventText,
        );
      case EventPriority.alarm:
        return EventColors(
          background: AppColors.alarmEventBg,
          text: AppColors.alarmEventText,
        );
      case EventPriority.other:
        return EventColors(
          background: AppColors.otherEventBg,
          text: AppColors.otherEventText,
        );
      default:
        return EventColors(
          background: AppColors.unknownEventBg,
          text: AppColors.unknownEventText,
        );
    }
  }
}

class EventColors {
  final Color background;
  final Color text;

  EventColors({required this.background, required this.text});
}
