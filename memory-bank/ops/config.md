---
title: Configuration Guide
doc_kind: engineering
doc_function: canonical
purpose: Каноничное описание ownership-модели конфигурации Orbit. Читать при изменениях env contract, production runtime и deployment settings.
derived_from:
  - ../dna/governance.md
status: active
audience: humans_and_agents
---

# Configuration Guide

Этот документ не перечисляет все возможные настройки Rails подряд. Его задача - зафиксировать, где в Orbit живет canonical schema конфигурации и какие runtime/env contracts реально важны для разработки, CI и будущего deploy.

## Configuration Architecture

Orbit использует framework-native конфигурацию Rails с несколькими owner-слоями:

1. `config/database.yml` - source of truth для database topology в `development`, `test` и `production`, включая отдельные production databases для `primary`, `cache`, `queue` и `cable`.
2. `config/environments/production.rb` - production runtime defaults: `solid_cache`, `solid_queue`, logging в STDOUT, health endpoint `/up`, mailer defaults и другие non-secret runtime policy.
3. `config/deploy.yml` - planned deploy contract через Kamal: image/build settings, volume, aliases и clear/secret env vars для контейнера.
4. `.envrc` - локальный слой загрузки `.env` и `.env.local`, плюс автоматический выбор `PORT` через `port-selector`.
5. `.kamal/secrets` и Rails credentials - секретные значения для deploy/runtime; реальные значения не должны дублироваться в документации.

### File Layout

```text
.envrc
.env
.env.local
config/
├── database.yml
├── deploy.yml
├── environments/
│   └── production.rb
└── ...
.kamal/
└── secrets
```

### Ownership Rules

Каноничные правила ownership:

1. Если меняется topology БД или connection model, сначала обновляется `config/database.yml`.
2. Если меняется production runtime behavior приложения, сначала обновляется `config/environments/production.rb`.
3. Если изменение относится к контейнерному deploy, переменным контейнера, alias-командам или volume, owner - `config/deploy.yml`.
4. Если меняется локальный способ определения `PORT` или загрузки env-файлов, owner - `.envrc`.
5. Секреты документируются только через место хранения и выдачи, но не через реальные значения.

```ruby
ENV.fetch("PORT", 3000)
ENV.fetch("RAILS_LOG_LEVEL", "info")
ENV["ORBIT_DATABASE_PASSWORD"]
```

## Naming Convention For Env Vars

У Orbit сейчас нет собственного project-wide префикса вроде `APP_`. Проект использует смесь:

- framework-native имен (`PORT`, `DATABASE_URL`, `RAILS_MAX_THREADS`, `RAILS_MASTER_KEY`, `RAILS_LOG_LEVEL`);
- domain/project-specific имен там, где это уже зафиксировано Rails config (`ORBIT_DATABASE_PASSWORD`).

Rules:

- не вводить новый custom prefix без явной причины и синхронного обновления этой документации;
- для стандартных Rails/Kamal переменных сохранять их исходные имена, а не оборачивать в альтернативные алиасы;
- boolean-флаги документировать в том виде, в каком они реально читаются кодом или deploy-конфигом, например `SOLID_QUEUE_IN_PUMA`;
- секреты должны иметь говорящее имя и храниться вне репозитория даже тогда, когда их название упомянуто в конфиге.

## Documenting Important Variables

Ниже перечислены переменные, которые формируют текущий runtime contract Orbit.

| Variable | Description | Default | Owner |
| --- | --- | --- | --- |
| `PORT` | Порт локального Puma / `bin/dev` | `3000`, если `.envrc` не выставил другой | local runtime |
| `RAILS_MAX_THREADS` | Размер thread pool Puma и pool Active Record | `3` в Puma, `5` в `database.yml` fallback | platform |
| `DATABASE_URL` | Переопределение подключения к БД; используется в CI и может использоваться локально | none | platform / CI |
| `ORBIT_DATABASE_PASSWORD` | Пароль для production database user `orbit` | none | production platform |
| `RAILS_MASTER_KEY` | Доступ к Rails credentials в deploy/runtime | none | production platform |
| `SOLID_QUEUE_IN_PUMA` | Запуск Solid Queue supervisor внутри Puma в single-server deploy | `true` в текущем `deploy.yml` | platform |
| `WEB_CONCURRENCY` | Количество Puma workers при container deploy | unset | platform |
| `RAILS_LOG_LEVEL` | Уровень логирования production runtime | `info` | platform |

## Secrets

- Никогда не вставляй реальные значения секретов в репозиторий или в `memory-bank/`.
- Для локальной разработки чувствительные переменные должны приходить из `.env.local` или другого локального невключаемого файла; `.envrc` только подхватывает их.
- Для Kamal deploy секреты приходят из `.kamal/secrets`; repo уже предполагает этот путь, но не документирует реальные значения.
- Дополнительные интеграционные секреты Rails, например SMTP, должны храниться в Rails credentials, если эта интеграция активирована.

## Adoption Checklist

- [x] описан schema-owner конфигурации
- [x] задокументирована текущая naming convention
- [x] перечислены ключевые runtime/env contracts
- [x] описан secret handling
- [x] удалены шаблонные ссылки на несуществующие downstream-справочники
