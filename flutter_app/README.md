# CID Retranslator - Flutter GUI

Flutter-версія графічного інтерфейсу для CID Retranslator з крос-платформною підтримкою (Windows, Linux, macOS).

## Особливості

✅ **Крос-платформність**: Windows, Linux, macOS  
✅ **Сучасний дизайн**: Windows 11 стиль з Material Design  
✅ **Реальний час**: WebSocket для миттєвих оновлень  
✅ **Повний функціонал**: Всі можливості оригінального Walk GUI  

## Структура проекту

```
flutter_app/
├── lib/
│   ├── main.dart                 - Точка входу
│   ├── models/                   - Моделі даних
│   │   ├── ppk_item.dart        - Модель ППК пристрою
│   │   ├── event_item.dart      - Модель події
│   │   └── stats_data.dart      - Модель статистики
│   ├── services/                 - Сервіси
│   │   ├── api_service.dart     - HTTP REST клієнт
│   │   └── websocket_service.dart - WebSocket клієнт
│   ├── providers/                - State management
│   │   ├── ppk_provider.dart    - Провайдер ППК
│   │   ├── event_provider.dart  - Провайдер подій
│   │   └── stats_provider.dart  - Провайдер статистики
│   ├── screens/                  - Екрани
│   │   ├── main_screen.dart     - Головний екран з табами
│   │   ├── ppk_tab.dart         - Вкладка ППК
│   │   ├── events_tab.dart      - Вкладка подій
│   │   └── settings_tab.dart    - Вкладка налаштувань
│   ├── widgets/                  - Віджети
│   │   └── stats_bar.dart       - Статус-бар
│   └── theme/                    - Тема
│       ├── app_theme.dart       - Налаштування теми
│       └── constants.dart       - Кольори та константи
└── pubspec.yaml                  - Залежності
```

## Вимоги

- **Flutter SDK**: 3.10+ (stable channel)
- **Dart SDK**: 3.0+
- **Go backend**: 1.20+ (для серверної частини)

### Linux
```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

### Windows
- Visual Studio 2022 з C++ Desktop Development

### macOS
- Xcode

## Встановлення

### 1. Встановити Flutter

```bash
# Linux/macOS
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Перевірити встановлення
flutter doctor
```

### 2. Встановити залежності Flutter

```bash
cd /home/apidlypnyi/go_project/cid_retranslator_walk/flutter_app
flutter pub get
```

### 3. Налаштувати Go backend

Переконайтеся, що HTTP сервер увімкнено в `config.yaml`:

```yaml
http:
  enabled: true
  host: 0.0.0.0
  port: "8080"
```

## Запуск

### Режим розробки (Development)

**1. Запустити Go backend:**

```bash
cd /home/apidlypnyi/go_project/cid_retranslator_walk
go run main.go
```

**2. Запустити Flutter додаток:**

```bash
cd flutter_app

# Linux
flutter run -d linux

# Windows
flutter run -d windows

# macOS
flutter run -d macos
```

### Режим Release (Production)

**1. Зібрати Flutter додаток:**

```bash
cd flutter_app

# Linux
flutter build linux --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release
```

**2. Виконавчий файл буде тут:**

- **Linux**: `build/linux/x64/release/bundle/cid_retranslator`
- **Windows**: `build\windows\runner\Release\cid_retranslator.exe`
- **macOS**: `build/macos/Build/Products/Release/cid_retranslator.app`

## Особливості реалізації

### PPK Tab (Вкладка ППК)

- **Таблиця**: №, ППК, Остання подія, Дата/Час
- **Сортування**: По будь-якій колонці
- **Підсвітка таймауту**: Червоний фон якщо немає подій 15+ хвилин
- **Деталі**: Клік по рядку відкриває діалог з інформацією
- **Real-time**: Автоматичне оновлення через WebSocket

### Events Tab (Вкладка подій)

- **Таблиця**: Час, ППК, Код, Тип, Опис, Зона/Група
- **Кольорове кодування** за пріоритетом:
  - Невідомо: Світло-сірий
  - Охорона: Світло-синій
  - Зняття з охорони: Світло-зелений
  - ОК: Світло-жовтий
  - Тривога: Світло-червоний
  - Інше: Білий
- **Ліміт**: Максимум 500 останніх подій
- **Real-time**: Автоматичне оновлення через WebSocket

### Stats Bar (Статус-бар)

- **Статус з'єднання**: ● Зелений/Червоний індикатор
- **Лічильники**:
  - ✓ Прийнято подій
  - ✗ Відхилено подій
  - ↻ Кількість перепідключень
  - ⏱ Час роботи (uptime)
- **Оновлення**: Кожну секунду через WebSocket

## API Endpoints

Flutter додаток з'єднується з Go backend через REST API:

- `GET /api/ppk` - Список всіх ППК
- `GET /api/ppk/:id/events` - Події конкретного ППК
- `GET /api/events` - Останні 500 подій
- `GET /api/stats` - Поточна статистика
- `GET /api/config` - Конфігурація
- `PUT /api/config` - Оновити конфігурацію
- `GET /ws` - WebSocket для real-time оновлень

## WebSocket Messages

Формат повідомлень WebSocket:

```json
{
  "type": "ppk_update | event_update | stats_update",
  "data": { ... }
}
```

## Розробка

### Гарячий перезапуск (Hot Reload)

Під час розробки Flutter підтримує hot reload - зміни в коді застосовуються миттєво:

```bash
flutter run -d linux
# Натисніть 'r' для reload або 'R' для restart
```

### Дебаг

```bash
flutter run --debug -d linux
```

### Аналіз коду

```bash
flutter analyze
```

### Тести

```bash
flutter test
```

## Troubleshooting

### Помилка підключення до backend

Переконайтеся що:
1. Go backend запущений на `localhost:8080`
2. HTTP сервер увімкнено в `config.yaml`
3. Firewall не блокує порт 8080

### Flutter не знаходить пристрій

```bash
# Перевірити доступні пристрої
flutter devices

# Список підключень
flutter doctor -v
```

### Проблеми з WebSocket

Перевірте консоль Flutter на помилки з'єднання:
```bash
flutter run -d linux --verbose
```

## Що далі

- [ ] Імплементувати Settings tab (форма конфігурації)
- [ ] Додати PPK Details dialog з таблицею подій
- [ ] Імплементувати System Tray support
- [ ] Додати локалізацію (ua/en)
- [ ] Написати тести

## Ліцензія

Same as main project

## Автор

Migrated from Walk GUI to Flutter
