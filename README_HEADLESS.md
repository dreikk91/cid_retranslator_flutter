# CID Retranslator - Headless Mode

Headless версія CID Retranslator для запуску на Linux/macOS без GUI.

## Запуск

### Linux/macOS (без GUI)

```bash
go run main_headless.go
```

Або скомпілювати:
```bash
go build -o cid_retranslator_headless main_headless.go
./cid_retranslator_headless
```

### Windows (з GUI)

```bash
go run main.go
```

## HTTP API

Коли HTTP API увімкнено (за замовчуванням), сервер слухає на `http://0.0.0.0:8080`

### Endpoints

- `GET /api/ppk` - Список всіх ППК пристроїв
- `GET /api/ppk/{id}/events` - Події конкретного ППК
- `GET /api/events` - Останні 500 подій
- `GET /api/stats` - Поточна статистика
- `GET /api/config` - Конфігурація
- `PUT /api/config` - Оновити конфігурацію
- `GET /ws` - WebSocket для real-time оновлень

### Приклади

```bash
# Отримати список ППК
curl http://localhost:8080/api/ppk

# Отримати події
curl http://localhost:8080/api/events

# Отримати статистику
curl http://localhost:8080/api/stats
```

## Flutter App

Flutter додаток підключається до HTTP API за адресою `http://localhost:8080`

```bash
cd flutter_app
flutter run -d linux  # Linux
flutter run -d windows  # Windows
flutter run -d macos  # macOS
```

## Конфігурація

Редагуйте `config.yaml`:

```yaml
http:
  enabled: true
  host: "0.0.0.0"
  port: "8080"
```

## Зупинка

Натисніть `Ctrl+C` для graceful shutdown.
