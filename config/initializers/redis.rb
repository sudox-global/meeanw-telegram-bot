require 'redis'

$redis = Redis.new(url: Rails.application.credentials.redis_url)
