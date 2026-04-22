---
title: Release And Deployment
doc_kind: engineering
doc_function: canonical
purpose: Каноничное описание release gates и planned deploy path Orbit. Читать перед релизной проверкой, CI gate review и первым production deploy через Kamal.
derived_from:
  - ../dna/governance.md
status: active
audience: humans_and_agents
---

# Release And Deployment

## Release Flow

Текущий release flow Orbit состоит из двух частей: подтвержденные verification gates и planned deploy path.

Подтвержденная часть:

1. Изменения попадают в `main` через обычный git/PR workflow.
2. На `push` в `main` и на `pull_request` запускается GitHub Actions workflow `CI`.
3. CI обязан прогнать security checks, lint, unit/integration tests и system tests.
4. Если изменение затрагивает пользовательские flows или matching, перед релизом нужен локальный smoke на основных сценариях Orbit.

Planned часть:

5. Deploy path задуман через Kamal и контейнерную сборку.
6. Перед первым реальным deploy нужно заменить template-like значения в `config/deploy.yml`, заполнить `.kamal/secrets`, зафиксировать реальные hostnames и обновить [`stages.md`](stages.md).
7. До этого момента не считать `bin/kamal deploy` безопасной или полностью документированной командой для production.

## Release Commands

Каноничные команды релизной проверки сегодня:

```bash
bin/rubocop
bin/brakeman
bin/bundler-audit
bin/rails test
bundle exec rspec
bin/rails test:system
bin/rails matching:run
```

Команды ниже допустимы только после инстанцирования deploy-инфраструктуры и явного human approval:

```bash
bin/kamal setup
bin/kamal deploy
bin/kamal logs
```

Safety rules:

- обязательные runtime secrets для deploy включают как минимум `RAILS_MASTER_KEY` и production database credentials;
- все non-local deploy-операции требуют явного approval, пока staging/production не описаны в `ops/stages.md`;
- automated release gates сегодня ограничиваются CI; deploy и post-deploy smoke остаются manual until proven otherwise.

## Release Test Plan

Если релиз заметно меняет onboarding, matching или pod experience, полезно заводить отдельный тестовый план. Формат можно оставить тем же, но checklist стоит адаптировать под реальный продуктовый поток Orbit.

**Формат:** `release-v{VERSION}-test-plan.md`

Минимальный Orbit-oriented skeleton:

```markdown
# Тестовый план релиза v{VERSION}

**Дата:** YYYY-MM-DD
**Предыдущая версия:** v{PREV_VERSION}
**Текущая версия:** v{VERSION}
**Стенд:** <environment>

## Обзор изменений

| Issue | Название | Тип | Приоритет |
| --- | --- | --- | --- |
| #XXXX | Описание задачи | Feature/Fix/Refactoring/Tech debt | Высокий/Средний/Низкий |

## Проверка изменений

- [ ] Описан хотя бы один test case для каждого крупного change set

## Smoke-тесты

- [ ] Landing / entry page открывается
- [ ] Регистрация и вход не сломаны
- [ ] Onboarding доводит пользователя до готовности к matching
- [ ] `bin/rails matching:run` отрабатывает без исключений на тестовых данных
- [ ] Страница `Pod` открывается для matched пользователя
- [ ] Pod chat / realtime path не сломан, если релиз его затрагивает
- [ ] Health endpoint `/up` отвечает успешно
```

## Rollback

Rollback policy для Orbit пока частично определена и должна быть усилена перед первым production deploy.

На текущем уровне зрелости нужно считать обязательными следующие правила:

1. rollback unit должен совпадать с последним успешно задеплоенным container image / release;
2. fastest safe rollback должен быть задокументирован в Kamal workflow до первого production запуска;
3. rollback в live environment не должен выполняться без подтверждения человека;
4. любые миграции, затрагивающие `primary`, `cache`, `queue` или `cable` databases, нужно отдельно оценивать на обратимость;
5. если релиз меняет matching behavior или membership invariants, rollback-план должен учитывать риск повторного batch matching и проверку отсутствия дублирующих `PodMembership`.
