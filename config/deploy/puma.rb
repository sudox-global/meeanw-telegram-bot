#!/usr/bin/env puma

directory '/var/www/meeanw-telegram-bot/current'
rackup "/var/www/meeanw-telegram-bot/current/config.ru"
environment 'production'

tag ''

pidfile "/var/www/meeanw-telegram-bot/shared/tmp/pids/puma.pid"
state_path "/var/www/meeanw-telegram-bot/shared/tmp/pids/puma.state"
stdout_redirect '/var/www/meeanw-telegram-bot/shared/log/puma_access.log', '/var/www/meeanw-telegram-bot/shared/log/puma_error.log', true

threads 0,16

bind 'unix:///var/www/meeanw-telegram-bot/shared/tmp/sockets/puma.sock'

restart_command 'bundle exec puma'

prune_bundler

on_restart do
  puts 'Refreshing Gemfile'
  ENV["BUNDLE_GEMFILE"] = ""
end
