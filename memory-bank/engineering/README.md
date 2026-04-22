---
title: Engineering Documentation Index
doc_kind: engineering
doc_function: index
purpose: Навигация по инженерным правилам Orbit: testing policy, coding style, git workflow и границы автономии агента.
derived_from:
  - ../dna/governance.md
status: active
audience: humans_and_agents
---

# Engineering Documentation Index

Секция `engineering/` фиксирует инженерные соглашения Orbit на уровне разработки и delivery discipline. В отличие от `domain/`, здесь не описывается продуктовая логика; в отличие от `ops/`, здесь не описываются среды и release path. Этот каталог отвечает на вопрос: как именно в Orbit писать код, проверять изменения и где агент обязан остановиться на контрольной точке.

- [Testing Policy](testing-policy.md) — каноничные правила верификации Orbit: когда нужны automated tests, какие local/CI suites считаются обязательными и где допустим manual-only verify.
- [Autonomy Boundaries](autonomy-boundaries.md) — границы автономии агента в текущем репозитории: что можно делать без подтверждения, какие изменения требуют checkpoint и когда нужно эскалировать.
- [Coding Style](coding-style.md) — реальные соглашения Orbit по Ruby/Rails, Hotwire/Stimulus, локальной сложности и canonical tooling.
- [Git Workflow](git-workflow.md) — текущие git-конвенции Orbit: `main`, commit/PR expectations и отношение к worktrees.
- [ADR](../adr/README.md) — instantiated Architecture Decision Records проекта.
