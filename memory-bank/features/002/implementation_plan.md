# Implementation Plan: Алгоритм матчинга пользователей в Pod

Ссылка на spec: memory-bank/features/002/spec.md
Ссылка на brief: memory-bank/features/002/brief.md

---

## Предусловия

- Rails 8.1.3, PostgreSQL
- Таблица `users` со всеми полями онбординга уже существует (`db/schema.rb`)
- RSpec и FactoryBot **не установлены** (в `Gemfile` только minitest/capybara)
- `lib/tasks/` существует, но пустая
- `app/services/` **не существует** — создаётся в шаге 10

---

## Шаги

### Шаг 1 — Добавить RSpec и FactoryBot

**Файл:** `Gemfile`

Добавить в `group :development, :test`:
```ruby
gem "rspec-rails"
gem "factory_bot_rails"
```

Затем выполнить:
```bash
bundle install
rails generate rspec:install
```

`rails generate rspec:install` создаст: `spec/`, `spec/spec_helper.rb`, `spec/rails_helper.rb`, `.rspec`.

**Проверка:** `bundle exec rspec` выполняется без ошибок (0 примеров).

---

### Шаг 2 — Миграция: таблица `pods`

**Новый файл:** `db/migrate/<timestamp>_create_pods.rb`

```ruby
create_table :pods do |t|
  t.string :status, null: false, default: "inactive"
  t.timestamps
end
```

Запустить `rails db:migrate`.

**Проверка:** `db/schema.rb` содержит таблицу `pods` с полем `status`.

---

### Шаг 3 — Миграция: таблица `pod_memberships`

**Новый файл:** `db/migrate/<timestamp>_create_pod_memberships.rb`

```ruby
create_table :pod_memberships do |t|
  t.references :pod,  null: false, foreign_key: true
  t.references :user, null: false, foreign_key: true
  t.datetime :created_at, null: false
end
add_index :pod_memberships, [:pod_id, :user_id], unique: true
```

Запустить `rails db:migrate`.

**Проверка:** `db/schema.rb` содержит `pod_memberships` с FK на `pods` и `users`.

---

### Шаг 4 — Миграция: таблица `notifications`

**Новый файл:** `db/migrate/<timestamp>_create_notifications.rb`

```ruby
create_table :notifications do |t|
  t.references :user, null: false, foreign_key: true
  t.references :pod,  null: false, foreign_key: true
  t.string  :message, null: false
  t.boolean :read, null: false, default: false
  t.datetime :created_at, null: false
end
```

Запустить `rails db:migrate`.

**Проверка:** `db/schema.rb` содержит `notifications` с FK на `users` и `pods`.

---

### Шаг 5 — Модель `Pod`

**Новый файл:** `app/models/pod.rb`

```ruby
class Pod < ApplicationRecord
  has_many :pod_memberships, dependent: :destroy
  has_many :users, through: :pod_memberships
  has_many :notifications, dependent: :destroy

  enum :status, { inactive: "inactive", active: "active" }

  validates :status, presence: true
end
```

**Проверка:** `Pod.new(status: "active").valid?` → true в rails console.

---

### Шаг 6 — Модель `PodMembership`

**Новый файл:** `app/models/pod_membership.rb`

```ruby
class PodMembership < ApplicationRecord
  belongs_to :pod
  belongs_to :user

  validates :pod_id, uniqueness: { scope: :user_id }
end
```

**Проверка:** попытка создать дублирующую запись отклоняется валидацией.

---

### Шаг 7 — Модель `Notification`

**Новый файл:** `app/models/notification.rb`

```ruby
class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :pod

  validates :message, presence: true
end
```

**Проверка:** `Notification.new.valid?` → false (message blank, user/pod missing).

---

### Шаг 8 — Обновить модель `User`

**Файл:** `app/models/user.rb`

Добавить ассоциации (после строки `devise ...`):
```ruby
has_many :pod_memberships, dependent: :destroy
has_many :pods, through: :pod_memberships
has_many :notifications, dependent: :destroy
```

Добавить scope для матчингового пула:
```ruby
scope :matching_pool, -> {
  left_joins(:pod_memberships)
    .where(pod_memberships: { id: nil })
    .where(onboarding_completed: true)
    .where.not(latitude: nil)
    .where.not(longitude: nil)
    .order(:id)
}
```

**Проверка:** `User.matching_pool.to_sql` не падает; существующие тесты в `test/models/user_test.rb` проходят.

---

### Шаг 9 — Интеграция FactoryBot с RSpec

**Файл:** `spec/rails_helper.rb`

После блока `RSpec.configure do |config|` добавить:
```ruby
config.include FactoryBot::Syntax::Methods
```

`rails generate rspec:install` не добавляет этот хелпер автоматически. Без него `create()` / `build()` в тестах упадут с `NoMethodError`.

**Проверка:** `bundle exec rspec` — 0 ошибок; `FactoryBot::Syntax::Methods` включён.

---

### Шаг 9а — FactoryBot: фабрики

**Новые файлы:**

`spec/factories/users.rb`
```ruby
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password" }
    confirmed_at { Time.current }
    onboarding_completed { true }
    latitude  { 53.9 }
    longitude { 27.5 }
    life_phase       { :student }
    social_style     { :introvert }
    friendship_goal  { :growth }
    openness_level   { :moderate }
    social_frequency { :once_week }
    schedule_preference { {} }
  end
end
```

`spec/factories/pods.rb`
```ruby
FactoryBot.define do
  factory :pod do
    status { "inactive" }
  end
end
```

`spec/factories/pod_memberships.rb`
```ruby
FactoryBot.define do
  factory :pod_membership do
    association :pod
    association :user
  end
end
```

`spec/factories/notifications.rb`
```ruby
FactoryBot.define do
  factory :notification do
    association :user
    association :pod
    message { "Вы вошли в группу" }
    read    { false }
  end
end
```

**Проверка:** `bundle exec rspec` — 0 ошибок (factories загружаются без исключений).

---

### Шаг 10 — Сервис `MatchingService`

**Создать директорию:**
```bash
mkdir app/services
```

**Новый файл:** `app/services/matching_service.rb`

```ruby
class MatchingService
  RADII_KM            = [5, 10, 15, 20, 25, 30].freeze
  MIN_POD_SIZE        = 5
  SCORE_THRESHOLD     = 3
  POD_CANDIDATE_COUNT = 4

  SIMPLE_FIELDS = %i[life_phase social_style friendship_goal
                     openness_level social_frequency].freeze

  def self.run = new.run

  def run
    pool = User.matching_pool.to_a
    return "Not enough users to form a pod." if pool.size < MIN_POD_SIZE

    # Основной цикл: пока в пуле достаточно для полного пода
    until pool.size < MIN_POD_SIZE
      anchor     = pool.shift
      candidates = find_candidates(anchor, pool)
      members    = [anchor] + candidates
      status     = candidates.size >= POD_CANDIDATE_COUNT ? "active" : "inactive"

      create_pod(members, status)
      pool -= members
    end

    # Остаток 1–4 пользователей → один общий inactive pod (AC-8)
    create_pod(pool, "inactive") unless pool.empty?
  end

  private

  # Возвращает до 4 кандидатов из pool с расширяющимся радиусом (AC-6)
  def find_candidates(anchor, pool)
    RADII_KM.each do |radius|
      within = pool.select { |u| haversine(anchor, u) <= radius }
      scored = within
        .map    { |u| [u, compatibility_score(anchor, u)] }
        .select { |_, s| s >= SCORE_THRESHOLD }
        .sort_by { |u, s| [-s, u.id] }

      return scored.first(POD_CANDIDATE_COUNT).map(&:first) if scored.size >= POD_CANDIDATE_COUNT
    end

    # Радиус исчерпан — берём лучших в пределах 30 км, не выходя за него
    pool
      .select { |u| haversine(anchor, u) <= RADII_KM.last }
      .map    { |u| [u, compatibility_score(anchor, u)] }
      .select { |_, s| s >= SCORE_THRESHOLD }
      .sort_by { |u, s| [-s, u.id] }
      .first(POD_CANDIDATE_COUNT)
      .map(&:first)
  end

  def compatibility_score(a, b)
    score = SIMPLE_FIELDS.sum do |field|
      val_a = a.public_send(field)
      val_b = b.public_send(field)
      val_a && val_b && val_a == val_b ? 1 : 0
    end
    score + schedule_score(a.schedule_preference, b.schedule_preference)
  end

  def schedule_score(sp_a, sp_b)
    a = (sp_a || {}).transform_keys(&:to_s)
    b = (sp_b || {}).transform_keys(&:to_s)
    n = (a.keys & b.keys).size
    return 0 if n == 0
    1 + (n - 1) * 0.2
  end

  def haversine(u1, u2)
    rad = Math::PI / 180
    dlat = (u2.latitude  - u1.latitude)  * rad
    dlon = (u2.longitude - u1.longitude) * rad
    lat1 = u1.latitude * rad
    lat2 = u2.latitude * rad
    a = Math.sin(dlat / 2)**2 +
        Math.cos(lat1) * Math.cos(lat2) * Math.sin(dlon / 2)**2
    6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  end

  def create_pod(members, status)
    pod = Pod.create!(status: status)
    members.each do |user|
      PodMembership.create!(pod: pod, user: user)
      Notification.create!(user: user, pod: pod, message: "Вы вошли в группу", read: false)
    end
  end
end
```

**Проверка:** `MatchingService.new.send(:haversine, ...)` возвращает ожидаемое расстояние в rails console. Сценарий 7 пользователей: 5 → active pod, 2 оставшихся → один inactive pod.

---

### Шаг 11 — Rake task `matching:run`

**Новый файл:** `lib/tasks/matching.rake`

```ruby
namespace :matching do
  desc "Run the matching algorithm to form Pods"
  task run: :environment do
    result = MatchingService.run
    puts result if result.is_a?(String)
  end
end
```

**Проверка:** `rails matching:run` выполняется без исключений на пустой БД (выводит сообщение).

---

### Шаг 12 — RSpec-тесты: `MatchingService`

**Создать директорию:**
```bash
mkdir spec/services
```

**Новый файл:** `spec/services/matching_service_spec.rb`

```ruby
require "rails_helper"

RSpec.describe MatchingService do
  # Хелпер: создаёт пользователя рядом с координатами (lat, lon),
  # полностью совместимого с дефолтными настройками фабрики.
  def nearby_user(lat: 53.9, lon: 27.5, **attrs)
    create(:user, latitude: lat, longitude: lon, **attrs)
  end

  describe ".run" do
    context "AC-11: начальный пул меньше 5 пользователей" do
      it "возвращает сообщение и не создаёт pod" do
        create_list(:user, 3)
        result = nil
        expect { result = MatchingService.run }.not_to change(Pod, :count)
        expect(result).to eq("Not enough users to form a pod.")
      end
    end

    context "AC-1: 5+ совместимых пользователей рядом" do
      it "создаёт active pod из 5 участников" do
        create_list(:user, 5, latitude: 53.9, longitude: 27.5)
        MatchingService.run
        pod = Pod.last
        expect(pod.status).to eq("active")
        expect(pod.users.count).to eq(5)
      end
    end

    context "AC-2: пользователи без onboarding_completed исключаются" do
      it "не включает неонбордированных в pod" do
        create_list(:user, 5, latitude: 53.9, longitude: 27.5)
        excluded = create(:user, latitude: 53.9, longitude: 27.5, onboarding_completed: false)
        MatchingService.run
        expect(Pod.all.flat_map(&:users)).not_to include(excluded)
      end
    end

    context "AC-3: идемпотентность — пользователи уже в поде пропускаются" do
      it "не добавляет их повторно при повторном запуске" do
        create_list(:user, 5, latitude: 53.9, longitude: 27.5)
        MatchingService.run
        expect { MatchingService.run }.not_to change(Pod, :count)
      end
    end

    context "AC-4: score < 3 → кандидат не попадает в pod" do
      it "не добавляет несовместимого пользователя в active pod" do
        # 5 совместимых + 1 с нулевым score (все поля отличаются)
        create_list(:user, 5, latitude: 53.9, longitude: 27.5)
        incompatible = create(:user,
          latitude: 53.9, longitude: 27.5,
          life_phase: :retired,
          social_style: :extrovert,
          friendship_goal: :fun,
          openness_level: :deep,
          social_frequency: :daily,
          schedule_preference: {}
        )
        MatchingService.run
        active_pods = Pod.where(status: "active")
        expect(active_pods.flat_map(&:users)).not_to include(incompatible)
      end
    end

    context "AC-5: schedule_score" do
      it "возвращает 1.0 при одном совпадающем слоте" do
        service = MatchingService.new
        expect(service.send(:schedule_score, { "mon" => true }, { "mon" => true })).to eq(1.0)
      end

      it "возвращает 1.4 при трёх совпадающих слотах" do
        a = { "mon" => true, "wed" => true, "fri" => true }
        service = MatchingService.new
        expect(service.send(:schedule_score, a, a)).to eq(1.4)
      end
    end

    context "AC-6: радиус не выходит за 30 км" do
      it "не включает пользователя за пределами 30 км в active pod" do
        create_list(:user, 5, latitude: 53.9, longitude: 27.5)
        # ~111 км севернее
        far_user = create(:user, latitude: 54.9, longitude: 27.5)
        MatchingService.run
        # far_user не попадает в active pod (нет совместимых соседей в радиусе 30 км),
        # но оказывается в inactive pod как остаток пула — это ожидаемое поведение
        expect(Pod.where(status: "active").flat_map(&:users)).not_to include(far_user)
        expect(Pod.where(status: "inactive").flat_map(&:users)).to include(far_user)
      end
    end

    context "AC-7: кандидатов < 4 в радиусе 30 км → inactive pod" do
      it "создаёт inactive pod когда не набирается 4 кандидата" do
        # 4 пользователя рядом (включая anchor) + 2 далеко (> 30 км) — итого 6 ≥ MIN_POD_SIZE
        # anchor находит 3 кандидата в радиусе 30 км (< POD_CANDIDATE_COUNT=4) → inactive pod
        create_list(:user, 4, latitude: 53.9, longitude: 27.5)
        create_list(:user, 2, latitude: 54.9, longitude: 27.5) # ~111 км севернее
        MatchingService.run
        expect(Pod.first.status).to eq("inactive")
      end
    end

    context "AC-8: остаток пула < 5 → один inactive pod" do
      it "собирает 2 оставшихся в один inactive pod" do
        # 7 пользователей: 5 → active pod, 2 → inactive pod
        create_list(:user, 7, latitude: 53.9, longitude: 27.5)
        MatchingService.run
        inactive_pods = Pod.where(status: "inactive")
        expect(inactive_pods.count).to eq(1)
        expect(inactive_pods.first.users.count).to eq(2)
      end
    end

    context "AC-9: тайбрейкер по id" do
      it "при равном score выбирает пользователя с меньшим id" do
        anchor = nearby_user
        # Два одинаково совместимых кандидата — берётся тот, у кого id меньше
        lower  = nearby_user
        higher = nearby_user
        create_list(:user, 3, latitude: 53.9, longitude: 27.5)

        MatchingService.run

        pod = Pod.joins(:pod_memberships)
                 .where(pod_memberships: { user_id: anchor.id })
                 .first
        expect(pod.users).to include(lower)
      end
    end

    context "AC-10: уведомления" do
      it "каждый участник получает Notification 'Вы вошли в группу'" do
        users = create_list(:user, 5, latitude: 53.9, longitude: 27.5)
        MatchingService.run
        users.each do |user|
          expect(user.notifications.pluck(:message)).to include("Вы вошли в группу")
        end
      end
    end

    context "AC-12: инварианты размера" do
      it "active pod всегда содержит ровно 5 участников" do
        create_list(:user, 10, latitude: 53.9, longitude: 27.5)
        MatchingService.run
        Pod.where(status: "active").each do |pod|
          expect(pod.users.count).to eq(5)
        end
      end

      it "inactive pod содержит от 1 до 4 участников" do
        create_list(:user, 7, latitude: 53.9, longitude: 27.5)
        MatchingService.run
        Pod.where(status: "inactive").each do |pod|
          expect(pod.users.count).to be_between(1, 4)
        end
      end
    end
  end
end
```

**Проверка:** `bundle exec rspec spec/services/matching_service_spec.rb` — все примеры green.

---

### Шаг 13 — Убедиться, что существующие тесты не сломаны

**Команда:**
```bash
rails test
```

Проверяет: `test/models/user_test.rb`, `test/controllers/`, `test/integration/` — ничего не сломано добавлением ассоциаций в `User`.

**Проверка:** `rails test` — 0 failures, 0 errors.

---

## Порядок зависимостей

```
Шаг 1 (gems)
  └─► Шаг 2, 3, 4 (миграции — параллельно)
        └─► Шаг 5, 6, 7 (модели — после миграций)
              └─► Шаг 8 (User — после Pod/PodMembership/Notification)
                    └─► Шаг 9 (FactoryBot → RSpec интеграция)
                          └─► Шаг 9а (factories — после моделей и RSpec интеграции)
                                └─► Шаг 10 (MatchingService)
                                      └─► Шаг 11 (rake task)
                                            └─► Шаг 12 (тесты)
                                                  └─► Шаг 13 (regression)
```

---

## Новые файлы (итого)

| Файл | Тип |
|------|-----|
| `db/migrate/*_create_pods.rb` | миграция |
| `db/migrate/*_create_pod_memberships.rb` | миграция |
| `db/migrate/*_create_notifications.rb` | миграция |
| `app/models/pod.rb` | модель |
| `app/models/pod_membership.rb` | модель |
| `app/models/notification.rb` | модель |
| `app/services/matching_service.rb` | сервис |
| `lib/tasks/matching.rake` | rake task |
| `spec/factories/users.rb` | фабрика |
| `spec/factories/pods.rb` | фабрика |
| `spec/factories/pod_memberships.rb` | фабрика |
| `spec/factories/notifications.rb` | фабрика |
| `spec/services/matching_service_spec.rb` | тесты |

## Изменяемые файлы (итого)

| Файл | Изменение |
|------|-----------|
| `Gemfile` | + rspec-rails, factory_bot_rails |
| `app/models/user.rb` | + ассоциации + scope matching_pool |
