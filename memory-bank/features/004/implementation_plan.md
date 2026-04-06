# Implementation Plan: Realtime чат внутри Pod

**Feature:** `memory-bank/features/004/`  
**Spec:** `memory-bank/features/004/spec.md`  
**Стек:** Rails 8.1.3, ActionCable (solid_cable в prod), Turbo Streams, Stimulus, Tailwind, RSpec

---

## Шаг 1 — Миграция и модель `Message`

**Файлы:**
- `db/migrate/<timestamp>_create_messages.rb` — создать
- `app/models/message.rb` — создать
- `spec/models/message_spec.rb` — создать
- `spec/factories/messages.rb` — создать

**Что делать:**

Миграция:
```ruby
create_table :messages do |t|
  t.references :pod,  null: false, foreign_key: true
  t.references :user, null: false, foreign_key: true
  t.text       :body, null: false
  t.timestamps
end
add_index :messages, [:pod_id, :created_at]
```

Модель:
```ruby
class Message < ApplicationRecord
  belongs_to :pod
  belongs_to :user

  validates :body, presence: true, length: { maximum: 1000 }
end
```

Pod модель (`app/models/pod.rb`) — добавить:
```ruby
has_many :messages, dependent: :destroy
```

User модель (`app/models/user.rb`) — добавить:
```ruby
has_many :messages, dependent: :destroy
```

Factory (`spec/factories/messages.rb`):
```ruby
FactoryBot.define do
  factory :message do
    association :pod
    association :user
    body { "Тестовое сообщение" }
  end
end
```

`spec/factories/pods.rb` — добавить трейт `:active`:
```ruby
FactoryBot.define do
  factory :pod do
    status { "inactive" }

    trait :active do
      status { "active" }
    end
  end
end
```

**Проверка:** `rails db:migrate` без ошибок; `bundle exec rspec spec/models/message_spec.rb` — тесты на валидации (presence, length: max 1000).

---

## Шаг 2 — `ApplicationCable::Connection`

**Файлы:**
- `app/channels/` — создать директорию
- `app/channels/application_cable/` — создать директорию
- `app/channels/application_cable/connection.rb` — создать
- `app/channels/application_cable/channel.rb` — создать (базовый, без изменений)

**Что делать:**

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      if (user_id = cookies.encrypted[:_orbit_session]&.then { |s| s["warden.user.user.key"]&.dig(0, 0) })
        User.find_by(id: user_id) || reject_unauthorized_connection
      else
        reject_unauthorized_connection
      end
    end
  end
end
```

> **Примечание:** Devise хранит user_id в зашифрованной сессии. Альтернатива — использовать `env["warden"].user` напрямую:
```ruby
def find_verified_user
  env["warden"].user || reject_unauthorized_connection
end
```
Вторая форма проще и надёжнее — использовать её.

```ruby
# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
```

**Проверка:** `rails c` → `ActionCable::Server::Base` инициализируется без ошибок.

---

## Шаг 3 — `PodChannel`

**Файлы:**
- `app/channels/pod_channel.rb` — создать
- `spec/channels/pod_channel_spec.rb` — создать

**Что делать:**

```ruby
class PodChannel < ApplicationCable::Channel
  def subscribed
    pod = current_user.pods.find_by(id: params[:pod_id])
    if pod
      stream_for pod
    else
      reject
    end
  end
end
```

Broadcast вызывается из `MessagesController` (шаг 4), не из канала.

**Spec (`spec/channels/pod_channel_spec.rb`):**
- member subscribes → subscription confirmed, stream created
- non-member subscribes → subscription rejected
- user from другого pod subscribes → rejected

**Проверка:** `bundle exec rspec spec/channels/pod_channel_spec.rb`

---

## Шаг 4 — `MessagesController`

**Файлы:**
- `app/controllers/messages_controller.rb` — создать
- `app/views/messages/_message.html.erb` — создать
- `spec/controllers/messages_controller_spec.rb` — создать

**Что делать:**

```ruby
class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pod

  def create
    @message = @pod.messages.build(message_params.merge(user: current_user))

    if @message.save
      PodChannel.broadcast_to(
        @pod,
        {
          sender_id: current_user.id,
          html: render_to_string(partial: "messages/message", locals: { message: @message })
        }
      )
      head :ok
    else
      render json: { error: @message.errors.full_messages.first }, status: :unprocessable_entity
    end
  end

  private

  def set_pod
    @pod = current_user.pods.find_by(id: params[:pod_id])
    render json: { error: "Доступ запрещён" }, status: :forbidden if @pod.nil?
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
```

**Партиал `app/views/messages/_message.html.erb`:**
```erb
<div id="message-<%= message.id %>"
     class="flex flex-col gap-1 px-4 py-2">
  <div class="flex items-baseline gap-2">
    <span class="font-semibold text-sm text-gray-900"><%= message.user.display_name %></span>
    <span class="text-xs text-gray-400">
      <% if message.created_at.today? %>
        <%= message.created_at.strftime("%H:%M") %>
      <% else %>
        <%= message.created_at.strftime("%d.%m.%Y %H:%M") %>
      <% end %>
    </span>
  </div>
  <p class="text-sm text-gray-700 whitespace-pre-wrap break-words"><%= message.body %></p>
</div>
```

**Spec:** тесты на create (success → 200, broadcast вызван; body > 1000 → 422 JSON; не-участник → 403 JSON).

**Проверка:** `bundle exec rspec spec/controllers/messages_controller_spec.rb`

---

## Шаг 5 — Маршруты

**Файлы:**
- `config/routes.rb` — изменить

**Что менять:**

```ruby
# Было:
resources :pods, only: [:show] do
  resources :activities, only: [:new, :create]
  resources :members, only: [:show]
end

# Стало:
resources :pods, only: [:show] do
  resources :activities, only: [:new, :create]
  resources :members,    only: [:show]
  resources :messages,   only: [:create]
end
```

Результат: `POST /pods/:pod_id/messages` → `MessagesController#create`

**Проверка:** `rails routes | grep messages` → маршрут присутствует.

---

## Шаг 6 — Layout: meta-тег `current-user-id`

**Файлы:**
- `app/views/layouts/application.html.erb` — изменить

**Что добавить** в `<head>`, после `<%= javascript_importmap_tags %>`:
```erb
<% if user_signed_in? %>
  <meta name="current-user-id" content="<%= current_user.id %>">
<% end %>
```

**Зачем:** Stimulus-контроллер читает этот тег для фильтрации broadcast-сообщений отправителя (optimistic update, требование 5 spec).

**Проверка:** открыть браузер DevTools на `/pods/:id` → `<meta name="current-user-id">` присутствует в `<head>`.

---

## Шаг 7 — Pod show view: секция чата

**Файлы:**
- `app/views/pods/show.html.erb` — изменить
- `app/views/pods/_chat.html.erb` — создать
- `app/views/pods/_chat_history.html.erb` — создать (контент Turbo Frame)

**`show.html.erb`** — добавить в конце основного контента:
```erb
<%= render "chat", pod: @pod %>
```

**`_chat.html.erb`:**
```erb
<section class="mt-8" data-controller="chat"
         data-chat-pod-id-value="<%= pod.id %>"
         data-chat-active-value="<%= pod.active? %>">

  <h2 class="text-lg font-semibold text-gray-900 mb-4">Чат</h2>

  <%# История сообщений (Turbo Frame) %>
  <%= turbo_frame_tag "chat_history_#{pod.id}",
        src: pod_chat_path(pod),
        loading: :lazy do %>
    <div data-chat-target="spinner" class="flex justify-center py-4">
      <%# spinner (загрузка начальной истории) %>
      <svg class="animate-spin h-5 w-5 text-gray-400" ...></svg>
    </div>
  <% end %>

  <%# Лента сообщений (куда прилетают новые через broadcast) %>
  <div id="messages-<%= pod.id %>"
       data-chat-target="messageList"
       class="flex flex-col gap-0 max-h-96 overflow-y-auto">
  </div>

  <%# Форма ввода — только для active pod %>
  <% if pod.active? %>
    <form data-chat-target="form"
          data-action="submit->chat#send keydown->chat#handleKeydown"
          class="mt-4 flex flex-col gap-2">
      <textarea data-chat-target="input"
                data-action="input->chat#updateCounter"
                rows="3"
                maxlength="1000"
                placeholder="Написать сообщение…"
                class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm
                       focus:outline-none focus:ring-2 focus:ring-indigo-400
                       resize-none"></textarea>
      <div class="flex items-center justify-between">
        <span data-chat-target="counter"
              class="text-xs text-gray-400">0 / 1000</span>
        <button type="submit"
                data-chat-target="submit"
                disabled
                class="px-4 py-2 rounded-lg bg-indigo-600 text-white text-sm font-medium
                       disabled:opacity-40 disabled:cursor-not-allowed
                       hover:bg-indigo-700 transition">
          Отправить
        </button>
      </div>
    </form>
  <% end %>

</section>
```

> **Примечание:** `pod_chat_history_path` — новый маршрут, добавляется в шаге 8.

**`_chat_history.html.erb`** (контент Turbo Frame — рендерится контроллером):

```erb
<%= turbo_frame_tag "chat_history_#{@pod.id}" do %>
  <div id="chat-history-messages" data-chat-target="history">

    <% if @messages.count == 50 %>
      <%# Триггер infinite scroll %>
      <div data-chat-target="scrollTrigger" class="py-1"></div>
      <div data-chat-target="paginationSpinner" class="hidden flex justify-center py-2">
        <svg class="animate-spin h-4 w-4 text-gray-400" ...></svg>
      </div>
    <% end %>

    <% if @messages.empty? %>
      <p class="text-center text-sm text-gray-400 py-8">
        Пока нет сообщений. Начните общение!
      </p>
    <% else %>
      <% @messages.each do |message| %>
        <%= render "messages/message", message: message %>
      <% end %>
    <% end %>

  </div>
<% end %>
```

**Проверка:** `/pods/:id` рендерится без ошибок, секция чата видна.

---

## Шаг 8 — Маршрут и контроллер истории чата

**Файлы:**
- `config/routes.rb` — изменить (добавить маршрут истории)
- `app/controllers/pod_chats_controller.rb` — создать
- `app/views/pod_chats/show.html.erb` — создать

**Маршрут:**
```ruby
resources :pods, only: [:show] do
  resources :activities, only: [:new, :create]
  resources :members,    only: [:show]
  resources :messages,   only: [:create]
  resource  :chat,       only: [:show], controller: "pod_chats"  # GET /pods/:pod_id/chat
end
```

**Контроллер `app/controllers/pod_chats_controller.rb`:**
```ruby
class PodChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pod

  def show
    @messages = @pod.messages
                    .includes(:user)
                    .order(created_at: :desc)
                    .limit(50)
                    .reverse
    # Для пагинации: before_id
    if params[:before_id].present?
      pivot = @pod.messages.find_by(id: params[:before_id])
      if pivot
        @messages = @pod.messages
                        .includes(:user)
                        .where("created_at < ?", pivot.created_at)
                        .order(created_at: :desc)
                        .limit(50)
                        .reverse
      end
    end
  end

  private

  def set_pod
    @pod = current_user.pods.find_by(id: params[:pod_id])
    render file: "public/404.html", status: :not_found, layout: false if @pod.nil?
  end
end
```

**View `app/views/pod_chats/show.html.erb`:**
```erb
<%= render "pods/chat_history" %>
```

**Проверка:** `rails routes | grep chat` → `GET /pods/:pod_id/chat` присутствует.

---

## Шаг 9 — Stimulus-контроллер `chat_controller.js`

**Файлы:**
- `app/javascript/controllers/chat_controller.js` — создать

**Функциональность контроллера (5 зон):**

### 9.1 — ActionCable subscription + broadcast receive
```javascript
connect() {
  this.channel = createConsumer().subscriptions.create(
    { channel: "PodChannel", pod_id: this.podIdValue },
    {
      received: (data) => this.handleBroadcast(data),
      rejected: () => this.markAllPendingFailed()
    }
  )
}

handleBroadcast(data) {
  const currentUserId = document.querySelector('meta[name="current-user-id"]')?.content
  if (String(data.sender_id) === String(currentUserId)) return  // игнорируем своё

  this.messageListTarget.insertAdjacentHTML("beforeend", data.html)
  this.scrollToBottom()
}

disconnect() { this.channel?.unsubscribe() }
```

### 9.2 — Счётчик символов + блокировка кнопки
```javascript
updateCounter() {
  const len = this.inputTarget.value.length
  this.counterTarget.textContent = `${len} / 1000`
  const over = len > 1000
  this.counterTarget.classList.toggle("text-red-500", over)
  this.counterTarget.classList.toggle("text-gray-400", !over)
  this.submitTarget.disabled = len === 0 || over
}
```

### 9.3 — Enter/Shift+Enter
```javascript
handleKeydown(event) {
  if (event.key === "Enter" && !event.shiftKey) {
    event.preventDefault()
    this.send(event)
  }
}
```

### 9.4 — Optimistic update + fetch с AbortController
```javascript
async send(event) {
  event.preventDefault()
  const body = this.inputTarget.value.trim()
  if (!body || body.length > 1000) return

  const pendingId = `pending-${Date.now()}`
  this.appendOptimistic(pendingId, body)
  this.inputTarget.value = ""
  this.updateCounter()

  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), 10_000)

  try {
    const response = await fetch(`/pods/${this.podIdValue}/messages`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ message: { body } }),
      signal: controller.signal
    })
    clearTimeout(timeout)

    if (response.ok) {
      document.getElementById(pendingId)?.classList.remove("message--pending", "opacity-50")
    } else if (response.status === 403 || response.status === 422) {
      const data = await response.json()
      this.markFailed(pendingId, data.error, false)  // без кнопки retry
    } else {
      this.markFailed(pendingId, null, true)  // с кнопкой retry
    }
  } catch {
    clearTimeout(timeout)
    this.markFailed(pendingId, null, true)
  }
}
```

### 9.5 — Infinite scroll (Intersection Observer)
```javascript
connectScrollObserver() {
  if (!this.hasScrollTriggerTarget) return
  this.observer = new IntersectionObserver(
    (entries) => {
      if (entries[0].isIntersecting && !this.loading) this.loadMore()
    },
    { threshold: 0.1 }
  )
  this.observer.observe(this.scrollTriggerTarget)
}

async loadMore() {
  this.loading = true
  this.paginationSpinnerTarget.classList.remove("hidden")
  const oldestId = this.historyTarget.querySelector("[id^='message-']")?.id.replace("message-", "")

  try {
    const response = await fetch(`/pods/${this.podIdValue}/chat?before_id=${oldestId}`, {
      headers: { "Accept": "text/html" }
    })
    if (!response.ok) throw new Error()
    const html = await response.text()
    const prevHeight = this.messageListTarget.scrollHeight
    this.historyTarget.insertAdjacentHTML("afterbegin", html)
    this.messageListTarget.scrollTop += this.messageListTarget.scrollHeight - prevHeight
  } catch {
    // показать inline-сообщение об ошибке с кнопкой Повторить
  } finally {
    this.paginationSpinnerTarget.classList.add("hidden")
    this.loading = false
  }
}
```

**Примечание:** `index.js` трогать не нужно — `eagerLoadControllersFrom` автоматически регистрирует все файлы `*_controller.js` из папки `controllers/`.

**Проверка:** открыть DevTools Console на `/pods/:id` — нет JS-ошибок; отправить сообщение — появляется optimistic-элемент.

---

## Шаг 10 — Тесты

**Файлы:**
- `spec/models/message_spec.rb` — создать
- `spec/channels/pod_channel_spec.rb` — создать
- `spec/controllers/messages_controller_spec.rb` — создать
- `spec/controllers/pod_chats_controller_spec.rb` — создать
- `spec/factories/messages.rb` — уже создана в шаге 1

### `spec/models/message_spec.rb`
- присутствие `body`
- длина `body` ≤ 1000 (1001 — невалидно)
- принадлежность к `pod` и `user`

### `spec/channels/pod_channel_spec.rb`
```ruby
RSpec.describe PodChannel, type: :channel do
  let(:user) { create(:user) }
  let(:pod)  { create(:pod, :active) }

  context "участник Pod" do
    before { create(:pod_membership, user: user, pod: pod) }
    it "подтверждает подписку" do
      stub_connection current_user: user
      subscribe(pod_id: pod.id)
      expect(subscription).to be_confirmed
    end
  end

  context "не участник" do
    it "отклоняет подписку" do
      stub_connection current_user: user
      subscribe(pod_id: pod.id)
      expect(subscription).to be_rejected
    end
  end
end
```

### `spec/controllers/messages_controller_spec.rb`
- POST create, участник, валидное body → 200, broadcast вызван
- POST create, body > 1000 символов → 422 JSON `{ error: ... }`
- POST create, не участник → 403 JSON `{ error: ... }`
- POST create, неаутентифицированный → redirect to sign_in

### `spec/controllers/pod_chats_controller_spec.rb`
- GET show, участник → 200, @messages.count ≤ 50
- GET show, `before_id` → возвращает сообщения до указанного id
- GET show, не участник → 404

**Проверка:** `bundle exec rspec spec/models/message_spec.rb spec/channels/ spec/controllers/messages_controller_spec.rb spec/controllers/pod_chats_controller_spec.rb`

---

## Шаг 11 — Проверка регрессии

**Файлы:** не изменяются

**Команда:**
```bash
bundle exec rspec
```

Все существующие тесты должны пройти:
- `spec/controllers/pods_controller_spec.rb`
- `spec/controllers/activities_controller_spec.rb`
- `spec/controllers/members_controller_spec.rb`
- `spec/models/`
- `spec/services/`

---

## Итоговый порядок выполнения

| # | Шаг | Файлов создаётся | Файлов изменяется |
|---|-----|-----------------|-------------------|
| 1 | Миграция + модель Message | 3 | 3 (`pod.rb`, `user.rb`, `pods.rb` factory) |
| 2 | ApplicationCable::Connection | 2 + 2 директории | — |
| 3 | PodChannel | 2 | — |
| 4 | MessagesController + партиал | 3 | — |
| 5 | Маршрут messages | — | 1 (`routes.rb`) |
| 6 | Meta-тег layout | — | 1 (`application.html.erb`) |
| 7 | Pod show: секция чата + партиалы | 2 | 1 (`show.html.erb`) |
| 8 | PodChatsController + маршрут | 3 | 1 (`routes.rb`) |
| 9 | chat_controller.js | 1 | — |
| 10 | Тесты | 4 | — |
| 11 | Регрессия | — | — |

**Итого:** 19 новых файлов, 7 изменённых.
