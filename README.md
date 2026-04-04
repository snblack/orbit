# Orbit

## Запуск локально

**Требования:** Ruby 3.4.8, PostgreSQL

```bash
bundle install
rails db:create db:migrate db:seed
rails server
```

Приложение доступно на `http://localhost:3000`.

## Матчинг

```bash
rails matching:run
```

Алгоритм группирует пользователей из пула (onboarding завершён, координаты указаны, ещё не в поде) в Pod-ы по 5 человек с учётом геолокации и совместимости.

## Тесты

```bash
# Minitest
rails test

# RSpec
bundle exec rspec
```
