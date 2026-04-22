# Brief Do

Создай **Draft Feature Package** — первую стадию lifecycle перед Spec и Plan.

## Что такое Brief в этом проекте

Brief — это стадия `Draft` в `feature.md`. Он фиксирует проблему и намерение владельца, но **не описывает решение и не уходит в implementation details**.

На этой стадии создаются два файла:
- `memory-bank/features/FT-XXX/README.md` — routing-слой пакета
- `memory-bank/features/FT-XXX/feature.md` — canonical feature-документ со `status: draft`

Шаблоны живут в `memory-bank/flows/templates/feature/`. Выбор шаблона:
- `short.md` — если фича локальна и укладывается в один `REQ-*`, один `SC-*`, один `CHK-*`, один `EVID-*`
- `large.md` — если нужны `ASM-*`, `DEC-*`, `CTR-*`, `FM-*`, несколько acceptance scenarios или несколько `CHK-*`/`EVID-*`

## Что заполняется на стадии Brief

Заполни только секцию `What`:

- `Problem` — какую конкретную проблему решаем, боль пользователя, контекст откуда пришла задача
- `Scope` — `REQ-*` что обязательно входит
- `Non-Scope` — `NS-*` что точно не делаем

Секции `How` и `Verify` оставь как плейсхолдеры из шаблона — они заполняются на стадии Spec (Design Ready).

`implementation-plan.md` на этой стадии **не создаётся**.

## Brief отвечает на вопросы

- Какую проблему решаем?
- Для кого? Какой пользователь или стейкхолдер затронут?
- Откуда взялась задача? Контекст происхождения.
- Что хотим получить? Желаемый результат на уровне намерения.

## Что нужно сделать

Прочитай правила из `memory-bank/flows/feature-flow.md` и шаблоны из `memory-bank/flows/templates/feature/`.

Создай feature package для этой задачи:

```text
[вставь сюда описание задачи, issue, запрос стейкхолдера или контекст]
```

## Требования к результату

- Не предлагай архитектурное решение, не уходи в implementation details.
- Сфокусируйся на проблеме, контексте, affected users/stakeholders и намерении.
- Если данных недостаточно — сначала задай короткий список уточняющих вопросов.
- Если данных достаточно — создай `README.md` и `feature.md` со `status: draft` и `delivery_status: planned`.
- После создания сообщи путь к пакету и что нужно заполнить на следующем шаге (Spec → Design Ready).
