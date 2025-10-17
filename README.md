# CronBarX — macOS Status Bar Manager

<div align="center">

🇺🇸 **Lightweight xbar alternative with plugin support**  
🇷🇺 **Легковесная альтернатива xbar с поддержкой плагинов**  

[![macOS](https://img.shields.io/badge/macOS-10.13+-blue?logo=apple)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Memory](https://img.shields.io/badge/Memory-~20_MB-success.svg)]()
[![Downloads](https://img.shields.io/github/downloads/26info/CronBarX/total.svg)](https://github.com/26info/CronBarX/releases)

![single-8022263-0=](https://github.com/user-attachments/assets/454d5e15-f1ba-46a4-80fa-3b43a114146c)

 [English](#english) • [Русский](#русский)

</div>

---

## English

🚀 **Lightweight macOS status bar manager with multi-instance and plugin support**

### ✨ Features

— **Multi-instances** — run multiple scripts simultaneously  
— **Plugin manager** — install plugins directly from GitHub repository  
— **Auto-update** — automatic script output refresh  
— **Low memory usage** — ~20 MB  
— **Native interface** — full integration with macOS  
— **Bash/zsh support** — works with any shell scripts  

### 📊 Comparison with xbar

| Feature | **CronBarX** | **xbar** |
|---------|--------------|----------|
| **Technology** | Native macOS (Swift/Objective-C) | Native macOS (Swift) |
| **Performance** | Optimized for low resource usage | Native performance |
| **Architecture** | Multi-instance support | Single app with plugin system |
| **Plugin Manager** | ✅ Built-in GUI | ✅ File-based management |
| **macOS Integration** | ✅ Full native integration | ✅ Full native integration |
| **Plugin Languages** | Bash, Python, Ruby, JavaScript, etc. | Bash, Python, Ruby, JavaScript, etc. |
| **Ease of Use** | Intuitive interface | Established ecosystem |
| **Plugin Repository** | Built-in manager | Community plugins |

### 🚀 Quick Start

1. Download the latest version from the [Releases section](https://github.com/26info/CronBarX/releases)
2. Launch CronBarX  
3. Click the ⚙️ icon in the status bar  
4. Select "Create new instance"  
5. Choose your shell script  
6. Done! The script will appear in the status bar  

### 📝 Script Format

CronBarX supports the same format as xbar:

```bash
#!/bin/bash
echo "🔄 $(date '+%H:%M:%S')"
echo "---"
echo "Open Terminal | shell=open -a Terminal"
echo "Refresh | refresh=true"
```

### 🔧 Debugging & Logs

CronBarX includes comprehensive file logging for easy troubleshooting:

**Log file location:**

```
~/Library/Application Support/CronBarX/cronbarx.log
```

---

<div align="center">

**Program Screenshot / Скриншот работы программы**

![CronBarX_screen](https://github.com/user-attachments/assets/723ad0ec-0c84-4ea5-89ac-7d7520df99b3)

</div>

---

## Русский

🚀 **Легковесный менеджер для статус-бара macOS с поддержкой множества инстансов и плагинов**

### ✨ Особенности

— **Мульти-инстансы** — запускайте несколько скриптов одновременно  
— **Менеджер плагинов** — устанавливайте плагины прямо из GitHub репозитория  
— **Автообновление** — автоматическое обновление вывода скриптов  
— **Низкое потребление памяти** — ~20 МБ  
— **Нативный интерфейс** — полная интеграция с macOS  
— **Поддержка bash/zsh** — работает с любыми shell-скриптами  

### 📊 Сравнение с xbar

| Функция | **CronBarX** | **xbar** |
|---------|--------------|----------|
| **Технология** | Нативное macOS (Swift/Objective-C) | Нативное macOS (Swift) |
| **Производительность** | Оптимизирована для низкого потребления ресурсов | Нативная производительность |
| **Архитектура** | Поддержка нескольких экземпляров | Одиночное приложение с системой плагинов |
| **Менеджер плагинов** | ✅ Встроенный графический интерфейс | ✅ Файловое управление |
| **Интеграция с macOS** | ✅ Полная нативная интеграция | ✅ Полная нативная интеграция |
| **Языки плагинов** | Bash, Python, Ruby, JavaScript и др. | Bash, Python, Ruby, JavaScript и др. |
| **Удобство использования** | Интуитивный интерфейс | Развитая экосистема |
| **Репозиторий плагинов** | Встроенный менеджер | Сообщество плагинов |

### 🚀 Быстрый старт

1. Скачайте последнюю версию из [раздела Releases](https://github.com/26info/CronBarX/releases)
2. Запустите CronBarX  
3. Нажмите на иконку ⚙️ в статус-баре  
4. Выберите «Создать новый инстанс»  
5. Выберите ваш shell-скрипт  
6. Готово! Скрипт появится в статус-баре  

### 📝 Формат скриптов

CronBarX поддерживает тот же формат, что и xbar:

```bash
#!/bin/bash
echo "🔄 $(date '+%H:%M:%S')"
echo "---"
echo "Открыть Терминал | shell=open -a Terminal"
echo "Обновить | refresh=true"
```
### 🔧 Отладка и логи

CronBarX включает подробное файловое логирование для удобной диагностики проблем:

**Расположение файла лога:**

```
~/Library/Application Support/CronBarX/cronbarx.log
```

