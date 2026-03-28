# Идеальное решение: SaaS Metrics Dashboard для инди-фаундеров

## Сначала честный анализ проблемы

Проблема звучит просто: "Baremetrics дорогой, хочу дешевле". Но это поверхность.

Реальная проблема глубже: **инди-фаундер тонет в метриках которые не помогают принимать решения**.

Существующие инструменты сделаны для CFO Series B компаний — они показывают 40 графиков. Инди-фаундер открывает Baremetrics и видит когорты, ARPU, expansion MRR, contraction MRR... и уходит в "founder theater" — ощущение работы без реального действия.

> "Most early SaaS founders make the same mistake: we act like we're running a Series B dashboard while we're still trying to find 20 people who care." — Indie Hackers, ноябрь 2025

**Правда которую никто не говорит:** до $20K MRR почти все метрики кроме трёх — бесполезны, потому что выборка слишком мала.

Три метрики которые реально важны на старте:
1. **MRR растёт?** — единственный сигнал "это работает"
2. **Пользователи возвращаются после 1 недели?** — единственное доказательство что продукт нужен
3. **Новые пользователи быстро доходят до "aha момента"?** — активация двигает все остальные метрики

---

## Почему конкуренты оставили место

| Инструмент | Цена | Проблема |
|---|---|---|
| Baremetrics | $79–358/мес | Дорого при малом MRR, сложно, сделано для больших |
| ChartMogul | Бесплатно до $10K MRR, потом $100+/мес | Бесплатный план очень ограничен, сложный интерфейс |
| ProfitWell / Paddle | Бесплатно, но сдвигается к Paddle-экосистеме | Зависимость от Paddle, урезанный роадмап для других |
| Самодельный Google Sheets | Бесплатно | Ручной ввод, нет автосинка, нет алертов, теряет время |

**Ключевой инсайт:** ChartMogul бесплатен до $10K MRR — но большинство инди-фаундеров не знают об этом. А кто знает — жалуется что интерфейс перегружен и не отвечает на главный вопрос: **"Что мне делать прямо сейчас?"**

Пустое место: **инструмент который говорит фаундеру не что происходит, а что с этим делать**.

---

## Концепция идеального продукта: **Pulse**

> *"Pulse — это не дашборд метрик. Это еженедельный брифинг фаундера: что изменилось, почему это важно, и что делать дальше."*

### Принцип: "Командный центр" вместо "аналитической платформы"

Baremetrics показывает данные. Pulse отвечает на вопросы.

Каждый раз когда фаундер открывает Pulse, он видит не 40 графиков — а **три вопроса со статусом**:

```
✅ MRR растёт?        $2,340 → $2,810  (+20% за 30 дней)
⚠️  Retention здоров?  Месяц 2: 68% (норма для вашей ниши: 75%+)
❌ Активация быстрая? Только 34% новых доходят до первого ключевого действия
```

И под каждым — **одно конкретное действие**:
- "MRR растёт — отлично. 3 новых клиента пришли из SEO-статьи про [тема]. Напишите ещё одну."
- "Retention просел. 2 клиента отменили в этом месяце. [Иван и Мария]. Написать им?"
- "Активация низкая. Медианное время до первого экспорта — 4 дня. Норма у похожих продуктов — 1 день. Вот что можно упростить."

---

## Полная архитектура продукта

### Блок 1: Подключения (Sources)

**Stripe** — основное. Правильный расчёт MRR через исторические инвойсы (не subscriptions object — это ловушка новичков, subscriptions показывают только текущее состояние).

**LemonSqueezy** — второй по популярности у инди-фаундеров (Merchant of Record, без налоговых головных болей).

**Paddle** — для фаундеров с международной аудиторией.

**Gumroad** — для creators-as-founders.

**Ручной ввод** — для тех кто только начинает или использует нестандартные системы.

Уникальный момент: **мультиисточник в одном MRR**. Ты продаёшь через Stripe и LemonSqueezy параллельно? Pulse объединяет и показывает единый MRR.

---

### Блок 2: Метрики (что считаем и как)

**Tier 1 — всегда на экране (для любого MRR):**

- **MRR** с правильной декомпозицией:
  - New MRR (новые клиенты)
  - Expansion MRR (апгрейды)
  - Contraction MRR (даунгрейды)
  - Churned MRR (отписки)
  - Net New MRR = New + Expansion − Contraction − Churned
- **MRR Growth Rate** месяц-к-месяцу и неделя-к-неделе
- **Active Subscribers** с трендом
- **Churn Rate** (% и в деньгах)
- **Failed Payments** — деньги которые уже "твои" но потеряются если не догнать

**Tier 2 — появляются после $5K MRR (достаточно данных):**

- **LTV** (Customer Lifetime Value) — средний доход с клиента за всё время
- **ARPU** (Average Revenue Per User)
- **MRR by Plan** — какой тариф приносит больше
- **Trial-to-Paid Conversion Rate**

**Tier 3 — после $20K MRR (статистически значимо):**

- **Cohort Retention** — сколько клиентов N-го месяца остаётся через 3/6/12 месяцев
- **Net Revenue Retention** — растёт ли доход от существующих клиентов
- **LTV:CAC ratio** (если добавить расходы на маркетинг)
- **Payback Period**

**Почему это важно:** Pulse сам говорит тебе какие метрики сейчас значимы для твоего стадии. Не показывает когорты когда у тебя 15 клиентов — это статистический шум.

---

### Блок 3: Алерты (самое ценное)

Это то чего нет ни у одного конкурента в удобном виде для инди-фаундеров.

**Алерты в реальном времени:**

| Событие | Алерт |
|---|---|
| Новый платёж | "🎉 Новый клиент: Анна К., $29/мес (Plan: Pro)" |
| Отмена подписки | "⚠️ Отмена: Иван М. отменил Pro ($49/мес). Был клиентом 3 месяца. Написать?" |
| Failed payment | "💸 Не прошёл платёж: Сергей Л., $29. Попытка 1 из 3. Автодунинг включён." |
| MRR milestone | "🏆 Достигли $1,000 MRR!" |
| MRR drop >10% | "🔴 MRR упал на $180 за 7 дней. 4 отмены. Смотреть?" |
| Unusual churn spike | "⚡ Аномалия: 3 отмены за 24 часа (обычно 1 в неделю). Что-то изменилось?" |

Алерты приходят в **Slack / Email / Telegram** (на выбор). Для инди-фаундера который не сидит в дашборде 24/7 — это критично.

---

### Блок 4: Churned Customer Intelligence

Это killer feature которого нет у конкурентов в доступном ценовом сегменте.

Когда клиент отменяет — Pulse автоматически:

1. **Показывает карточку клиента:** план, сколько платил, сколько месяцев был клиентом, как часто логинился
2. **Предлагает написать** — кнопка "Send cancellation win-back" открывает шаблон письма с персонализацией
3. **Опционально:** встраивает offboarding survey в момент отмены (Stripe checkout exit → форма "почему уходишь?")
4. **Агрегирует причины:** если 5 клиентов написали "слишком дорого" — Pulse выводит это как инсайт

Не просто "кто ушёл" — а "почему ушли и что делать".

---

### Блок 5: Weekly Digest — главная фича

Каждый понедельник в 9:00 — email/Telegram-сообщение:

```
📊 Pulse Weekly Digest — неделя 12–18 марта

MRR: $2,810 (+$180 vs прошлая неделя) ✅
Новых клиентов: 4
Отмен: 1 (Иван М., был 3 мес, сказал "нашёл бесплатную альтернативу")
Failed payments решено: 2 из 3

🔑 Главный инсайт этой недели:
Все 4 новых клиента пришли через страницу /pricing.
Средний time-to-convert с этой страницы: 2 дня.
Другие страницы: 8 дней.
→ Попробуй добавить FAQ на другие лендинги.

⚡ Одно действие на эту неделю:
Напиши Ивану М. — win-back письмо. Шаблон готов. [Открыть]
```

Это то что фаундер хочет видеть — не 40 графиков, а **один инсайт и одно действие**.

---

### Блок 6: Investor-Ready Export

Когда фаундер идёт к инвестору или публикует revenue update на Indie Hackers:

- Один клик → PDF с красивым MRR graph, key metrics, growth rate
- Shareable link (можно расшарить публично — MRR Milestones page)
- Twitter/X card: "We hit $5K MRR 🎉" с графиком — готово к посту

Многие инди-фаундеры публично делятся прогрессом — это часть маркетинга. Pulse делает это красиво и без усилий.

---

### Блок 7: Dunning (автоматическое возврат Failed Payments)

9% SaaS-дохода теряется на failed payments — карта истекла, недостаточно средств.

Pulse включает встроенный dunning:
- Автоматически retry через 3/5/7 дней
- Отправляет email клиенту с ссылкой обновить карту
- Показывает "recovered revenue" на дашборде

Для инди-фаундера это буквально деньги из воздуха — без усилий.

---

## UX: как выглядит продукт

### Home Screen — "Mission Control"

```
┌─────────────────────────────────────────────────────┐
│  PULSE                               March 26, 2026  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  MRR         $2,810    ▲ +$180 this week (+7%)      │
│  Subscribers    42     ▲ +4 new, -1 churned          │
│  Churn Rate    2.4%    ✅ healthy (< 5%)              │
│                                                     │
├─────────────────────────────────────────────────────┤
│  THIS WEEK                                          │
│  ┌──────────────────────────────────────────────┐  │
│  │ 🎉 4 new payments    $116 new MRR            │  │
│  │ ⚠️  1 cancellation   -$29 MRR               │  │
│  │ 💸 1 failed payment  $29 at risk → [Fix]    │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
├─────────────────────────────────────────────────────┤
│  ONE THING TO DO TODAY                             │
│  ┌──────────────────────────────────────────────┐  │
│  │ Ivan M. cancelled yesterday.                 │  │
│  │ Was a customer for 3 months. Said:           │  │
│  │ "found a free alternative"                   │  │
│  │ → [Send win-back email]  [Dismiss]           │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  [MRR Chart]  [Cohorts]  [Customers]  [Settings]   │
└─────────────────────────────────────────────────────┘
```

---

## Ценообразование

| Тариф | Цена | Для кого |
|---|---|---|
| **Free** | $0 | До $3K MRR — навсегда бесплатно |
| **Indie** | $9/мес | $3K–$30K MRR — все основные функции |
| **Growth** | $29/мес | $30K–$150K MRR + cohorts, advanced alerts, dunning |
| **Scale** | $79/мес | $150K+ MRR + team access, API, white-label exports |

**Почему это работает:**
- Baremetrics берёт $79 с первого дня → мы берём $0 до $3K
- При $800 MRR наш план = $9 = 1.1% дохода vs Baremetrics = $79 = 9.9% дохода
- При $5K MRR фаундер уже чувствует ценность и легко платит $9

---

## Технический стек и сложность реализации

### Frontend: React + TypeScript + Tailwind + Recharts

**Ключевые компоненты:**
- `MRRChart` — линейный график с breakdowns (New/Expansion/Churn/Contraction)
- `MetricCard` — карточка метрики с трендом и status indicator
- `AlertFeed` — лента событий в реальном времени
- `CustomerList` — таблица клиентов с фильтрами
- `WeeklyDigestPreview` — превью дайджеста

### Backend: Node.js + Express + PostgreSQL

**Ключевые сервисы:**

```
stripe-sync/
  ├── invoice-fetcher.js       # тянет исторические инвойсы
  ├── mrr-calculator.js        # считает MRR из инвойсов (не subscriptions!)
  ├── subscription-tracker.js  # отслеживает new/churn/upgrade/downgrade
  └── webhook-handler.js       # обрабатывает Stripe webhooks в реальном времени

metrics/
  ├── mrr.js                   # MRR, ARR, Net New MRR
  ├── churn.js                 # churn rate, churned MRR
  ├── ltv.js                   # LTV, ARPU
  ├── cohorts.js               # cohort retention (появляется после N клиентов)
  └── insights.js              # AI-генерация инсайтов из метрик

alerts/
  ├── rule-engine.js           # проверяет условия алертов
  ├── slack-notifier.js
  ├── email-notifier.js
  └── telegram-notifier.js

digests/
  └── weekly-digest.js         # cron каждый понедельник 9:00
```

**База данных:**
```sql
-- Основные таблицы
users (id, email, created_at)
connections (id, user_id, provider, api_key_encrypted, connected_at)
invoices (id, user_id, external_id, customer_id, amount, currency, date, plan, status)
customers (id, user_id, external_id, email, name, mrr, status, created_at, cancelled_at)
mrr_snapshots (id, user_id, date, mrr, new_mrr, expansion_mrr, churn_mrr, contraction_mrr)
alerts (id, user_id, type, payload, sent_at, read_at)
cancellation_reasons (id, user_id, customer_id, reason, created_at)
```

### Технические сложности которые нужно решить

**1. Правильный расчёт MRR**

Нельзя брать `subscription.amount * 12 / 12`. Нужно:
- Использовать исторические инвойсы (не subscriptions object)
- Нормализовать годовые планы к месячному эквиваленту
- Учитывать скидки, coupon, trial periods
- Правильно классифицировать: это upgrade, downgrade, или reactivation?

Это самая нетривиальная часть — Medium-статья "Calculating MRR from raw Stripe data is tricky" описывает все ловушки.

**2. Webhooks vs Polling**

Stripe webhooks дают события в реальном времени. Но:
- Webhooks могут потеряться → нужен fallback polling
- Порядок событий не гарантирован → нужна idempotency
- Retry при failed webhook → нужна deduplification

**3. Multi-source MRR**

Если фаундер использует и Stripe и LemonSqueezy — нужно:
- Дедупликация клиентов (один клиент может быть в обоих)
- Единая валюта (конвертация по курсу на дату транзакции)
- Единая timeline MRR

**4. Когда показывать какие метрики**

Логика "tier" метрик — нужен алгоритм который определяет:
- Достаточно ли данных для cohort анализа? (минимум 3 когорты по 10+ клиентов)
- Значима ли LTV при малой выборке?
- Показывать ли CAC если не введены расходы?

---

## Что делает Pulse лучшим на рынке

| Фича | Baremetrics | ChartMogul | Pulse |
|---|---|---|---|
| Цена для $1K MRR | $79/мес | Бесплатно (ограничено) | **$0** |
| Weekly AI Digest | ❌ | ❌ | **✅** |
| "One action" рекомендация | ❌ | ❌ | **✅** |
| Churn win-back workflow | Базово | ❌ | **✅** |
| Multi-source MRR (Stripe + LS) | ❌ | ❌ | **✅** |
| Telegram алерты | ❌ | ❌ | **✅** |
| "Stage-aware" метрики | ❌ | ❌ | **✅** |
| Investor-ready export | ✅ | ✅ | **✅** |
| Dunning (failed payments) | ✅ | ❌ | **✅** |

---

## Где искать первых пользователей

**Где живёт аудитория:**
- Indie Hackers (сообщество ~500K фаундеров)
- Reddit: r/SaaS, r/indiehackers, r/microSaaS
- Twitter/X: #indiehacker, #buildinpublic теги
- Product Hunt (launch)
- Hacker News: "Show HN: Free Stripe Analytics for indie founders"

**Тактика:**
1. Написать пост на Indie Hackers: "Я делаю $800 MRR и отдавал бы $100 Baremetrics — решил это исправить"
2. Show HN на Hacker News: конкретный угол "бесплатно до $3K MRR, потом $9"
3. Product Hunt launch с упором на "free alternative to Baremetrics"
4. "Build in public" — публично строить продукт и документировать прогресс

**Важно:** аудитория технически грамотная, понимает ценность продукта сразу. Не нужно объяснять зачем нужны метрики — нужно объяснить почему твой инструмент лучше.

---

## MVP за 4–6 недель

**Неделя 1–2:**
- Stripe OAuth подключение
- Синхронизация инвойсов за последние 12 месяцев
- Расчёт MRR, Active Subscribers, Churn Rate
- Базовый дашборд (3 карточки + линейный график MRR)

**Неделя 3:**
- Список клиентов с MRR и статусом
- Webhook handler для real-time событий
- Email алерт при новом платеже и отмене

**Неделя 4:**
- Weekly Digest email (cron каждый понедельник)
- Базовый dunning (retry failed payments через Stripe)
- LemonSqueezy подключение (второй источник)

**Неделя 5–6:**
- "One action" блок (win-back для churned)
- Investor-ready PDF export
- Cancellation survey embed
- Telegram алерты

**Запуск на Product Hunt + Indie Hackers**

---

## Источники

- [Calculating MRR from Stripe is Tricky — Medium](https://medium.com/@steven_wang/calculating-mrr-from-raw-stripe-data-is-tricky-heres-how-we-did-it-80c9980d783a)
- [3 SaaS Metrics That Actually Matter — Indie Hackers](https://www.indiehackers.com/post/the-3-saas-metrics-that-actually-matter-everything-else-is-founder-entertainment-a558e70890)
- [Baremetrics vs ChartMogul 2026 — QuantLedger](https://www.quantledger.app/blog/baremetrics-vs-chartmogul)
- [Stripe Revenue Reporting Docs](https://docs.stripe.com/revenue-reporting)
- [Lemon Squeezy vs Stripe vs Paddle 2026 — DEV.to](https://dev.to/devtoolpicks/lemon-squeezy-vs-stripe-vs-paddle-which-should-solo-devs-use-in-2026-2jm9)
- [ChurnDog — Indie Hackers](https://www.indiehackers.com/post/i-built-a-tool-to-help-saas-founders-fight-churn-meet-churndog-o1xTaZ1oMeuFRjwSFl1H)
- [I Replaced $130/mo Analytics Stack — Indie Hackers](https://www.indiehackers.com/post/i-replaced-a-130-mo-analytics-stack-with-one-20-dashboard-heres-what-happened-b15a4fd957)
