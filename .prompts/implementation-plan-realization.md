# Implementation Plan Realization

Реализуй фичу по `implementation-plan.md`.

Прочитай:
- `memory-bank/features/FT-XXX/implementation-plan.md` — план для исполнения
- `memory-bank/features/FT-XXX/feature.md` — canonical source acceptance criteria и evidence contract

## Перед стартом

- Убедись, что `feature.md` имеет `status: active` и `delivery_status: planned`.
- Обнови `feature.md` → `delivery_status: in_progress`.

## Правила выполнения

- Следуй шагам (`STEP-*`) по порядку, если из плана явно не следует безопасная параллелизация.
- Не меняй scope задачи без явного основания в `feature.md`.
- Если обнаружилось противоречие, пропущенный шаг или неверный grounding — остановись и опиши проблему до продолжения.
- Для шагов с `AG-*` (approval gate) — остановись и получи явное подтверждение от человека перед выполнением.
- После каждого `CP-*` (checkpoint) кратко сообщай о статусе.

## После реализации

1. Запусти все required test suites из плана. Убедись, что они зелёные.
2. Заполни evidence: `EVID-*` в `feature.md` конкретными артефактами (путь к файлу, CI run, скриншот).
3. Проставь результат `pass`/`fail` для каждого `CHK-*` из `feature.md`.
4. Выполни simplify review: убедись, что код минимально сложен. Три похожие строки лучше premature abstraction.
5. Обнови `feature.md` → `delivery_status: done`.
6. Обнови `implementation-plan.md` → `status: archived`.

## Итоговый отчёт

- Какие `STEP-*` выполнены.
- Какие файлы изменены.
- Какие тесты запущены и каков результат.
- Какие `CHK-*` прошли, какие нет.
- Какие ограничения, риски или follow-up остались.
