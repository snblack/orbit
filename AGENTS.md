# Orbit — Agent Instructions

## Проект

Orbit — веб-приложение для создания дружеских связей через малые группы (Pods). Пользователи проходят онбординг, алгоритм собирает группы по 5 человек, группа проходит 12-недельную программу сближения.

## Стэк

| Слой | Технология |
|---|---|
| Backend | Ruby on Rails 8.1.3 (монолит) |
| Frontend | Hotwire: Turbo + Stimulus |
| CSS | Tailwind CSS |
| База данных | PostgreSQL + pgvector (для AI-embeddings) |
| Realtime | ActionCable + Solid Cable (без Redis) |
| Background jobs | Sidekiq + Redis |
| Cache | Solid Cache (PostgreSQL-backed, без Redis) |
| Аутентификация | Devise |
| Платежи | Stripe + Pay gem |
| Email | ActionMailer + Resend |
| Файлы | ActiveStorage + Cloudflare R2 |
| Геолокация | Geocoder gem |
| AI | OpenAI API (ruby-openai gem) |
| Vector search | neighbor gem (pgvector + ActiveRecord) |

## Архитектура

Монолитное Rails-приложение. Нет отдельного SPA. Фронтенд строится на ERB + Turbo Frames/Streams + Stimulus. ActionCable обрабатывает realtime чат.

### Основные модели

- `User` — профиль, Devise auth, embedding вектор
- `Pod` — группа из 5 человек, текущая фаза (1–12 неделя)
- `PodMembership` — принадлежность User к Pod, роль (member/connector)
- `Activity` — активность, предложенная внутри Pod
- `ActivityVote` — голос участника за активность
- `Message` — сообщение в групповом чате Pod

### Ключевые сервисы

- `PodMatcher` — алгоритм матчинга (Phase 1: взвешенный на Ruby, Phase 3: OpenAI embeddings + pgvector)
- `ActivitySuggester` — GPT-4o-mini генерирует идеи активностей для группы
- `PodPhaseJob` — Sidekiq-джоб, еженедельно переводит Pod через программу

## Конвенции

- Использовать **Turbo Frames** для частичных обновлений страниц без перезагрузки
- Использовать **Turbo Streams** для broadcast в реальном времени (чат, статусы)
- **Stimulus** только там, где Turbo не справляется (сложные UI-взаимодействия)
- Фоновые задачи — через **ActiveJob + Sidekiq**, не через inline processing
- AI-вызовы всегда в сервисных объектах (`app/services/`), не в моделях/контроллерах
- Геолокация хранится как `latitude` + `longitude` в модели User, район — как строка

## Деплой

Render.com или Fly.io. Один репозиторий, один деплой. Redis и PostgreSQL как managed services.

## Разработка

```bash
bin/dev          # запускает Rails + Tailwind watcher (Procfile.dev)
bundle exec sidekiq  # фоновые джобы (отдельный процесс)
```
