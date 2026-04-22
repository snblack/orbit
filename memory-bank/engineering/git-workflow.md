---
title: Git Workflow
doc_kind: engineering
doc_function: convention
purpose: Текущие git-conventions Orbit: default branch, commit/PR expectations и optional worktree usage.
derived_from:
  - ../dna/governance.md
status: active
audience: humans_and_agents
---

# Git Workflow

Этот документ описывает минимальный, но реальный git workflow Orbit. Репозиторий не навязывает жесткий conventional-commit regime, поэтому здесь фиксируются только подтвержденные инварианты, а не выдуманные process rules.

## Default Branch

Основная ветка Orbit - `main`. GitHub Actions запускаются на `push` в `main` и на `pull_request`, поэтому именно эта ветка считается canonical target для интеграции изменений.

## Commits

- Commit subject должен быть коротким, предметным и отражать intent изменения.
- Допустимы как русскоязычные, так и англоязычные commit messages, если они остаются понятными и конкретными.
- Обязательного формата вида `type(scope): ...` в проекте сейчас нет.
- Ссылка на issue или PR полезна, когда она добавляет traceability, но не зафиксирована как обязательная часть каждого коммита.
- Не смешивай в одном коммите несколько несвязанных изменений, если их можно отделить без потери целостности задачи.

## Pull Requests

- Перед handoff в PR должны быть зелёными relevant local checks для затронутой поверхности.
- Минимальный expected set определяется задачей, но в Orbit чаще всего это один или несколько из следующих прогонов: `bin/rails test`, `bundle exec rspec`, `bin/rails test:system`, `bin/rubocop`, `bin/brakeman`, `bin/bundler-audit`, `bin/importmap audit`, `bin/ci`.
- PR title должен быть коротким и предметным.
- В PR body полезно фиксировать:
  - что изменено;
  - как это проверено локально;
  - какие manual-only шаги, ограничения или риски остаются;
  - затронут ли `memory-bank`, если изменение меняет documented contract проекта.
- Если изменение трогает matching, auth, realtime chat, env contract или deployment path, в PR должен быть явно виден verify plan и границы риска.

## Worktrees

Worktrees допустимы как локальный способ изоляции параллельных задач, но не зафиксированы как обязательная часть workflow.

Если используется `git worktree add`, после создания рабочей директории нужно выполнить обычный bootstrap Orbit для локальной разработки: `direnv allow`, `bundle install`, `bin/setup --skip-server` по необходимости. Worktree не должен получать отдельные process rules, противоречащие основному `main`-centric workflow.
