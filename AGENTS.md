# Orbit — Agent Instructions

## О проекте

Читай описание проекта в файле [PROJECT.md](PROJECT.md).

## Установленный стэк

| Слой | Технология |
|---|---|
| Backend | Ruby on Rails 8.1.3 (монолит) |
| Asset pipeline | Propshaft + importmap-rails |
| Frontend | Hotwire: Turbo + Stimulus |
| CSS | Tailwind CSS (tailwindcss-rails) |
| База данных | PostgreSQL |
| Background jobs | Solid Queue (PostgreSQL-backed, без Redis) |
| Cache | Solid Cache (PostgreSQL-backed, без Redis) |
| Realtime | ActionCable + Solid Cable (без Redis) |
| Аутентификация | Devise |
| Web-сервер | Puma |
| Деплой | Kamal |
| Email (dev) | Letter Opener (превью в браузере) |
| Тесты | Capybara + Selenium |

## Разработка

```bash
bin/dev  # запускает Rails + Tailwind watcher (Procfile.dev)
```
