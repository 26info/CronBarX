# CronBarX — macOS Status Bar Manager

<div align="center">

🇷🇺 **Легковесная альтернатива xbar с поддержкой плагинов**  
🇺🇸 **Lightweight xbar alternative with plugin support**

[![Swift](https://img.shields.io/badge/Swift-5.0+-orange?logo=swift)](https://swift.org/)
[![macOS](https://img.shields.io/badge/macOS-10.13+-blue?logo=apple)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Memory](https://img.shields.io/badge/Memory-~20_MB-success.svg)]()
[![Downloads](https://img.shields.io/github/downloads/26info/CronBarX/total.svg)](https://github.com/26info/CronBarX/releases)

[Русский](#русский) • [English](#english)

</div>

---

## Русский

🚀 **Легковесный менеджер для статус-бара macOS с поддержкой множества инстансов и плагинов**

### ✨ Особенности

— **Мульти-инстансы** — запускайте несколько скриптов одновременно  
— **Менеджер плагинов** — устанавливайте плагины прямо из GitHub репозитория  
— **Автообновление** — автоматическое обновление вывода скриптов  
— **Низкое потребление памяти** — ~20 МБ против 40+ МБ у xbar  
— **Нативный интерфейс** — полная интеграция с macOS  
— **Поддержка bash/zsh** — работает с любыми shell-скриптами  

### 📊 Сравнение с xbar

| Характеристика | **CronBarX** | **xbar** |
|----------------|--------------|----------|
| Потребление памяти | ~20 МБ | ~40-50 МБ |
| Производительность | Высокая | Средняя |
| Мульти-инстансы | ✅ Встроенная поддержка | ❌ Только через плагины |
| Менеджер плагинов | ✅ Встроенный | ✅ Есть |
| Нативность | Полная интеграция с macOS | Electron-приложение |
| Простота использования | Интуитивный интерфейс | Аналогично |

### 🚀 Быстрый старт

1. Запустите CronBarX  
2. Нажмите на иконку ⚙️ в статус-баре  
3. Выберите «Создать новый инстанс»  
4. Выберите ваш shell-скрипт  
5. Готово! Скрипт появится в статус-баре  

### 📝 Формат скриптов

CronBarX поддерживает тот же формат, что и xbar:

```bash
#!/bin/bash
echo "🔄 $(date '+%H:%M:%S')"
echo "---"
echo "Системная информация | bash='system_profiler'"
echo "Обновить | refresh=true"
```

---

## English

🚀 **Lightweight macOS status bar manager with multi-instance and plugin support**

### ✨ Features

— **Multi-instances** — run multiple scripts simultaneously  
— **Plugin manager** — install plugins directly from GitHub repository  
— **Auto-update** — automatic script output refresh  
— **Low memory usage** — ~20 MB vs 40+ MB in xbar  
— **Native interface** — full integration with macOS  
— **Bash/zsh support** — works with any shell scripts  

### 📊 Comparison with xbar

| Feature | **CronBarX** | **xbar** |
|---------|--------------|----------|
| Memory usage | ~20 MB | ~40-50 MB |
| Performance | High | Medium |
| Multi-instances | ✅ Built-in support | ❌ Plugins only |
| Plugin manager | ✅ Built-in | ✅ Available |
| Nativeness | Full macOS integration | Electron app |
| Ease of use | Intuitive interface | Similar |

### 🚀 Quick Start

1. Launch CronBarX  
2. Click the ⚙️ icon in the status bar  
3. Select "Create new instance"  
4. Choose your shell script  
5. Done! The script will appear in the status bar  

### 📝 Script Format

CronBarX supports the same format as xbar:

```bash
#!/bin/bash
echo "🔄 $(date '+%H:%M:%S')"
echo "---"
echo "System Information | bash='system_profiler'"
echo "Refresh | refresh=true"
