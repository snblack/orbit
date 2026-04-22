---
title: Frontend
doc_kind: domain
doc_function: canonical
purpose: Шаблон описания UI-поверхностей, design system и i18n-слоя. Читать при работе с web, mobile или internal UI.
derived_from:
  - ../dna/governance.md
status: active
audience: humans_and_agents
---

# Frontend

Этот документ описывает реальный frontend-слой Orbit. Проект не использует отдельный SPA-клиент: основной пользовательский интерфейс построен как server-rendered Rails application с Hotwire-паттернами для интерактивности.

## UI Surfaces

- `public_web` — landing и входные страницы продукта. Код живет в Rails views и layout-слое.
- `auth_flow` — регистрация, вход и переход в onboarding через Devise.
- `onboarding_flow` — пошаговый интерфейс заполнения профиля, интересов, social preferences и геоданных.
- `pod_experience` — просмотр `Pod`, участников, активностей и основного пространства после мэтчинга.
- `pod_chat` — realtime-общение внутри конкретного `Pod` через Action Cable и связанные UI-компоненты.

Boundary с backend здесь проходит внутри одного Rails-монолита: UI не отделен от серверной части как отдельное приложение, поэтому design decisions должны уважать Rails/Hotwire-first модель, а не предполагать независимый frontend runtime.

## Component And Styling Rules

Orbit использует Tailwind в составе Rails-стека, поэтому базовый UI contract следующий:

- сначала предпочитай композицию из существующих Rails partials, utility-классов и Hotwire-паттернов вместо внедрения нового client-side framework;
- ad hoc UI допустим внутри конкретной feature boundary, если он не создает повторно используемый pattern;
- если элемент начинает повторяться между onboarding, pod pages и chat, его нужно оформлять как переиспользуемый view-level pattern, а не копировать разметку;
- сложная интерактивность должна сначала проверяться на реализуемость через Turbo/Stimulus и только потом рассматриваться как исключение;
- стили и состояние интерфейса не должны дублировать domain logic, уже вычисленную на сервере.

## Interaction Patterns

Каноничный interactive stack Orbit:

- server-rendered Rails views как основа всех пользовательских поверхностей;
- Turbo для navigation/update flows, где не нужен отдельный SPA-state;
- Stimulus для локальной клиентской интерактивности, например chat behavior, geolocation и navbar interactions;
- Action Cable для realtime внутри pod chat.

Правила:

- для новых feature используй текущий Rails + Hotwire stack по умолчанию;
- не добавляй параллельный SPA-паттерн без явного архитектурного основания;
- если интерактивность можно реализовать через Turbo frame, partial update или небольшой Stimulus controller, это предпочтительнее тяжелого client-side state management;
- realtime-поведение должно оставаться pod-scoped и не превращаться в глобальный event bus без отдельного решения.

## Localization

Основной источник локализации в Orbit - Rails I18n, в первую очередь `config/locales/ru.yml`.

Правила локализации:

- новые повторно используемые пользовательские строки должны попадать в locale-файлы, а не оставаться захардкоженными по месту без причины;
- если строка завязана на enum, validation или shared UI copy, source of truth должен жить в I18n;
- inline-текст в views допустим как временная мера или для локального copy, но при росте повторного использования его нужно выносить в переводы;
- fallback behavior определяется Rails I18n и не должен переопределяться точечно без documented reason.
