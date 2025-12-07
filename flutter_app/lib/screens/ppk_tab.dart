import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cid_retranslator/theme/constants.dart';
import 'package:cid_retranslator/models/ppk_item.dart';
import 'package:cid_retranslator/models/event_item.dart';
import 'package:cid_retranslator/providers/ppk_provider.dart';

class PPKTab extends StatefulWidget {
  const PPKTab({super.key});

  @override
  State<PPKTab> createState() => _PPKTabState();
}

class _PPKTabState extends State<PPKTab> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final DateFormat _dateFormat = DateFormat('HH:mm:ss yyyy-MM-dd');

  // PPK timeout duration (15 minutes)
  final Duration ppkTimeout = Duration(minutes: 15);

  @override
  Widget build(BuildContext context) {
    return Consumer<PPKProvider>(
      builder: (context, ppkProvider, child) {
        if (ppkProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.win11Accent),
          );
        }

        if (ppkProvider.error != null) {
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
                  'Помилка завантаження даних',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.win11TextPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  ppkProvider.error!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.win11TextSecondary,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ppkProvider.loadPPKList(),
                  child: Text('Повторити спробу'),
                ),
              ],
            ),
          );
        }

        if (ppkProvider.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.devices,
                  size: 64,
                  color: AppColors.win11TextSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'Немає даних про ППК',
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
            minWidth: 600,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            headingRowColor: WidgetStateProperty.all(
              AppColors.win11CardBackground,
            ),
            dataRowColor: WidgetStateProperty.resolveWith<Color>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.win11AccentLight;
              }
              return AppColors.win11CardBackground;
            }),
            columns: [
              DataColumn2(
                label: Text('№', style: TextStyle(fontWeight: FontWeight.bold)),
                size: ColumnSize.S,
                onSort: (columnIndex, ascending) {
                  _sort('number', columnIndex, ascending, ppkProvider);
                },
              ),
              DataColumn2(
                label: Text(
                  'ППК',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                size: ColumnSize.M,
                onSort: (columnIndex, ascending) {
                  _sort('name', columnIndex, ascending, ppkProvider);
                },
              ),
              DataColumn2(
                label: Text(
                  'Остання подія',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                size: ColumnSize.L,
                onSort: (columnIndex, ascending) {
                  _sort('event', columnIndex, ascending, ppkProvider);
                },
              ),
              DataColumn2(
                label: Text(
                  'Дата/Час',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                size: ColumnSize.L,
                onSort: (columnIndex, ascending) {
                  _sort('date', columnIndex, ascending, ppkProvider);
                },
              ),
            ],
            rows: ppkProvider.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isTimeout = item.isTimedOut();

              return DataRow2(
                color: WidgetStateProperty.resolveWith<Color>((
                  Set<WidgetState> states,
                ) {
                  if (isTimeout) {
                    return AppColors.ppkTimeoutBg;
                  }
                  if (index % 2 == 0) {
                    return AppColors.ppkGray;
                  }
                  return AppColors.win11CardBackground;
                }),
                cells: [
                  DataCell(
                    Text(
                      item.number.toString(),
                      style: TextStyle(
                        color: isTimeout
                            ? AppColors.ppkTimeoutText
                            : AppColors.ppkBlack,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      item.name ?? '',
                      style: TextStyle(
                        color: isTimeout
                            ? AppColors.ppkTimeoutText
                            : AppColors.ppkBlack,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      item.event ?? '',
                      style: TextStyle(
                        color: isTimeout
                            ? AppColors.ppkTimeoutText
                            : AppColors.ppkBlack,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      _dateFormat.format(item.date ?? DateTime(1970)),
                      style: TextStyle(
                        color: isTimeout
                            ? AppColors.ppkTimeoutText
                            : AppColors.ppkBlack,
                      ),
                    ),
                  ),
                ],
                onTap: () {
                  // TODO: Show PPK details dialog
                  _showPPKDetails(context, item);
                },
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
    PPKProvider provider,
  ) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    provider.sortItems(column, ascending);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Помилка':
        return AppColors.colorRed;
      case 'Попередження':
        return AppColors.colorOrange;
      case 'Активний':
        return AppColors.colorGreen;
      default:
        return AppColors.ppkBlack;
    }
  }

  void _showPPKDetails(BuildContext context, PPKItem item) async {
    // Show loading dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: AppColors.win11Accent),
      ),
    );

    try {
      // Fetch events for this PPK
      final apiService = Provider.of<PPKProvider>(context, listen: false);
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/ppk/${item.number}/events'),
      );

      // Close loading dialog
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final events = data.map((e) => EventItem.fromJson(e)).toList();

        // Show events dialog
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Container(
              width: 900,
              height: 600,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(Icons.devices, color: AppColors.win11Accent),
                      SizedBox(width: 8),
                      Text(
                        'ППК ${item.number} - ${item.name ?? "Невідомо"}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Divider(),

                  // Info row
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        _buildInfoChip(
                          'Остання подія',
                          item.event ?? 'Немає даних',
                        ),
                        SizedBox(width: 16),
                        _buildInfoChip(
                          'Час',
                          item.date != null
                              ? _dateFormat.format(item.date!)
                              : 'Невідомо',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 8),
                  Text(
                    'Історія подій (${events.length} останніх):',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  // Events table
                  Expanded(
                    child: events.isEmpty
                        ? Center(
                            child: Text(
                              'Немає подій для цього ППК',
                              style: TextStyle(
                                color: AppColors.win11TextSecondary,
                              ),
                            ),
                          )
                        : DataTable2(
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 600,
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
                              ),
                              DataColumn2(
                                label: Text(
                                  'Код',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                size: ColumnSize.S,
                              ),
                              DataColumn2(
                                label: Text(
                                  'Тип',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                size: ColumnSize.M,
                              ),
                              DataColumn2(
                                label: Text(
                                  'Опис',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                size: ColumnSize.L,
                              ),
                            ],
                            rows: events.map((event) {
                              return DataRow2(
                                cells: [
                                  DataCell(
                                    Text(
                                      _dateFormat.format(
                                        event.time ?? DateTime(1970),
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(event.code ?? '')),
                                  DataCell(Text(event.type ?? '')),
                                  DataCell(Text(event.desc ?? '')),
                                ],
                              );
                            }).toList(),
                          ),
                  ),

                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Закрити'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Помилка'),
            content: Text('Не вдалося завантажити події'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      Navigator.pop(context);

      // Show error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Помилка'),
          content: Text('Помилка підключення: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.win11CardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.win11Border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.win11TextSecondary,
            ),
          ),
          Text(value, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
