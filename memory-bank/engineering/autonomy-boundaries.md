---
title: Autonomy Boundaries
doc_kind: engineering
doc_function: canonical
purpose: Границы автономии агента: что можно делать без подтверждения, где нужна супервизия, когда эскалировать.
derived_from:
  - ../dna/governance.md
canonical_for:
  - agent_autonomy_rules
  - escalation_triggers
  - supervision_checkpoints
status: active
audience: humans_and_agents
---

# Autonomy Boundaries

Этот документ описывает не абстрактные агентные правила, а реальные границы автономии внутри Orbit. Базовый режим по умолчанию: агент может уверенно работать в локальном репозитории и `memory-bank`, но не должен молча менять product-critical contracts, non-local execution path или чувствительные operational решения.

## Автопилот — делай без подтверждения

- Редактировать код и тесты в рамках согласованной задачи
- Запускать локальные команды Orbit: `bin/rails test`, `bundle exec rspec`, `bin/rails test:system`, `bin/rubocop`, `bin/brakeman`, `bin/bundler-audit`, `bin/ci`
- Читать код, логи и локальные артефакты проверки
- Создавать и обновлять документацию в `memory-bank/`
- Создавать локальные ветки и worktrees, если это помогает изоляции задачи
- Выполнять безопасные refactorings, которые не меняют product contract и подтверждаются тестами

## Супервизия — делай, но покажи на контрольной точке

- Изменение схемы БД, миграции и reset/seeding path — покажи миграцию и verify plan до выполнения
- Изменение matching rules, критериев eligibility, pod lifecycle или инвариантов membership — покажи intended behavior до начала исполнения
- Изменение auth/login/onboarding routing через Devise или controller-level access rules — покажи diff и verify plan
- Изменение Action Cable, chat behavior, realtime contract или внешне наблюдаемого UI flow — покажи изменения и способ проверки
- Изменение `config/`, env contract, CI/deploy path или non-local operational команды — покажи, что именно меняется и почему
- Удаление файлов, крупных блоков кода или заметная реструктуризация каталогов — покажи scope удаления
- Подготовка PR в `main` — покажи итоговый diff и результаты relevant local checks

## Эскалация — остановись и спроси

- Неясные или противоречивые бизнес-требования
- Выбор между несколькими равноценными подходами с разными trade-offs
- Любые действия вне локальной среды: deploy, работа с production/staging, live data, внешние аккаунты и реальные интеграции
- Изменение security-sensitive поведения: auth, session handling, secrets, permission model, payment/compliance-adjacent логика
- Запуск операций, которые могут materially менять состояние пользователей вне локальной машины
- Конфликтующие локальные паттерны в кодовой базе, когда из имеющихся примеров нельзя уверенно вывести canonical rule
- Задача выходит за согласованный scope и требует product decision, а не только инженерного исполнения

## Правило эскалации

Если замечания, flaky failures или блокеры не уменьшаются после 2-3 итераций, проблема может быть не в коде, а в upstream-требованиях, тестовой стратегии или ограничениях среды. В этом случае агент останавливает цикл, явно формулирует блокер и предлагает вернуться к плану, scope или approval decision вместо бесконечного перебора.
