---
title: Architecture Patterns
doc_kind: domain
doc_function: canonical
purpose: Каноничное место для архитектурных границ проекта. Читать при изменениях, затрагивающих модули, фоновые процессы, интеграции или конфигурацию.
derived_from:
  - ../dna/governance.md
status: active
audience: humans_and_agents
---

# Architecture Patterns

Этот документ фиксирует архитектурные границы Orbit. Он не заменяет чтение кода, но задает каноничную картину ownership между основными частями системы и помогает не размывать domain boundaries при добавлении новых feature.

## Module Boundaries

| Context | Owns | Must not depend on directly |
| --- | --- | --- |
| `identity_and_access` | регистрация, сессии, подтверждение пользователя, routing после sign in/sign up | детали matching scoring и pod internals |
| `onboarding_and_profile` | шаги onboarding, profile fields, interests, schedule preference, geo-данные, readiness к matching | создание `Pod`, chat delivery и внутренние детали уведомлений |
| `matching` | batch-алгоритм формирования групп, compatibility scoring, geographic radius expansion, создание `Pod` и membership | UI-детали onboarding, presentation-слой pod experience |
| `pods_and_social` | `Pod`, membership, активности, pod chat, пользовательский опыт после мэтчинга | внутренние правила аутентификации и формулы matching score |
| `platform` | Rails infrastructure, Action Cable, persistence, env config, delivery механизм задач и realtime | product-specific решения о том, кого и как матчить |

Минимальные правила для Orbit:

- onboarding-слой отвечает за готовность пользователя к мэтчингу, но не за сам алгоритм;
- matching-слой может создавать `Pod`, `PodMembership` и `Notification`, но не должен тянуть presentation-логику из UI;
- post-match опыт должен опираться на уже созданный `Pod` и membership, а не пересчитывать eligibility или compatibility на лету;
- внешние интеграции и infra-слой не должны становиться неявным местом для domain rules.

## Concurrency And Critical Sections

Ключевая конкурентная зона Orbit - batch matching. Сегодня matching запускается вне HTTP request path через `rails matching:run`, то есть как отдельная операционная команда, а не как синхронная часть пользовательского запроса.

Каноничные правила:

- система должна предотвращать сценарий, в котором один пользователь оказывается сразу в нескольких `Pod`;
- перед изменением matching flow нужно явно проверять, как обеспечивается уникальность membership и что произойдет при повторном запуске команды;
- новые фоновые или scheduled execution path для мэтчинга нельзя добавлять без явного решения по idempotency и race conditions;
- если matching начнет выполняться через job queue или параллельные воркеры, concurrency control должен быть задокументирован здесь и в `ops/`.

Idempotent recovery для Orbit означает: повторный запуск механизма не должен дублировать membership и не должен создавать противоречивое состояние пользователя относительно активного `Pod`.

## Failure Handling And Error Tracking

Orbit предпочитает простую и наблюдаемую модель ошибок:

- в request/response-потоках ошибки валидации и неполного профиля должны оставаться на уровне пользовательского флоу, а не маскироваться общими rescue;
- в matching и других batch-процессах критично различать domain verdict ("недостаточно пользователей для формирования `Pod`") и настоящие системные ошибки;
- если появляется retry-механизм на уровне job runner или инфраструктуры, не нужно дублировать его локальными rescue/retry без documented reason;
- при добавлении error tracker в событиях matching и pod lifecycle должна передаваться domain metadata: `user_id`, `pod_id`, количество кандидатов, статус pod и execution path.

Пример вопроса, на который этот раздел должен отвечать:

> Если matching не смог собрать полную пятерку, это ошибка системы или допустимый продуктовый исход?

## Configuration Ownership

Для Orbit важна ownership-модель конфигурации, а не список всех env-переменных подряд.

Каноничный подход:

1. Если меняется поведение matching, сначала обновляется owner-слой алгоритма и его константы.
2. Если меняется инфраструктурная конфигурация realtime, auth или delivery, обновляется соответствующий Rails owner-слой.
3. Если изменение зависит от env contract или deployment settings, оно должно сопровождаться обновлением [`../ops/config.md`](../ops/config.md).

Особое правило: product logic не должна "прятаться" в неочевидных env-флагах. Если параметр влияет на то, как Orbit формирует группы или ведет пользователя по ключевому workflow, это решение должно быть отражено не только в конфигурации, но и в domain-документации.
