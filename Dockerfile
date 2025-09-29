# Используем официальный образ Ruby
FROM ruby:3.4.6

# Установка netcat
RUN apt-get update && \
    apt-get install -y netcat-openbsd

# Копируем скрипт ожидания в контейнер
COPY wait-for-it.sh /app/wait-for-it.sh

# Устанавливаем права на исполнение
RUN chmod +x /app/wait-for-it.sh

# Устанавливаем зависимости
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# Устанавливаем рабочую директорию
WORKDIR /my_test_task_app

# Копируем Gemfile и Gemfile.lock
COPY Gemfile* ./

# Устанавливаем зависимости
RUN bundle install

# Копируем все файлы проекта
COPY . .

# Указываем команду по умолчанию для запуска приложения
CMD ["rails", "server", "-b", "0.0.0.0"]