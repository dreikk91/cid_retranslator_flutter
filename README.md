# CID Retranslator

**Система моніторингу з Flutter UI та Go backend**

---

## 📦 Структура проекту

```
cid_retranslator_flutter/
├── flutter_app/          # Flutter desktop application (UI)
├── server/               # Go WebSocket server
├── cidparser/            # CID parsing logic
├── queue/                # Message queue
├── main_headless.go      # Go backend entry point
└── .github/              # CI/CD workflows
    └── workflows/        # GitHub Actions
```

## 🚀 Швидкий старт

### Локальна розробка

#### Go Backend
```bash
# Збірка backend
go build -o cid_retranslator_backend main_headless.go

# Запуск
./cid_retranslator_backend
```

#### Flutter App
```bash
cd flutter_app

# Отримати залежності
flutter pub get

# Запустити в debug режимі
flutter run -d windows

# Збірка release
flutter build windows --release
```

### GitHub CI/CD

Проект має автоматичні workflows для збірки на Windows:

- **Development builds:** Автоматично при кожному push
- **Production releases:** При створенні тегу `v*`

📖 **Детальна документація:** [.github/QUICK_START.md](.github/QUICK_START.md)

#### Створення релізу

```bash
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0
```

→ Автоматично створюється GitHub Release з готовим ZIP пакетом!

## 📥 Завантаження готових збірок

### З GitHub Releases (production)
1. Перейдіть у [Releases](../../releases)
2. Завантажте `cid_retranslator_vX.X.X_windows.zip`

### З GitHub Actions (development)
1. Перейдіть у [Actions](../../actions)
2. Виберіть успішний build
3. Завантажте artifacts

## 🏗️ Технології

- **Backend:** Go 1.23
  - WebSocket server (gorilla/websocket)
  - Gorilla Mux router
  - Lumberjack logging
  
- **Frontend:** Flutter 3.38.4
  - Provider state management
  - WebSocket client
  - System tray support (system_tray)
  - Window management (window_manager)
  - Data tables (data_table_2)

- **CI/CD:** GitHub Actions
  - Automatic builds for Windows
  - Artifact storage
  - Release automation

## 📝 Конфігурація

Редагуйте `config.yaml` для налаштування:

```yaml
# Приклад конфігурації
server:
  port: 8080
  host: localhost
# ... інші налаштування
```

## 📚 Документація

- [Quick Start Guide](.github/QUICK_START.md) - Початок роботи з CI/CD
- [Workflows README](.github/workflows/README.md) - Детальний опис workflows
- [Workflow Diagrams](.github/WORKFLOW_DIAGRAMS.md) - Візуальні схеми
- [CI/CD Summary](.github/CICD_SUMMARY.md) - Короткий огляд
- [Changelog](.github/CHANGELOG.md) - Історія змін

### Flutter додаток документація
- [README.md](flutter_app/README.md) - Flutter app README
- [README_BUILD.md](README_BUILD.md) - Інструкції зі збірки
- [README_HEADLESS.md](README_HEADLESS.md) - Headless режим
- [TRAY_GUIDE.md](TRAY_GUIDE.md) - System tray налаштування
- [ICON_README.md](ICON_README.md) - Іконки

## 🔨 Збірка вручну

### Windows (з іконкою)

```batch
REM Встановити rsrc, якщо необхідно
go install github.com/akavel/rsrc@latest

REM Згенерувати ресурси
rsrc -ico icon.ico -manifest multiplepages.exe.manifest -o rsrc.syso

REM Зібрати
go build -o cid_retranslator.exe .
```

## 🧪 Тестування

```bash
# Go тести
go test ./...

# Flutter тести
cd flutter_app
flutter test
```

## 🤝 Розробка

### Вимоги

- Go 1.23+
- Flutter 3.38.4+
- Dart 3.10.3+
- Git

### Workflow

1. Створіть feature branch
2. Зробіть зміни
3. Закомітьте та запуште
4. CI автоматично перевірить build
5. Створіть Pull Request

## 📄 Ліцензія

[Вкажіть вашу ліцензію]

## 👥 Автори

[Ваше ім'я / команда]

---

**Статус CI:** ![Build Status](../../actions/workflows/build-release.yml/badge.svg)
