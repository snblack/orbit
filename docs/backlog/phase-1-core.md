# Phase 1: Core — Недели 1–4

Цель: рабочий MVP с онбордингом, матчингом, Pod-дашбордом и реалтайм-чатом.

---

## 1.1 Проект и инфраструктура

- [ ] Создать Rails-приложение (`rails new orbit --database=postgresql`)
- [ ] Установить и настроить Tailwind CSS (`tailwindcss-rails`)
- [ ] Установить Hotwire (`hotwire-rails` или встроен в Rails 7)
- [ ] Настроить Devise (регистрация, логин, подтверждение email)
- [ ] Подключить Sidekiq + Redis (`config/sidekiq.yml`, `Procfile.dev`)
- [ ] Настроить pgvector расширение в PostgreSQL (`CREATE EXTENSION vector`)
- [ ] Установить `neighbor` gem для vector search
- [ ] Настроить ActiveStorage + Cloudflare R2 (для фото профиля)
- [ ] Базовый layout с Tailwind: навигация, мобильный responsive

---

## 1.2 Онбординг-квиз

**Цель:** пользователь проходит структурированный квиз и данные сохраняются в профиль.

- [ ] Модель `User` расширить полями профиля:
  - `life_phase` (enum: recently_moved, career_change, new_parent, remote_worker, etc.)
  - `social_style` (enum: introvert, ambivert, extrovert)
  - `friendship_goal` (enum: support, growth, fun, intellectual)
  - `schedule_preference` (jsonb: дни недели + время)
  - `social_frequency` (enum: once_week, two_three_week, daily)
  - `openness_level` (enum: surface, moderate, deep)
  - `interests` (array: string[])
  - `location_district` (string)
  - `latitude`, `longitude` (float)
  - `onboarding_completed` (boolean)
- [ ] Multi-step форма онбординга (5–6 шагов) с Turbo Frames
- [ ] Шаг 1: Жизненная фаза (radio cards)
- [ ] Шаг 2: Ценности и мироощущение (radio + checkboxes)
- [ ] Шаг 3: Ритм жизни (расписание, частота встреч)
- [ ] Шаг 4: Интересы (checkbox grid + открытое поле)
- [ ] Шаг 5: Геолокация (автоопределение браузером или ручной ввод района)
- [ ] Шаг 6: Фото + короткое видео-представление (15 сек, опционально)
- [ ] Progress bar через весь квиз
- [ ] Валидации на каждом шаге, сохранение через `PATCH /users/:id`

---

## 1.3 Алгоритм матчинга (Phase 1: взвешенный)

**Цель:** собрать Pod из 5 человек без AI, на чистой Ruby-логике.

- [ ] Модели: `Pod`, `PodMembership`
- [ ] `PodMatcher` сервис (`app/services/pod_matcher.rb`):
  - Фильтр по городу/району (Geocoder, радиус ≤ 30 мин)
  - Пересечение окон свободного времени
  - Скоринг совместимости:
    - Жизненная фаза (вес 30%)
    - Тип общения intro/extro (вес 20%)
    - Ценностное сходство (вес 25%)
    - Частота встреч (вес 25%)
  - Группировка в Pod по 5 человек
- [ ] Admin-action или Rake-задача для запуска матчинга вручную
- [ ] После матчинга: email пользователям "Вы попали в Pod"
- [ ] `Connector`-роль: автоматически назначается участнику с наибольшим extroversion

---

## 1.4 Pod Dashboard

**Цель:** главный экран пользователя — всё про его Pod.

- [ ] `PodController#show` — главная страница
- [ ] Список участников Pod: аватар, имя, краткое bio
- [ ] Текущая фаза Pod (1–12 неделя) с описанием что происходит
- [ ] "Last seen together": последняя совместная активность с датой
- [ ] Ближайшая запланированная активность (если есть)
- [ ] Кнопка "Предложить активность"
- [ ] Turbo Frame: обновление без перезагрузки при действиях
- [ ] Страница профиля участника Pod (только для Pod-членов)

---

## 1.5 Realtime чат

**Цель:** групповой чат внутри Pod через ActionCable.

- [ ] Модель `Message` (pod_id, user_id, body, created_at)
- [ ] `PodChannel` — ActionCable channel
- [ ] UI чата: список сообщений + поле ввода
- [ ] Turbo Streams broadcast при новом сообщении
- [ ] Индикатор "онлайн" участников Pod (presence через ActionCable)
- [ ] Автопрокрутка вниз при новых сообщениях (Stimulus controller)
- [ ] Пагинация старых сообщений (load more)
- [ ] Карточки вопросов в чате (статичные 36 Questions на Phase 1)
