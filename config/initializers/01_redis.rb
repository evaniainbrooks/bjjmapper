RollFindr::Redis = Redis.new(:host => Rails.application.config.redis_host, :password => Rails.application.config.redis_password)
