# Implementation Plan Do

Создай `implementation-plan.md` для фичи, которая достигла стадии **Design Ready**.

Прочитай:
- `memory-bank/features/FT-XXX/feature.md` — canonical source для REQ-*, NS-*, SC-*, CHK-*, EVID-*
- `memory-bank/flows/feature-flow.md` — gate «Design Ready → Plan Ready» и stable identifiers
- `memory-bank/flows/templates/feature/implementation-plan.md` — шаблон

## Перед составлением плана выполни grounding

Пройдись по реальному состоянию репозитория и зафикси в секции `Discovery Context`:

- **Relevant paths** — реальные файлы и модули, которые затронет реализация.
- **Reference patterns** — локальные паттерны (сервисы, контроллеры, тесты), на которые ориентируется план.
- **Unresolved questions** (`OQ-*`) — если есть неизвестности, зафиксируй их явно.
- **Test surfaces** — где появятся тесты.
- **Execution environment** — ruby version, rails version, какие команды запускают тесты.

## Что должен содержать план

- `PRE-*` — preconditions (что должно быть истиной перед стартом).
- `STEP-*` — атомарные шаги: конкретный файл, что именно меняется, как проверить.
- `CP-*` — checkpoints после блоков шагов.
- `CHK-*` / `EVID-*` — checks и evidence, ссылающиеся на canonical IDs из `feature.md`.
- `AG-*` — human approval gates для рискованных или необратимых действий.
- Колонки `Implements`, `Verifies`, `Evidence IDs` — traceability к REQ-*, SC-*, EVID-* из `feature.md`.

## Правила

- Plan не переопределяет scope, architecture или acceptance criteria из `feature.md`.
- Если что-то противоречит `feature.md`, сначала обнови `feature.md`, потом план.
- Не создавай план, если `feature.md` ещё не `status: active` (не Design Ready).
- После создания сообщи, выполнены ли все условия gate «Design Ready → Plan Ready».
