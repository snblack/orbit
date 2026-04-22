---
title: Development Environment
doc_kind: engineering
doc_function: canonical
purpose: Каноничное описание локальной разработки Orbit. Читать при setup рабочей среды, запуске Rails, тестов и batch-операций.
derived_from:
  - ../dna/governance.md
status: active
audience: humans_and_agents
---

# Development Environment

Этот документ фиксирует реальный локальный workflow Orbit. Для bootstrap общего toolchain и CLI-авторизации сначала смотри [`../../SETUP.md`](../../SETUP.md), а здесь используй только project-specific entrypoints.

## Setup

Минимальные требования:

- Ruby `3.4.8`;
- PostgreSQL;
- `direnv` для загрузки `.envrc`, `.env` и `.env.local`.

Каноничная последовательность:

```bash
direnv allow
bundle install
bin/setup --skip-server
```

Что делает `bin/setup` в текущем репозитории:

1. проверяет и устанавливает gems;
2. выполняет `bin/rails db:prepare`;
3. очищает `log/` и `tmp/`;
4. при запуске без `--skip-server` передает управление в `bin/dev`.

Если нужно пересоздать локальную БД с seed-данными, используй:

```bash
bin/setup --reset --skip-server
```

## Daily Commands

Ниже перечислены реальные команды, которые должен знать агент и разработчик.

```bash
bin/dev
bin/rails server
bin/rails db:prepare
bin/rails test
bundle exec rspec
bin/rails test:system
bin/rubocop
bin/brakeman
bin/bundler-audit
bin/rails matching:run
```

Пояснения:

- `bin/dev` поднимает локальный web-процесс Rails и watcher для Tailwind через `Procfile.dev`;
- `bin/rails server` полезен, если нужен только web-server без CSS watcher;
- `bin/rails matching:run` запускает batch matching вне HTTP path и является каноничной операционной командой для формирования `Pod`.

## Browser Testing

Orbit - server-rendered Rails application с Hotwire, поэтому browser verification идет против локального Rails server.

Каноничные правила:

1. Сначала читать `PORT` из окружения.
2. `PORT` приходит из `.envrc`, который подхватывает `.env` и `.env.local`; если значение не задано, `.envrc` пытается выбрать свободный порт через `port-selector`.
3. Если окружение не экспортировало `PORT`, Puma и `bin/dev` используют default `3000`.
4. Не сканировать порты вручную без явного запроса пользователя.

Практический URL:

```text
http://localhost:${PORT}
```

Если `PORT` не задан, используй `http://localhost:3000`.

## Database And Services

Что важно для локальной работы Orbit сегодня:

- обязательная внешняя зависимость одна: PostgreSQL;
- отдельный локальный Redis не требуется и в репозитории не задокументирован как обязательный сервис;
- `bin/rails db:prepare` подготавливает локальную схему, а `bin/setup --reset` помогает полностью пересоздать локальную БД;
- seed-данные загружаются стандартным Rails-путем при `db:seed` и `db:reset`;
- batch matching нужно запускать вручную через `bin/rails matching:run`, потому что это отдельная операционная команда, а не request-time логика;
- в `Procfile.dev` Tailwind watcher вынесен в отдельный процесс, поэтому для работы с UI по умолчанию предпочитай `bin/dev`, а не одиночный `bin/rails server`.

## Adoption Checklist

- [x] указаны реальные setup-команды
- [x] указаны реальные test/lint/security commands
- [x] документирован способ определения локального URL
- [x] перечислены локальные зависимости и сервисы
- [x] удалены нерелевантные шаблонные примеры
