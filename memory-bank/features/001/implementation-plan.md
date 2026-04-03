# Implementation Plan: Редизайн форм авторизации Devise

**Spec:** `memory-bank/features/001/spec.md`

## Предварительный анализ (grounding)

- `app/views/devise/` — директория отсутствует, создаётся в рамках задачи
- `app/views/layouts/application.html.erb` — flash (`notice`, `alert`) уже рендерятся глобально (строки 83–96); файл **не трогаем**
- Акцентный цвет проекта: `indigo-600`, hover — `indigo-700` (из онбординга и navbar)
- Стиль кнопки-сабмита: `bg-indigo-600 text-white px-6 py-3 rounded-xl font-medium hover:bg-indigo-700 transition-colors` (из `_life_phase.html.erb`)
- Стиль акцентной ссылки navbar: `text-indigo-600 hover:text-indigo-700` + `text-sm`
- Devise роут: `devise_for :users` (стандартный, хелперы `resource`/`resource_name` доступны)
- Тестов нет (`spec/` пуст) — шаг «обновить тесты» пропускается; AC про `bundle exec rspec` выполним trivially (нет тестов — нет упавших)

---

## Шаги

### Шаг 1 — Создать директорию и файл `sessions/new`

**Файл:** `app/views/devise/sessions/new.html.erb` (создать)

Содержимое:
- Контейнер: `max-w-md mx-auto mt-12 px-4`
- Карточка: `bg-white rounded-2xl shadow-md p-8`
- Заголовок: `<h1>` «Войти»
- `form_for(resource, as: resource_name, url: session_path(resource_name))` — стандартный Devise-хелпер
- Поля (label + input):
  - `email` — label «Email», placeholder «your@email.com»
  - `password` — label «Пароль», placeholder «Минимум 6 символов»
- Стиль input: `w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-indigo-500`
- Стиль label: `block text-sm font-semibold text-gray-700 mb-1`
- Кнопка submit «Войти» — стиль акцента
- Ссылки:
  - `new_user_registration_path` — «Нет аккаунта? Зарегистрироваться»
  - `new_user_password_path` — «Забыли пароль?»
  - Стиль: `text-sm text-indigo-600 hover:underline`

**Проверка:** `grep -E "placeholder|label" app/views/devise/sessions/new.html.erb` — оба паттерна присутствуют. Блока `resource.errors` нет (Devise использует flash для ошибок сессии, flash рендерится глобально в layout).

---

### Шаг 2 — Создать файл `registrations/new`

**Файл:** `app/views/devise/registrations/new.html.erb` (создать)

Содержимое:
- Контейнер и карточка — идентично шагу 1
- `form_for(resource, as: resource_name, url: registration_path(resource_name))` — стандартный Devise-хелпер
- Блок ошибок (рендерится только при наличии):
  ```erb
  <% if resource.errors.any? %>
    <div class="bg-red-50 border border-red-200 text-red-800 rounded-lg px-4 py-3 text-sm mb-4">
      <ul><% resource.errors.full_messages.each do |msg| %><li><%= msg %></li><% end %></ul>
    </div>
  <% end %>
  ```
- Поля:
  - `email` — label «Email», placeholder «your@email.com»
  - `password` — label «Пароль», placeholder «Минимум 6 символов»
  - `password_confirmation` — label «Подтверждение пароля», placeholder «Повторите пароль»
- Кнопка submit «Зарегистрироваться»
- Ссылка: `new_user_session_path` — «Уже есть аккаунт? Войти»

**Проверка:** grep по `password_confirmation`, `resource.errors.any?`, трём placeholder'ам.

---

### Шаг 3 — Создать файл `passwords/new`

**Файл:** `app/views/devise/passwords/new.html.erb` (создать)

Содержимое:
- Контейнер и карточка — идентично шагу 1
- `form_for(resource, as: resource_name, url: password_path(resource_name), html: { method: :post })` — стандартный Devise-хелпер
- Блок ошибок (рендерится только при наличии):
  ```erb
  <% if resource.errors.any? %>
    <div class="bg-red-50 border border-red-200 text-red-800 rounded-lg px-4 py-3 text-sm mb-4">
      <ul><% resource.errors.full_messages.each do |msg| %><li><%= msg %></li><% end %></ul>
    </div>
  <% end %>
  ```
- Поля:
  - `email` — label «Email», placeholder «your@email.com»
- Кнопка submit «Отправить инструкции»
- Ссылка: `new_user_session_path` — «Вернуться к входу»

**Проверка:** grep по `resource.errors.any?`, `placeholder`, `new_user_session_path`.

---

### Шаг 4 — Создать файл `passwords/edit`

**Файл:** `app/views/devise/passwords/edit.html.erb` (создать)

Содержимое:
- Контейнер и карточка — идентично шагу 1
- `form_for(resource, as: resource_name, url: password_path(resource_name), html: { method: :put })` + скрытое поле `reset_password_token` — стандартный Devise-хелпер
- Блок ошибок (рендерится только при наличии):
  ```erb
  <% if resource.errors.any? %>
    <div class="bg-red-50 border border-red-200 text-red-800 rounded-lg px-4 py-3 text-sm mb-4">
      <ul><% resource.errors.full_messages.each do |msg| %><li><%= msg %></li><% end %></ul>
    </div>
  <% end %>
  ```
- Поля:
  - `password` — label «Новый пароль», placeholder «Новый пароль»
  - `password_confirmation` — label «Подтверждение пароля», placeholder «Повторите пароль»
- Кнопка submit «Сохранить пароль»
- Ссылок нет

**Проверка:** grep по `reset_password_token`, `resource.errors.any?`, двум placeholder'ам.

---

### Шаг 5 — Финальная проверка

Выполнить последовательно:

1. **Существование файлов:**
   ```
   ls app/views/devise/sessions/new.html.erb
   ls app/views/devise/registrations/new.html.erb
   ls app/views/devise/passwords/new.html.erb
   ls app/views/devise/passwords/edit.html.erb
   ```

2. **Блок ошибок в трёх файлах (не в sessions/new):**
   ```
   grep -rl "resource\.errors\.any?" app/views/devise/
   ```
   Ожидается 3 файла: `registrations/new`, `passwords/new`, `passwords/edit`.

3. **Все label и placeholder из таблицы:**
   ```
   grep -rn "your@email.com\|Минимум 6 символов\|Повторите пароль\|Новый пароль" app/views/devise/
   ```

4. **Flash через layout (не требует изменений):**
   ```
   grep -n "notice\|alert" app/views/layouts/application.html.erb
   ```
   Строки 83–96 уже содержат оба блока — подтверждено на этапе анализа.

5. **Инварианты — не затронуты:**
   ```
   git diff --name-only
   ```
   Только новые файлы в `app/views/devise/`; `config/routes.rb`, `devise.rb`, `User`, layout — без изменений.

---

## Что НЕ входит в план

| Что | Почему |
|---|---|
| Миграции | Только view-слой |
| Изменение `application.html.erb` | Flash уже есть (строки 83–96) |
| Написание/обновление тестов | `spec/` пуст, существующих тестов нет |
| Изменение `tailwind.config.js` | Используются только существующие утилиты Tailwind |
| `mailer`/`shared` Devise-вью | Вне scope |
