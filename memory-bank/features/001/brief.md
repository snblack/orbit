# Brief: Редизайн форм авторизации Devise

Ссылка на задачу: нет (github issue не создан)

## Проблема

Формы sign_in, sign_up, password reset и forgot_password управляются Devise, но кастомные view не сгенерированы — отображаются дефолтные. Они представляют собой сплошной текст без визуального выделения полей ввода: непонятно, куда вводить данные, где кнопка, где ошибки.

## Затрагиваемые формы

- `devise/sessions/new` — вход (email + password)
- `devise/registrations/new` — регистрация (email + password + password confirmation)
- `devise/passwords/new` — forgot password (email)
- `devise/passwords/edit` — reset password (new password + confirmation)

## Требуемые действия

1. Сгенерировать Devise views: `rails generate devise:views`
2. Применить редизайн ко всем четырём формам

## Дизайн-требования

**Стиль:** минимализм в духе Material Design, совместимый с существующими Tailwind-классами проекта.

**Ориентир:** стиль онбординга — `app/views/onboarding/steps/_location.html.erb`:
- Контейнер: `max-w-xl mx-auto`, карточка `bg-white rounded-2xl shadow-sm p-8`
- Поля: `border border-gray-300 rounded-xl px-4 py-3`, focus: `ring-2 ring-indigo-500`
- Label: `block text-sm font-medium text-gray-700 mb-1`
- Primary button: `bg-indigo-600 text-white px-6 py-3 rounded-xl font-medium hover:bg-indigo-700 transition-colors`

**Placeholder-текст** для каждого поля:
- email → `"your@email.com"`
- password → `"Минимум 6 символов"`
- password confirmation → `"Повторите пароль"`
- new password (reset) → `"Новый пароль"`

**Состояния, которые нужно обработать:**
- Ошибки валидации Devise: блок над формой, стиль `bg-red-50 border border-red-200 text-red-700 rounded-xl`
- Кнопка submit: стандартное состояние + hover
- Ссылки между формами ("Уже есть аккаунт? Войти", "Забыли пароль?") — `text-sm text-indigo-600 hover:underline`

## Критерии приёмки

- [ ] Все четыре формы имеют кастомные view в `app/views/devise/`
- [ ] Каждое поле ввода визуально выделено рамкой, имеет label и placeholder
- [ ] Кнопка submit стилизована (indigo фон, hover-эффект)
- [ ] Ошибки валидации отображаются в блоке над формой в red-стиле
- [ ] Формы корректно отображаются на мобильных (≥320px)
- [ ] Визуальный стиль консистентен с онбордингом (те же Tailwind-классы)

## Что НЕ входит в задачу

- Изменение логики Devise (контроллеры, маршруты, модели)
- Email-шаблоны
- Two-factor authentication и прочие расширения
