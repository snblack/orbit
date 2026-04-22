---
title: Runbooks Index
doc_kind: engineering
doc_function: index
purpose: Точка входа в operational runbooks Orbit. Читать, чтобы завести пошаговую инструкцию для повторяемой ops-задачи, batch-problem или deploy-инцидента.
derived_from:
  - ../../dna/governance.md
status: active
audience: humans_and_agents
---

# Runbooks Index

В этом каталоге живут runbooks для повторяемых operational задач.

Для Orbit первыми кандидатами на отдельные runbooks являются:

- сбой или неожиданный результат `bin/rails matching:run`;
- post-deploy smoke failure после активации Kamal;
- диагностика проблем с `Pod` chat / Action Cable в production-like окружении;
- восстановление после неудачной миграции или проблем с одной из production databases (`primary`, `cache`, `queue`, `cable`).

Runbook должен отвечать на вопросы:

- что является триггером;
- что проверить сначала;
- какие команды выполнять;
- какой результат ожидать;
- как безопасно откатиться;
- кому и когда эскалировать проблему.

## Suggested Structure

1. Summary
2. Trigger / symptoms
3. Safety notes
4. Diagnosis
5. Resolution
6. Rollback
7. Escalation

Если у проекта пока нет конкретных runbooks, каталог может временно содержать только этот индекс, но при первом повторяемом operational сценарии здесь нужно завести отдельный документ, а не полагаться на знания "в голове".
