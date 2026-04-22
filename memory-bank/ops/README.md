---
title: Operations Index
doc_kind: engineering
doc_function: index
purpose: Навигация по операционной документации Orbit. Читать при локальной разработке, работе с конфигурацией, CI и подготовке к non-local deploy.
derived_from:
  - ../dna/governance.md
status: active
audience: humans_and_agents
---

# Operations Index

Секция `ops/` описывает operational контекст Orbit на текущем уровне зрелости проекта:

- локальная разработка и CI уже имеют подтвержденные entrypoints;
- production deploy path намечен через Kamal, но часть инфраструктурных деталей еще не инстанцирована в репозитории;
- документы ниже должны отличать подтвержденные факты от planned workflow и не придумывать несуществующие окружения или процедуры.

- [Development Environment](development.md) — реальный локальный setup Orbit: `direnv`, Postgres, `bin/setup`, `bin/dev`, тесты, линтеры и batch matching.
- [Stages And Non-Local Environments](stages.md) — что уже подтверждено вне локальной машины, а что пока остается planned Kamal deployment path.
- [Release And Deployment](release.md) — текущие release gates, CI, ограничения до полноценного deploy и ожидаемый future workflow.
- [Configuration](config.md) — ownership-модель конфигурации Orbit: `database.yml`, `production.rb`, `deploy.yml`, `.envrc`, секреты и env contract.
- [Runbooks](runbooks/README.md) — место для повторяемых operational runbooks. Пока каталог служит каркасом для будущих инструкций.
