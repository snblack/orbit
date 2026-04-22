---
title: Stages And Non-Local Environments
doc_kind: engineering
doc_function: canonical
purpose: Каноничное описание non-local execution paths Orbit. Читать при работе с CI, подготовке Kamal deploy и уточнении прав доступа к runtime-окружениям.
derived_from:
  - ../dna/governance.md
status: active
audience: humans_and_agents
---

# Stages And Non-Local Environments

Orbit уже имеет подтвержденный non-local execution path через GitHub Actions CI, а production-like deploy path пока только частично подготовлен через Kamal. Этот документ должен честно различать:

- то, что существует и подтверждено в репозитории;
- то, что запланировано, но еще не инстанцировано в виде реальных hostnames, registry credentials и access procedure.

## Environment Inventory

| Environment | Purpose | Access path | Notes |
| --- | --- | --- | --- |
| `ci` | Автоматическая проверка lint, security, test и system test | GitHub Actions workflow `.github/workflows/ci.yml` | Единственный подтвержденный non-local path на сегодня |
| `staging` | Planned pre-release runtime environment | Kamal deploy target | Не задокументирован как реально существующий; не предполагать доступ без подтверждения человека |
| `production` | Planned live environment | Kamal deploy target | `config/deploy.yml` пока содержит template-like значения и требует инстанцирования перед первым deploy |

## Common Operations

Только две группы операций можно считать каноничными:

1. уже подтвержденные операции в CI;
2. будущие Kamal-операции, но только после того, как человек подтвердил реальные хосты, registry и права доступа.

```bash
# CI / local verification
bin/rails test
bundle exec rspec
bin/rails test:system
bin/rubocop
bin/brakeman
bin/bundler-audit

# Kamal operations after infra is instantiated and approved
bin/kamal logs
bin/kamal console
bin/kamal shell
bin/kamal dbc
```

Границы доступа:

- `ci` доступен через GitHub workflow runs и не дает интерактивного mutating доступа к живому runtime;
- любые `bin/kamal ...` команды считать restricted operations до тех пор, пока владелец проекта не подтвердит реальную deploy-конфигурацию;
- интерактивные команды уровня `console`, `shell` и `dbc` всегда относятся к mutating-capable access, даже если используются для read-only диагностики.

## Credentials And Access

Подтвержденные факты:

- секреты для deploy предполагаются в `.kamal/secrets`;
- `RAILS_MASTER_KEY` и production database password не должны храниться в открытом виде в репозитории;
- текущий `config/deploy.yml` не фиксирует реальный внешний registry credential flow и не документирует SSH-процедуру доступа.

Недопустимый обход процедуры:

- коммитить реальные ключи, токены, пароли или хосты в `memory-bank/` или в deploy-конфиги;
- запускать `bin/kamal` против непроверенного target на основе template-like значений;
- предполагать существование staging/production shell access без явного подтверждения владельца проекта.

## Version And Health Checks

Подтвержденный health endpoint в приложении - `GET /up`.

Безопасные проверки на сегодня:

```bash
curl -fsS "http://localhost:${PORT:-3000}/up"
```

Для non-local runtime после инстанцирования окружения использовать тот же путь `/up`, но только когда hostname задокументирован в этой секции. Отдельный version endpoint в репозитории пока не зафиксирован, поэтому deployed version должна определяться внешним release/deploy tooling, а не выдуманным URL.

## Logs And Observability

Текущее состояние observability:

- production runtime настроен на логирование в STDOUT;
- `/up` исключен из шумного логирования через `config.silence_healthcheck_path = "/up"`;
- в репозитории не зафиксированы Sentry, Datadog, Prometheus, Grafana или другой внешний monitoring stack;
- после активации Kamal canonical entrypoint для container logs - `bin/kamal logs`.

## Test Data And Smoke Targets

Подтвержденные источники тестовых данных:

- локальные seed-данные из `db/seeds.rb`;
- ручной запуск мэтчинга через `bin/rails matching:run` для проверки pod formation на non-production данных.

Отдельные staging tenants, demo users или shared test accounts пока не задокументированы.

## Adoption Checklist

- [x] перечислены подтвержденные и planned non-local environments
- [x] указаны реальные и условно допустимые access paths
- [x] описаны safe health/version checks
- [x] перечислены observability entrypoints, подтвержденные в репозитории
- [x] удалены фальшивые и нерелевантные шаблонные примеры
