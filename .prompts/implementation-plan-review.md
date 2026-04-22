# Implementation Plan Review

Проверь `implementation-plan.md` на соответствие gate **Plan Ready** из `feature-flow.md`.

Прочитай:
- `memory-bank/features/FT-XXX/implementation-plan.md` — план для проверки
- `memory-bank/features/FT-XXX/feature.md` — canonical source REQ-*, SC-*, CHK-*, EVID-*
- `memory-bank/flows/feature-flow.md` — gate «Design Ready → Plan Ready»

## Критерии gate Plan Ready

Для каждого критерия дай оценку `pass` или `fail`:

1. **Grounding выполнен** — discovery context содержит: relevant paths, reference patterns, test surfaces, execution environment.
2. **`PRE-*`** — есть хотя бы один precondition.
3. **`STEP-*`** — есть хотя бы один шаг. Каждый шаг: конкретный файл, что меняется, как проверить.
4. **`CHK-*` / `EVID-*`** — есть checks и evidence с traceability к canonical IDs из `feature.md`.
5. **Порядок корректен** — зависимости между шагами не нарушены, нет циклов.
6. **Нет переопределения scope** — план не меняет REQ-*, SC-* или architecture из `feature.md`.
7. **`OQ-*`** — все неизвестности зафиксированы явно, не спрятаны в prose.
8. **`AG-*`** — рискованные и необратимые действия имеют явные human approval gates.
9. **Test strategy** — указаны automated coverage surfaces и required suites (local/CI).

## Что нужно сделать

1. Для каждого `fail`:
   - укажи, какой шаг или секция затронуты;
   - объясни, почему это блокирует реализацию;
   - предложи конкретное исправление.
2. Внеси правки напрямую в `implementation-plan.md`.

Если все критерии pass: `0 замечаний, план готов к реализации`.
