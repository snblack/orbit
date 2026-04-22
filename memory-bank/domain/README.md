---
title: Domain Documentation Index
doc_kind: domain
doc_function: index
purpose: Навигация по domain-level документации Orbit. Читать для фиксации бизнес-контекста, архитектурных границ и UI-слоя проекта.
derived_from:
  - ../dna/governance.md
status: active
audience: humans_and_agents
---

# Domain Documentation Index

Секция `domain/` фиксирует каноничный контекст Orbit на уровне продукта, архитектуры и интерфейса. Feature-документы должны ссылаться на эти материалы, а не дублировать project-wide background в каждом пакете.

- [Project Problem Statement](problem.md) — что решает Orbit, для кого он существует, какие workflows считаются ключевыми и по каким outcomes оценивается продукт.
- [Architecture Patterns](architecture.md) — границы между onboarding, matching, pod lifecycle и platform-слоем. Читать при изменениях системного поведения или ownership модулей.
- [Frontend](frontend.md) — UI-поверхности Orbit, Hotwire/Stimulus conventions и правила локализации. Читать при работе с web-интерфейсом.
