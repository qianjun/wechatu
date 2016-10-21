# # Give a special namespace as prefix for Redis key, when your have more than one project used weixin_authorize, this config will make them work fine.
# redis = Redis::Namespace.new("#{namespace}", :redis => redis)



unless Rails.env.development?
 
redis = Redis.new(:url => "#{ENV['REDISURL']}")

 # 每次重启时，会把当前的命令空间所有的access_token 清除掉。
# exist_keys = redis.keys("#{namespace}:*")
exist_keys = redis.keys("*")
exist_keys.each{|key|redis.del(key)}

  WeixinAuthorize.configure do |config|
    config.redis = redis
  end

  WECHAT_CLIENT ||= WeixinAuthorize::Client.new(ENV["WECHATID"], ENV["WECHATSECRET"])

end