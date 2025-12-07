import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cid_retranslator/theme/constants.dart';
import 'package:cid_retranslator/providers/config_provider.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigProvider>(
      builder: (context, configProvider, child) {
        if (configProvider.isLoading && configProvider.config == null) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.win11Accent),
          );
        }

        if (configProvider.error != null && configProvider.config == null) {
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
                  'Помилка завантаження налаштувань',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.win11TextPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  configProvider.error!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.win11TextSecondary,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => configProvider.loadConfig(),
                  child: Text('Повторити спробу'),
                ),
              ],
            ),
          );
        }

        final config = configProvider.config;
        if (config == null) {
          return Center(child: Text('Немає даних'));
        }

        return Container(
          color: AppColors.win11Background,
          child: Column(
            children: [
              // Header с кнопками
              Container(
                color: AppColors.win11CardBackground,
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Налаштування додатку',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.win11TextPrimary,
                      ),
                    ),
                    Spacer(),
                    if (configProvider.hasChanges)
                      TextButton.icon(
                        onPressed: () => configProvider.resetConfig(),
                        icon: Icon(Icons.refresh, size: 18),
                        label: Text('Скасувати'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.win11TextSecondary,
                        ),
                      ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: configProvider.hasChanges
                          ? () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final success = await configProvider.saveConfig();
                              if (success) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Налаштування збережено'),
                                    backgroundColor: AppColors.win11Success,
                                  ),
                                );
                              } else {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Помилка збереження: ${configProvider.error}',
                                    ),
                                    backgroundColor: AppColors.win11Error,
                                  ),
                                );
                              }
                            }
                          : null,
                      icon: Icon(Icons.save, size: 18),
                      label: Text('Зберегти'),
                    ),
                  ],
                ),
              ),

              // Scrollable form
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildServerSection(context, config, configProvider),
                      SizedBox(height: 16),
                      _buildClientSection(context, config, configProvider),
                      SizedBox(height: 16),
                      _buildQueueSection(context, config, configProvider),
                      SizedBox(height: 16),
                      _buildLoggingSection(context, config, configProvider),
                      SizedBox(height: 16),
                      _buildCIDRulesSection(context, config, configProvider),
                      SizedBox(height: 16),
                      _buildMonitoringSection(context, config, configProvider),
                      SizedBox(height: 16),
                      _buildUISection(context, config, configProvider),
                      SizedBox(height: 16),
                      _buildHTTPSection(context, config, configProvider),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServerSection(
    BuildContext context,
    config,
    ConfigProvider provider,
  ) {
    return _buildCard(
      title: 'Сервер (Вхідні підключення)',
      children: [
        _buildTextField(
          label: 'Хост',
          value: config.server.host,
          onChanged: (value) {
            config.server.host = value;
            provider.markChanged();
          },
        ),
        _buildTextField(
          label: 'Порт',
          value: config.server.port,
          onChanged: (value) {
            config.server.port = value;
            provider.markChanged();
          },
        ),
      ],
    );
  }

  Widget _buildClientSection(
    BuildContext context,
    config,
    ConfigProvider provider,
  ) {
    return _buildCard(
      title: 'Клієнт (Вихідне підключення)',
      children: [
        _buildTextField(
          label: 'Хост',
          value: config.client.host,
          onChanged: (value) {
            config.client.host = value;
            provider.markChanged();
          },
        ),
        _buildTextField(
          label: 'Порт',
          value: config.client.port,
          onChanged: (value) {
            config.client.port = value;
            provider.markChanged();
          },
        ),
        _buildTextField(
          label: 'Початкова затримка перепідключення (напр. 1s, 5s)',
          value: config.client.reconnectInitial,
          onChanged: (value) {
            config.client.reconnectInitial = value;
            provider.markChanged();
          },
        ),
        _buildTextField(
          label: 'Максимальна затримка перепідключення (напр. 60s, 5m)',
          value: config.client.reconnectMax,
          onChanged: (value) {
            config.client.reconnectMax = value;
            provider.markChanged();
          },
        ),
      ],
    );
  }

  Widget _buildQueueSection(
    BuildContext context,
    config,
    ConfigProvider provider,
  ) {
    return _buildCard(
      title: 'Черга',
      children: [
        _buildNumberField(
          label: 'Розмір буфера',
          value: config.queue.bufferSize,
          onChanged: (value) {
            config.queue.bufferSize = value ?? 100;
            provider.markChanged();
          },
        ),
      ],
    );
  }

  Widget _buildLoggingSection(
    BuildContext context,
    config,
    ConfigProvider provider,
  ) {
    return _buildCard(
      title: 'Логування',
      children: [
        _buildTextField(
          label: 'Ім\'я файлу',
          value: config.logging.filename,
          onChanged: (value) {
            config.logging.filename = value;
            provider.markChanged();
          },
        ),
        _buildNumberField(
          label: 'Максимальний розмір (MB)',
          value: config.logging.maxSize,
          onChanged: (value) {
            config.logging.maxSize = value ?? 10;
            provider.markChanged();
          },
        ),
        _buildNumberField(
          label: 'Кількість backup файлів',
          value: config.logging.maxBackups,
          onChanged: (value) {
            config.logging.maxBackups = value ?? 5;
            provider.markChanged();
          },
        ),
        _buildNumberField(
          label: 'Максимальний вік (днів)',
          value: config.logging.maxAge,
          onChanged: (value) {
            config.logging.maxAge = value ?? 28;
            provider.markChanged();
          },
        ),
        _buildCheckbox(
          label: 'Стиснення архівів',
          value: config.logging.compress,
          onChanged: (value) {
            config.logging.compress = value ?? false;
            provider.markChanged();
          },
        ),
        _buildDropdown(
          label: 'Рівень логування',
          value: config.logging.level,
          items: ['DEBUG', 'INFO', 'WARN', 'ERROR'],
          onChanged: (value) {
            if (value != null) {
              config.logging.level = value;
              provider.markChanged();
            }
          },
        ),
      ],
    );
  }

  Widget _buildCIDRulesSection(
    BuildContext context,
    config,
    ConfigProvider provider,
  ) {
    return _buildCard(
      title: 'Правила CID',
      children: [
        _buildTextField(
          label: 'Обов\'язковий префікс',
          value: config.cidRules.requiredPrefix,
          onChanged: (value) {
            config.cidRules.requiredPrefix = value;
            provider.markChanged();
          },
        ),
        _buildNumberField(
          label: 'Валідна довжина',
          value: config.cidRules.validLength,
          onChanged: (value) {
            config.cidRules.validLength = value ?? 21;
            provider.markChanged();
          },
        ),
        _buildNumberField(
          label: 'Зсув номера account',
          value: config.cidRules.accNumOffset,
          onChanged: (value) {
            config.cidRules.accNumOffset = value ?? 2100;
            provider.markChanged();
          },
        ),
        _buildNumberField(
          label: 'Додавання до номера account',
          value: config.cidRules.accNumAdd,
          onChanged: (value) {
            config.cidRules.accNumAdd = value ?? 2100;
            provider.markChanged();
          },
        ),
      ],
    );
  }

  Widget _buildMonitoringSection(
    BuildContext context,
    config,
    ConfigProvider provider,
  ) {
    return _buildCard(
      title: 'Моніторинг',
      children: [
        _buildTextField(
          label: 'Таймаут ППК (напр. 15m, 1h)',
          value: config.monitoring.ppkTimeout,
          onChanged: (value) {
            config.monitoring.ppkTimeout = value;
            provider.markChanged();
          },
        ),
      ],
    );
  }

  Widget _buildUISection(
    BuildContext context,
    config,
    ConfigProvider provider,
  ) {
    return _buildCard(
      title: 'Інтерфейс',
      children: [
        _buildCheckbox(
          label: 'Запускати згорнутим',
          value: config.ui.startMinimized,
          onChanged: (value) {
            config.ui.startMinimized = value ?? false;
            provider.markChanged();
          },
        ),
        _buildCheckbox(
          label: 'Згортати в трей',
          value: config.ui.minimizeToTray,
          onChanged: (value) {
            config.ui.minimizeToTray = value ?? false;
            provider.markChanged();
          },
        ),
        _buildCheckbox(
          label: 'Закривати в трей',
          value: config.ui.closeToTray,
          onChanged: (value) {
            config.ui.closeToTray = value ?? false;
            provider.markChanged();
          },
        ),
      ],
    );
  }

  Widget _buildHTTPSection(
    BuildContext context,
    config,
    ConfigProvider provider,
  ) {
    return _buildCard(
      title: 'HTTP API',
      children: [
        _buildCheckbox(
          label: 'Увімкнути HTTP API',
          value: config.http.enabled,
          onChanged: (value) {
            config.http.enabled = value ?? true;
            provider.markChanged();
          },
        ),
        _buildTextField(
          label: 'Хост',
          value: config.http.host,
          onChanged: (value) {
            config.http.host = value;
            provider.markChanged();
          },
        ),
        _buildTextField(
          label: 'Порт',
          value: config.http.port,
          onChanged: (value) {
            config.http.port = value;
            provider.markChanged();
          },
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      color: AppColors.win11CardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppColors.win11Border),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.win11TextPrimary,
              ),
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: AppColors.win11TextSecondary),
          ),
          SizedBox(height: 4),
          TextFormField(
            initialValue: value,
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.win11Background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: AppColors.win11Border),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required Function(int?) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: AppColors.win11TextSecondary),
          ),
          SizedBox(height: 4),
          TextFormField(
            initialValue: value.toString(),
            keyboardType: TextInputType.number,
            onChanged: (val) => onChanged(int.tryParse(val)),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.win11Background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: AppColors.win11Border),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        title: Text(label, style: TextStyle(fontSize: 14)),
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        activeColor: AppColors.win11Accent,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: AppColors.win11TextSecondary),
          ),
          SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: value,
            items: items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.win11Background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: AppColors.win11Border),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: TextStyle(fontSize: 14, color: AppColors.win11TextPrimary),
          ),
        ],
      ),
    );
  }
}
