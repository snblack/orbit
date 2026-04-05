# Implementation Plan — Feature #003: Pod Dashboard

**Issue:** #3  
**Spec:** `memory-bank/features/003/spec.md`

---

## Фазы и шаги

### Phase 1 — Migrations

**Step 1 — Migration: add `display_name` and `bio` to users**

File: `db/migrate/<timestamp>_add_display_name_and_bio_to_users.rb`

```ruby
def change
  add_column :users, :display_name, :string, null: false, default: ""
  add_column :users, :bio, :text
end
```

Зависимости: нет.  
Проверка: `rails db:migrate` отрабатывает без ошибок; `User.column_names` содержит `display_name` и `bio`.

---

**Step 2 — Migration: create `activities` table**

File: `db/migrate/<timestamp>_create_activities.rb`

Колонки: `pod_id` (bigint, FK, not null), `proposed_by_id` (bigint, FK → users, not null), `occurred_on` (date, not null), `status` (string, not null, default: `"planned"`).  
Индексы: `index_activities_on_pod_id`, `index_activities_on_proposed_by_id`.  
Внешние ключи: `pod_id → pods`, `proposed_by_id → users`.

Зависимости: нет.  
Проверка: `rails db:migrate`; `Activity.column_names` содержит все 4 поля.

---

### Phase 2 — Models

**Step 3 — Update `app/models/user.rb`**

Добавить:
```ruby
validates :bio, length: { maximum: 300 }, allow_blank: true
validates :display_name, presence: true, on: :onboarding_profile
```

Глобальный `validates :display_name, presence: true` намеренно отсутствует: он сломал бы все существующие `save` для пользователей без `display_name` (включая промежуточные шаги онбординга).

Зависимости: Step 1 (колонка должна существовать).  
Проверка: `build(:user, display_name: nil).valid?` → true; `build(:user, display_name: nil).valid?(:onboarding_profile)` → false с ошибкой на display_name.

---

**Step 4 — Create `app/models/activity.rb`**

```ruby
class Activity < ApplicationRecord
  belongs_to :pod
  belongs_to :proposed_by, class_name: "User", foreign_key: :proposed_by_id

  enum :status, { completed: "completed", planned: "planned" }

  validates :occurred_on, presence: true
  validates :status, presence: true
  validate :occurred_on_not_in_past, on: :create, if: :planned?

  private

  def occurred_on_not_in_past
    return if occurred_on.blank?
    errors.add(:occurred_on, :past_date) if occurred_on < Date.today
  end
end
```

Также добавить в `app/models/pod.rb`:
```ruby
has_many :activities, dependent: :destroy
```

Зависимости: Step 2 (таблица должна существовать).  
Проверка: `build(:activity, occurred_on: Date.yesterday).valid?` → false, ошибка именно на `occurred_on` (past_date); `build(:activity, occurred_on: Date.today).valid?` → true. Использование фабрики обязательно — `Activity.new(...)` без заполненных `pod` и `proposed_by` даст false сразу из-за `belongs_to`, не изолируя проверяемую валидацию. `Pod.new.respond_to?(:activities)` → true.

---

### Phase 3 — I18n

**Step 5 — Create `config/locales/ru.yml`**

Содержимое:
```yaml
ru:
  date:
    formats:
      long: "%-d %B %Y"
    month_names:
      - ~
      - января
      - февраля
      - марта
      - апреля
      - мая
      - июня
      - июля
      - августа
      - сентября
      - октября
      - ноября
      - декабря
  activerecord:
    errors:
      models:
        activity:
          attributes:
            occurred_on:
              past_date: "должна быть сегодня или позже"
  onboarding:
    life_phase:
      recently_moved: "Недавно переехал(а)"
      career_change: "Смена карьеры"
      new_parent: "Молодой родитель"
      remote_worker: "Удалённая работа"
      student: "Студент"
      retired: "На пенсии"
      other: "Другое"
    friendship_goal:
      support: "Поддержка"
      growth: "Рост"
      fun: "Развлечения"
      intellectual: "Интеллектуальное общение"
    interests:
      hiking: "Природа и хайкинг"
      coffee: "Кофейни и посиделки"
      books: "Книги и чтение"
      tech: "Технологии"
      music: "Музыка"
      fitness: "Фитнес и спорт"
      cooking: "Готовка и еда"
      art: "Искусство и культура"
      travel: "Путешествия"
      gaming: "Игры"
      movies: "Кино и сериалы"
      meditation: "Медитация и осознанность"
      volunteering: "Волонтёрство"
      startups: "Стартапы и бизнес"
      languages: "Языки"
      photography: "Фотография"
```

Зависимости: нет.  
Проверка: `rails runner "puts I18n.l(Date.new(2026, 4, 5), format: :long)"` выводит «5 апреля 2026».

---

**Step 5a — Update `config/application.rb`: установить локаль по умолчанию**

В блок `class Application < Rails::Application` добавить:
```ruby
config.i18n.default_locale = :ru
config.i18n.available_locales = [:ru, :en]
config.i18n.fallbacks = [:en]
```

`default_locale = :ru` необходима, иначе `I18n.l(date, format: :long)` использует `:en` и русские названия месяцев из `ru.yml` не применяются.  
`fallbacks = [:en]` обязательна: в проекте используется `devise` без `devise-i18n`, т.е. `ru`-переводов для Devise нет (`config/locales/devise.en.yml` — единственный файл). Без фоллбэка на `:en` все Devise flash-сообщения покажутся как `[missing "ru.devise.sessions.signed_in" translation]`. Rails не включает fallbacks автоматически; `available_locales` нужен для корректной работы fallbacks в Rails 8.

Зависимости: Step 5 (файл `ru.yml` должен существовать).  
Проверка: `rails runner "puts I18n.locale"` выводит `ru`; вход через Devise показывает нормальный flash, а не `[missing ...]`.

---

### Phase 4 — Onboarding: шаг `profile`

**Step 6 — Create `app/views/onboarding/steps/_profile.html.erb`**

Форма с двумя полями: `display_name` (text_field, required) и `bio` (text_area, optional, maxlength 300).  
При ошибке (response 422) показывает inline-ошибку рядом с `display_name`.  
Стиль: консистентен с существующими шагами (_life_phase.html.erb и т.д.).

Зависимости: Step 5 (для возможных переводов), Step 1 (поля существуют).  
Проверка: `GET /onboarding/profile` рендерится без ошибок.

---

**Step 7 — Update `app/controllers/onboarding_controller.rb`**

1. Добавить `"profile"` в конец `STEPS`:
   ```ruby
   STEPS = %w[life_phase values rhythm interests location media profile].freeze
   ```
2. Добавить ветку в `step_params`:
   ```ruby
   when "profile"
     params.require(:user).permit(:display_name, :bio)
   ```

Зависимости: Step 6.  
Проверка: `PATCH /onboarding/profile` с пустым `display_name` → 422 + форма с ошибкой; с валидным `display_name` → редирект на root с notice.

---

### Phase 5 — Routes

**Step 8 — Update `config/routes.rb`**

```ruby
resources :pods, only: [:show] do
  resources :activities, only: [:new, :create]
  resources :members, only: [:show]
end
```

Это даёт:
- `GET  /pods/:id`                               → `pods#show`
- `GET  /pods/:pod_id/activities/new`            → `activities#new`
- `POST /pods/:pod_id/activities`                → `activities#create`
- `GET  /pods/:pod_id/members/:id`               → `members#show`

Зависимости: нет (контроллеры ещё не нужны на этом шаге).  
Проверка: `rails routes | grep pods` показывает все 4 маршрута.

---

### Phase 6 — Controllers

**Step 9 — Create `app/controllers/pods_controller.rb`**

```ruby
class PodsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pod

  def show
    @members = @pod.users
    @week_number = (Date.today - @pod.created_at.to_date).to_i / 7 + 1
    @last_activity = @pod.activities.completed.order(occurred_on: :desc).first
    @next_activity = @pod.activities.planned.where("occurred_on >= ?", Date.today)
                         .order(occurred_on: :asc).first
  end

  private

  def set_pod
    @pod = current_user.pods.find_by(id: params[:id])
    render file: "public/404.html", status: :not_found, layout: false if @pod.nil?
  end
end
```

Зависимости: Steps 4, 8.  
Проверка: `GET /pods/:id` своего Pod → 200; чужого Pod → 404.

---

**Step 10 — Create `app/controllers/activities_controller.rb`**

```ruby
class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pod

  def new
    @activity = @pod.activities.build
  end

  def create
    @activity = @pod.activities.build(activity_params)
    @activity.proposed_by = current_user

    if @activity.save
      redirect_to pod_path(@pod)
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::StatementInvalid
    flash.now[:alert] = "Ошибка сервера. Попробуйте ещё раз."
    render :new, status: :internal_server_error
  end

  private

  def set_pod
    @pod = current_user.pods.find_by(id: params[:pod_id])
    render file: "public/404.html", status: :not_found, layout: false if @pod.nil?
  end

  def activity_params
    params.require(:activity).permit(:occurred_on)
  end
end
```

Зависимости: Steps 4, 8, 9 (паттерн `set_pod`).  
Проверка: `POST /pods/:pod_id/activities` с прошедшей датой → 422 + форма с ошибкой; с корректной датой → redirect to pod_path.

---

**Step 11 — Create `app/controllers/members_controller.rb`**

```ruby
class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pod
  before_action :set_member

  def show; end

  private

  def set_pod
    @pod = current_user.pods.find_by(id: params[:pod_id])
    render file: "public/404.html", status: :not_found, layout: false if @pod.nil?
  end

  def set_member
    @member = @pod.users.find_by(id: params[:id])
    render file: "public/404.html", status: :not_found, layout: false if @member.nil?
  end
end
```

Зависимости: Step 8.  
Проверка: `GET /pods/:pod_id/members/:id` для члена Pod → 200; для не-члена → 404.

---

### Phase 7 — Helpers

**Step 12 — Update `app/helpers/application_helper.rb`**

Добавить в существующий модуль `ApplicationHelper`:
```ruby
def initials_for(user)
  name = user.display_name.presence || user.email
  name.split.first(2).map { |w| w[0].upcase }.join
end

def avatar_color_for(user)
  "hsl(#{(user.id * 37) % 360}, 55%, 65%)"
end
```

Фallback на email нужен потому, что `display_name` имеет `default: ""` — пользователи, не завершившие шаг `profile`, будут показываться с пустым кругом без этой защиты. Для таких пользователей инициал берётся из первой части email до `@`.

Хелперы размещаются в `ApplicationHelper`, а не в отдельном `PodsHelper`, чтобы быть доступными во всех контроллерах — в частности, в `MembersController`, чьё представление `members/show.html.erb` тоже использует `initials_for` и `avatar_color_for`.

Зависимости: Step 1.  
Проверка: `initials_for(User.new(display_name: "Alice Smith", email: "a@b.com"))` → `"AS"`; `initials_for(User.new(display_name: "", email: "alice@example.com"))` → `"A"`.

---

### Phase 8 — Views

**Step 13 — Extract flash partial**

1. Создать `app/views/shared/_flash.html.erb` — перенести в него текущие inline-блоки notice/alert из `application.html.erb`.
2. В `application.html.erb` заменить inline-блоки на `<%= render 'shared/flash' %>`.

Зависимости: нет.  
Проверка: Flash-сообщения продолжают отображаться после входа/выхода.

---

**Step 14 — Create `app/views/pods/show.html.erb`**

Секции:
- **Аватар-инициалы участников** через helper `initials_for(user)` и `avatar_color_for(user)`.
  - `initials_for`: первые буквы первых двух слов `display_name` (upcase).
  - `avatar_color_for`: `"hsl(#{(user.id * 37) % 360}, 55%, 65%)"`.
- **Список участников**: каждый — ссылка на `pod_member_path(@pod, member)` с аватаром.
- **Если pod.active?**:
  - Номер недели: `@week_number`.
  - Блок «последняя активность»: `@last_activity` если есть, иначе «Ещё не встречались» (блок всегда в DOM).
  - Дата через `I18n.l(@last_activity.occurred_on, format: :long)`.
  - Блок «ближайшая активность»: рендерится только если `@next_activity.present?` (отсутствует в DOM если nil).
  - Turbo Frame + кнопка «Предложить активность». Оба элемента должны быть **прямыми дочерними** одного контейнера — правило `~` работает только между сиблингами на одном уровне DOM:
    ```erb
    <div>
      <%= turbo_frame_tag "new_activity_form" do %><%- end %>
      <%= link_to "Предложить активность",
            new_pod_activity_path(@pod),
            data: { turbo_frame: "new_activity_form" },
            class: "..." %>
    </div>
    ```
    Кнопка скрывается через CSS: добавить в `app/assets/tailwind/application.css` после строки `@import "tailwindcss"` правило `turbo-frame:not(:empty) ~ a { display: none }`. Этот файл является источником компиляции Tailwind → `app/assets/builds/tailwind.css`; `app/assets/stylesheets/application.css` содержит только Propshaft-комментарий и не является активным источником CSS. Если обернуть кнопку или фрейм в дополнительный `<div>`, правило перестанет работать без ошибок — нарушение DOM-структуры здесь не диагностируется.
- **Если pod.inactive?**: список участников + плашка «Группа ещё формируется». Блоки активностей, ближайшей активности и кнопка — не рендерятся (отсутствуют в DOM).

Зависимости: Steps 9, 12, 13.  
Проверка: Вручную — активный Pod показывает все блоки; неактивный — только список и плашку.

---

**Step 15 — Create `app/views/activities/new.html.erb`**

Содержимое — только `turbo_frame_tag "new_activity_form"` с формой внутри:
```erb
<%= turbo_frame_tag "new_activity_form" do %>
  <%= form_with model: [@pod, @activity] do |f| %>
    <%# occurred_on date picker %>
    <%# error messages %>
    <%= f.submit "Предложить" %>
  <% end %>
<% end %>
```

При ошибке валидации контроллер возвращает 422 — Turbo обновит только фрейм.

Зависимости: Steps 10, 14.  
Проверка: Клик по «Предложить активность» загружает форму в фрейм; кнопка скрывается.

---

**Step 16 — Create `app/views/members/show.html.erb`**

Показывает: `@member.display_name`, `@member.bio` (если present?), аватар-инициалы, `life_phase`, `friendship_goal`, `interests` — все через I18n (`t("onboarding.life_phase.#{@member.life_phase}")` и аналогично для `friendship_goal` и каждого элемента `interests`).

Зависимости: Steps 5, 11, 12.  
Проверка: `/pods/:pod_id/members/:id` отображает все поля участника.

---

### Phase 9 — Navigation

**Step 17 — Update `app/views/layouts/application.html.erb`**

В блоке десктоп-меню (`hidden sm:flex`) после email добавить ссылку «Мой Pod»:
```erb
<% if user_signed_in? && (my_pod = current_user.pods.order(created_at: :desc).first) %>
  <%= link_to "Мой Pod", pod_path(my_pod), class: "text-sm text-indigo-600 font-medium hover:text-indigo-800" %>
<% end %>
```

Продублировать в мобильном меню (`data-navbar-target="menu"`).

Зависимости: Steps 8, 13 (flash partial уже вынесен).  
Проверка: Авторизованный пользователь с Pod видит «Мой Pod»; без Pod — не видит.

---

### Phase 10 — Seeds

**Step 18 — Update `db/seeds.rb`**

Структура нового seed (идемпотентный):

Порядок очистки в начале файла:
```ruby
Activity.delete_all                                     # до Pod — иначе FK constraint
Notification.delete_all
PodMembership.delete_all
Pod.delete_all
User.where(email: %w[alice@example.com bob@example.com
                     inactive_user@example.com inactive_buddy@example.com]).delete_all
User.where("email LIKE 'seed\\_%'").delete_all
```

1. Создать `alice@example.com` и `bob@example.com` с `display_name`, `bio`, всеми полями профиля, `onboarding_completed: true`.
2. Создать `inactive_user@example.com` и `inactive_buddy@example.com` для неактивного Pod.
3. Создать активный Pod с `created_at: 14.days.ago`, создать `PodMembership` для alice и bob.
4. Создать неактивный Pod (`status: "inactive"`), создать `PodMembership` для inactive_user и inactive_buddy.
5. Создать `Activity` (status: completed, occurred_on: 10.days.ago) для активного Pod (proposed_by: alice).
6. Создать `Activity` (status: planned, occurred_on: 3.days.from_now) для активного Pod (proposed_by: bob).
7. Сохранить 20 seed-пользователей для matching (как сейчас, добавить `display_name`).

Зависимости: Steps 1, 2, 3, 4.  
Проверка: `rails db:seed` без ошибок; alice входит и видит Dashboard с «Неделя 3».

---

### Phase 11 — Tests

**Step 19 — Update `spec/factories/users.rb`**

Добавить `sequence(:display_name) { |n| "User #{n}" }`, `bio { nil }` и `interests { [] }`.

`interests { [] }` обязательно: `members/show.html.erb` (Step 16) итерирует `@member.interests` через I18n. Если колонка не имеет DB-дефолта `[]`, неинициализированное поле будет `nil`, и вызов `.each` в шаблоне упадёт с `NoMethodError`. Без этого спека Step 24 (`members_controller_spec`) упадёт на `GET members#show` со статусом 200.

Зависимости: Step 1.  
Проверка: `FactoryBot.build(:user).display_name` не nil; `FactoryBot.build(:user).interests` → `[]`.

---

**Step 20 — Create `spec/factories/activities.rb`**

```ruby
FactoryBot.define do
  factory :activity do
    association :pod
    association :proposed_by, factory: :user
    occurred_on { Date.today + 3 }
    status { :planned }
  end
end
```

Зависимости: Steps 2, 4.

---

**Step 21 — Create `spec/models/activity_spec.rb`**

Тесты:
- `planned` activity с `occurred_on: Date.yesterday` → invalid (past_date error).
- `planned` activity с `occurred_on: Date.today` → valid.
- `completed` activity с `occurred_on: Date.yesterday` → valid (нет проверки прошлого для completed).

Зависимости: Steps 4, 19, 20.  
Проверка: `bundle exec rspec spec/models/activity_spec.rb` — все green.

---

**Step 21a — Create `spec/models/user_spec.rb`**

Тесты для новых валидаций User (используем фабрику, чтобы Devise-валидации не мешали):
- `build(:user, display_name: nil).valid?` → true (нет контекста — display_name не проверяется).
- `build(:user, display_name: nil).valid?(:onboarding_profile)` → false, ошибка на `display_name`.
- `build(:user, display_name: "Alice").valid?(:onboarding_profile)` → true.
- `build(:user, bio: "x" * 301).valid?` → false, ошибка на `bio`.
- `build(:user, bio: "x" * 300).valid?` → true.

Зависимости: Steps 1, 3, 19.  
Проверка: `bundle exec rspec spec/models/user_spec.rb` — все green.

---

**Step 21b — Update `spec/rails_helper.rb`**

Добавить в блок `RSpec.configure`:
```ruby
config.include Devise::Test::ControllerHelpers, type: :controller
```

Без этого `sign_in(user)` в контроллер-спеках упадёт с `NoMethodError` — `infer_spec_type_from_file_location!` в проекте отключён, поэтому хелперы Devise не подключаются автоматически.

Зависимости: нет.  
Проверка: `sign_in(build(:user))` вызывается в спеке с `type: :controller` без `NoMethodError`.

---

**Step 22 — Create `spec/controllers/pods_controller_spec.rb`**

Использовать `RSpec.describe PodsController, type: :controller` (явно, т.к. `infer_spec_type_from_file_location!` отключён).

Тесты:
- Неавторизованный GET `/pods/:id` → redirect to sign_in.
- Авторизованный GET `/pods/:id` своего Pod → 200.
- Авторизованный GET `/pods/:id` чужого Pod → 404.

Зависимости: Steps 9, 19, 21b.

---

**Step 23 — Create `spec/controllers/activities_controller_spec.rb`**

Использовать `RSpec.describe ActivitiesController, type: :controller`.

Тесты:
- POST с прошедшей датой → 422.
- POST с корректной датой → redirect to pod_path.
- POST → `Activity.save` raises `ActiveRecord::StatementInvalid` → 500 + flash[:alert].

Зависимости: Steps 10, 20, 21b.

---

**Step 24 — Create `spec/controllers/members_controller_spec.rb`**

Использовать `RSpec.describe MembersController, type: :controller`.

Тесты:
- GET члена своего Pod → 200.
- GET пользователя не из Pod → 404.
- GET с чужим pod_id → 404.

Зависимости: Steps 11, 19, 21b.

---

## Порядок выполнения (линейный)

```
1 → 2 → 3 → 4 → 5 → 5a → 6 → 7 → 8 → 9 → 10 → 11 → 12 → 13 → 14 → 15 → 16 → 17 → 18 → 19 → 20 → 21 → 21a → 21b → 22 → 23 → 24
```

Steps 1 и 2 можно выполнять параллельно (независимые миграции).  
Steps 5 и 5a можно выполнять параллельно (независимые файлы конфигурации).  
Steps 19 и 20 можно выполнять параллельно (независимые фабрики).  
Steps 21, 21a и 21b можно выполнять параллельно (независимые спеки моделей + rails_helper).  
Steps 22, 23, 24 можно выполнять параллельно (независимые спеки контроллеров).

---

## Контрольный список затрагиваемых файлов

| Файл | Действие |
|------|----------|
| `db/migrate/*_add_display_name_and_bio_to_users.rb` | create |
| `db/migrate/*_create_activities.rb` | create |
| `app/models/user.rb` | update |
| `app/models/activity.rb` | create (+ update `pod.rb`: `has_many :activities`) |
| `config/locales/ru.yml` | create |
| `config/application.rb` | update (`default_locale = :ru`) |
| `app/views/onboarding/steps/_profile.html.erb` | create |
| `app/controllers/onboarding_controller.rb` | update (STEPS + step_params) |
| `config/routes.rb` | update |
| `app/controllers/pods_controller.rb` | create |
| `app/controllers/activities_controller.rb` | create |
| `app/controllers/members_controller.rb` | create |
| `app/helpers/application_helper.rb` | update (`initials_for`, `avatar_color_for`) |
| `app/views/shared/_flash.html.erb` | create |
| `app/views/layouts/application.html.erb` | update (flash partial + nav link) |
| `app/assets/tailwind/application.css` | update (turbo-frame hide rule) |
| `spec/rails_helper.rb` | update (Devise::Test::ControllerHelpers) |
| `app/views/pods/show.html.erb` | create |
| `app/views/activities/new.html.erb` | create |
| `app/views/members/show.html.erb` | create |
| `db/seeds.rb` | update |
| `spec/factories/users.rb` | update |
| `spec/factories/activities.rb` | create |
| `spec/models/activity_spec.rb` | create |
| `spec/models/user_spec.rb` | create |
| `spec/controllers/pods_controller_spec.rb` | create |
| `spec/controllers/activities_controller_spec.rb` | create |
| `spec/controllers/members_controller_spec.rb` | create |
