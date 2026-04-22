---
title: Coding Style
doc_kind: engineering
doc_function: convention
purpose: Реальные coding style и tooling conventions Orbit для Rails, Hotwire/Stimulus и локальной сложности.
derived_from:
  - ../dna/governance.md
status: active
audience: humans_and_agents
---

# Coding Style

Этот документ фиксирует текущий engineering style Orbit. Проект - Rails 8 монолит с PostgreSQL, Hotwire, Stimulus, Importmap и Tailwind. Значит, default path для новой работы - продолжать существующую Rails-first архитектуру, а не вводить параллельные паттерны без сильного основания.

## General Rules

- Имена файлов, классов и модулей должны следовать стандартным Rails/Ruby conventions.
- Комментарии добавляются только там, где без них трудно понять why, domain boundary или non-obvious constraint.
- Предпочитай минимальную локальную сложность вместо преждевременных абстракций.
- Следуй существующему локальному стилю файла, если он не противоречит зафиксированным здесь правилам.
- Не переписывай несвязанный код только ради косметического единообразия.

## Tooling Contract

- **Formatter / linter:** `bin/rubocop` (`rubocop-rails-omakase`) - canonical style gate для Ruby/Rails кода.
- **Security/static analysis:** `bin/brakeman`, `bin/bundler-audit`, `bin/importmap audit`.
- **Test-related verification:** `bin/rails test`, `bundle exec rspec`, `bin/rails test:system`, `bin/ci` для полного локального прогона.
- Отдельный JS formatter/linter в репозитории не зафиксирован. Для Stimulus и importmap-кода действует правило: писать в стиле существующих файлов, сохраняя простоту и читаемость.
- Pre-commit hooks не объявлены как canonical contract проекта.

## Ruby And Rails

- Контроллеры должны оставаться тонкими: orchestration, auth guard, strong params, response shaping.
- Domain logic не должна прятаться в views, helpers или Stimulus-контроллерах; для вычислений и правил предпочитай модели и сервисы.
- Отдельный service object оправдан, когда он владеет заметным domain workflow или batch-операцией, как `MatchingService`, а не просто переносит 2-3 строки из контроллера.
- Имена методов должны быть предметными и отражать действие или verdict, а не внутреннюю реализацию.
- Избегай широких rescue без documented reason. В Orbit важно различать domain verdict и системную ошибку, особенно в matching и pod lifecycle.

## Views, Hotwire And Stimulus

- UI в Orbit по умолчанию server-rendered; сначала предпочитай Rails views, partials, Turbo и небольшой Stimulus-код.
- Не вводи параллельный SPA/runtime pattern без явного архитектурного решения.
- Если UI-фрагмент начинает повторяться между несколькими поверхностями, выноси его в переиспользуемый view-level pattern, а не копируй разметку.
- Stimulus-контроллеры должны быть локальными, DOM-scoped и отвечать за interaction glue, а не за domain rules.
- Client-side код не должен заново вычислять бизнес-решения, уже принятые на сервере.

## Styling And Copy

- Tailwind - canonical styling layer. Предпочитай существующие utility-паттерны и локальную композицию вместо введения нового styling abstraction layer.
- Пользовательские строки, которые повторяются или привязаны к shared behavior, должны жить в Rails I18n, в первую очередь в `config/locales/ru.yml`.
- Inline-copy допустим для локального и одноразового UI текста, но при росте повторного использования его нужно выносить в переводы.

## Database, Migrations And Data Shape

- Имена таблиц, колонок, моделей и ассоциаций должны оставаться Rails-native и отражать domain vocabulary Orbit: `Pod`, `PodMembership`, `Notification`, onboarding/profile terms.
- Миграции пишутся как минимально необходимые изменения схемы; не объединяй в одну миграцию несвязанные structural changes.
- Если изменение затрагивает uniqueness, idempotency или matching invariants, это нужно отражать не только в коде, но и в `domain/` или `ops/`, когда меняется documented contract.

## Change Discipline

- В проекте сосуществуют Rails/Minitest и RSpec-поверхности; не пытайся насильно унифицировать весь репозиторий за одну задачу.
- При touch-up изменениях в legacy или transitional участках уважай локальный паттерн, если задача не требует migration work.
- Если новое решение создает новый устойчивый паттерн для Orbit, сначала убедись, что он совместим с `domain/architecture.md`, `domain/frontend.md` и текущими operational правилами.
