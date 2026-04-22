# Spec Do

Заполни секции `How` и `Verify` в `feature.md`, продвинув его из стадии **Draft** в **Design Ready**.

Прочитай:
- `memory-bank/features/FT-XXX/feature.md` — текущее состояние фичи
- `memory-bank/flows/feature-flow.md` — gate «Draft → Design Ready» и список stable identifiers
- Шаблон `memory-bank/flows/templates/feature/short.md` или `large.md` — в зависимости от шаблона фичи

## Что нужно заполнить

### Секция `How`

- `Solution` — один абзац: основной подход и ключевой trade-off.
- `Change Surface` — таблица: какие файлы/компоненты меняются и почему.
- `Flow` — шаги от входного события до наблюдаемого результата.

### Секция `Verify`

- `EC-*` — Exit Criteria: что должно быть истинно после реализации.
- `SC-*` — Acceptance Scenarios: минимум один happy path, end-to-end через все затронутые слои.
- `NEG-*` — если критичные failure modes требуют явного покрытия.
- `CHK-*` — конкретная команда или процедура проверки.
- `EVID-*` — артефакт, который остаётся после проверки.
- `Traceability matrix` — связь `REQ-*` → `SC-*` → `CHK-*` → `EVID-*`.

## Требования к результату

- Не меняй секцию `What` и `Problem` — это зафиксировано на стадии Brief.
- Не уходи в implementation sequence — это задача `implementation-plan.md`.
- Все `SC-*` должны быть end-to-end: от входного события до наблюдаемого результата.
- После заполнения обнови frontmatter: `status: active`, `delivery_status: planned`.
- Если данных недостаточно — сначала задай список уточняющих вопросов с вариантами по умолчанию.
- Сообщи, выполнены ли все условия gate «Draft → Design Ready» из `feature-flow.md`.
