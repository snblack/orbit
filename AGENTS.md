# Orbit — контекст для агентов

## Запуск проекта локально

Ruby 3.4.8, PostgreSQL.

```bash
bundle install
rails db:create db:migrate
rails server
```

Приложение: `http://localhost:3000`

## Матчинг

```bash
rails matching:run
```

## Тесты

```bash
rails test           # Minitest
bundle exec rspec    # RSpec (сервисы)
```
