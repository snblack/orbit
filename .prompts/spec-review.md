# Spec Review

Проверь `feature.md` на соответствие gate **Design Ready** из `feature-flow.md`.

Прочитай:
- `memory-bank/features/FT-XXX/feature.md` — canonical feature-документ
- `memory-bank/flows/feature-flow.md` — gate «Draft → Design Ready» и traceability contract

## Критерии gate Design Ready

Для каждого критерия дай оценку `pass` или `fail`:

1. `status: active` — frontmatter обновлён.
2. `REQ-*` — есть хотя бы один requirement в секции `Scope`.
3. `NS-*` — есть хотя бы один non-scope.
4. `SC-*` — есть хотя бы один acceptance scenario, end-to-end от входа до результата.
5. `CHK-*` — есть хотя бы один конкретный, исполнимый check.
6. `EVID-*` — есть хотя бы один evidence-артефакт.
7. **Traceability** — каждый `REQ-*` прослеживается к хотя бы одному `SC-*` через traceability matrix.
8. **Нет implementation sequence** — в `feature.md` нет пошаговых инструкций реализации (это задача `implementation-plan.md`).

## Дополнительно

9. `How > Solution` — описывает подход и trade-off, без пошагового плана?
10. `How > Change Surface` — перечислены конкретные файлы или компоненты?
11. Нет двусмысленных слов: «быстро», «удобно», «при необходимости»?

## Что нужно сделать

1. Для каждого `fail`:
   - приведи проблемный фрагмент;
   - объясни, почему это блокирует Plan Ready;
   - предложи конкретное исправление.
2. Внеси правки напрямую в `feature.md`.

Если все критерии pass: `feature.md` готов к созданию implementation-plan.md`.
