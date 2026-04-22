---
title: Testing Policy
doc_kind: engineering
doc_function: canonical
purpose: Описывает testing policy Orbit: обязательность test case design, реальные local/CI suites и допустимые manual-only gaps.
derived_from:
  - ../dna/governance.md
  - ../flows/feature-flow.md
status: active
canonical_for:
  - repository_testing_policy
  - feature_test_case_inventory_rules
  - automated_test_requirements
  - sufficient_test_coverage_definition
  - manual_only_verification_exceptions
  - simplify_review_discipline
  - verification_context_separation
must_not_define:
  - feature_acceptance_criteria
  - feature_scope
audience: humans_and_agents
---

# Testing Policy

Orbit использует не один test framework, а hybrid stack внутри Rails-монолита:

- `bin/rails test` и `bin/rails test:system` покрывают стандартные Rails/Minitest поверхности;
- `bundle exec rspec` покрывает RSpec-поверхности, уже добавленные для моделей, сервисов, каналов и контроллеров;
- `bin/ci` собирает canonical локальный прогон style/security/test checks, но не заменяет targeted verify для конкретной change surface.

Policy ниже исходит из этого dual setup и запрещает делать вид, что у репозитория уже есть единый test stack.

## Core Rules

- Любое изменение поведения, которое можно проверить детерминированно, обязано получить automated regression coverage.
- Любой новый или измененный contract обязан получить contract-level automated verification.
- Любой bugfix обязан добавить regression test на воспроизводимый сценарий.
- Required automated tests считаются закрывающими риск только если они проходят локально и не противоречат актуальному CI.
- Manual-only verify допустим только как явное исключение и не заменяет automated coverage там, где automation реалистична.

## Ownership Split

- Canonical test cases delivery-единицы задаются в `feature.md` через `SC-*`, feature-specific `NEG-*`, `CHK-*` и `EVID-*`.
- `implementation-plan.md` владеет только стратегией исполнения: какие test surfaces будут добавлены или обновлены, какие gaps временно остаются manual-only и почему.

## Feature Flow Expectations

Canonical lifecycle gates живут в [../flows/feature-flow.md](../flows/feature-flow.md):

- к `Design Ready` `feature.md` уже фиксирует test case inventory;
- к `Plan Ready` `implementation-plan.md` содержит `Test Strategy` с planned automated coverage и manual-only gaps;
- к `Done` required tests добавлены, локальные команды зелёные и CI не противоречит локальному verify.

## Что Считается Sufficient Coverage

- Покрыт основной changed behavior и ближайший regression path.
- Покрыты новые или измененные contracts, события, schema или integration boundaries.
- Покрыты критичные failure modes из `FM-*`, bug history или acceptance risks.
- Покрыты feature-specific negative/edge scenarios, если они меняют verdict.
- Процент line coverage сам по себе недостаточен: нужен scenario- и contract-level coverage.
- Если change surface живет в уже существующем test stack (`test/` или `spec/`), отсутствие нового теста требует явного обоснования, а не молчаливого пропуска.

## Когда Manual-Only Допустим

- Сценарий зависит от live infra, внешних систем, hardware, недетерминированной среды или human оценки UI.
- Для каждого manual-only gap: причина, ручная процедура, owner follow-up.
- Если manual-only gap оставляет без regression protection критичный путь, feature не считается завершённой.
- Для Orbit типичные manual-only зоны: browser behavior вокруг геолокации, UX/visual verification server-rendered UI, отдельные realtime-path детали pod chat, если их трудно надежно детерминировать в текущем тестовом контуре.

## Simplify Review

Отдельный проход верификации после функционального тестирования. Цель: убедиться, что реализация минимально сложна.

- Выполняется после прохождения tests, но до closure gate.
- Паттерны: premature abstractions, глубокая вложенность, дублирование логики, dead code, overengineering.
- Три похожие строки лучше premature abstraction. Абстракция оправдана только когда она реально уменьшает риск или повтор.

## Verification Context Separation

Разные этапы верификации — отдельные проходы:

1. **Функциональная верификация** — tests проходят, acceptance scenarios покрыты
2. **Simplify review** — код минимально сложен
3. **Acceptance test** — end-to-end по `SC-*`

Для small features допустимо в одной сессии, но simplify review не пропускается.

## Project-Specific Conventions

### Test Surfaces

- Новые Rails-native тесты живут в `test/` и используют Minitest helper из `test/test_helper.rb`.
- Существующие RSpec-поверхности живут в `spec/`; новые model/service/controller/channel specs допустимо добавлять туда, если change surface уже развивается в этом стеке.
- System/browser verification по умолчанию относится к `bin/rails test:system`; ручная browser-проверка не заменяет системный тест там, где automation реалистична.

### Test Data And Setup

- Для Minitest canonical pattern - `test/fixtures/*.yml` и общий setup из `test/test_helper.rb`.
- Для RSpec canonical pattern - `FactoryBot` через `config.include FactoryBot::Syntax::Methods` в `spec/rails_helper.rb`; при необходимости можно использовать `spec/fixtures`.
- `spec/rails_helper.rb` использует transactional fixtures, поэтому новые RSpec-тесты должны уважать этот execution model, а не вводить произвольный cleanup pattern без причины.
- Если change зависит от seeded data, это нужно явно оговаривать: seed-path сам по себе не считается заменой детерминированному fixture/factory setup.

### Required Local Commands

Перед handoff агент должен прогнать relevant local checks для затронутой поверхности. В Orbit canonical набор выбирается из следующих команд:

- `bin/rails test`
- `bundle exec rspec`
- `bin/rails test:system`
- `bin/rubocop`
- `bin/brakeman`
- `bin/bundler-audit`
- `bin/importmap audit`
- `bin/ci`

Не каждая задача обязана гонять все команды, но handoff должен явно сообщать, что именно было проверено и что осталось вне прогона.

### Current CI Contract

На момент этого документа GitHub Actions запускает следующие suites:

- `scan_ruby`: `bin/brakeman`, `bin/bundler-audit`
- `scan_js`: `bin/importmap audit`
- `lint`: `bin/rubocop`
- `test`: `bin/rails db:test:prepare test`
- `system-test`: `bin/rails db:test:prepare test:system`

Важно: `bundle exec rspec` пока не зафиксирован как отдельный GitHub Actions job. Поэтому для RSpec-covered surfaces локальный прогон RSpec обязателен, даже если CI для него еще не выделен в отдельный job.

### Assertions And Copy

- Текстовые assertions не должны быть хрупким дубликатом UI-copy без причины, особенно если строка уже должна жить в Rails I18n.
- Для realtime и HTML-response сценариев полезнее проверять contract, структуру и наблюдаемый результат, чем переутверждать весь markup целиком.

## Checklist For Template Adoption

- [x] указаны реальные local test commands
- [x] перечислены обязательные CI suites
- [x] задокументирован deterministic test data pattern
- [x] описаны manual-only exceptions
- [x] policy не противоречит [../flows/feature-flow.md](../flows/feature-flow.md)
