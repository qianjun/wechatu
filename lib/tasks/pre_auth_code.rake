
# namespace :pick do  
#   desc "Pick a random user as the winner"  
#   task :winner => :environment do  
#     puts "Winner: #{pick(User).name}"  
#   end  
  
#   desc "Pick a random product as the prize"  
#   task :prize => :environment do   
#     puts "Prize: #{pick(User).name}"  
#   end  
  
#   def "Pick a random prize as the prize"  
#   task :all => [:prize, :winner]  
  
#   def pick(model_class)  
#     model_class.find(:first, : order => 'RAND()')  
#   end  
# end  

# component_token 和 refresh_token都需要刷新

namespace :apply do 
	desc "apply pre auth code from task"
	task :pre_auth_code => :environment do
		require 'rubygems'
		require "redis"
		client = WeixinAuthorize::Client.new(ENV["WECHATID"], ENV["WECHATSECRET"])
		redis = Redis.new(:url => "#{ENV['REDISURL']}")
    component_body = {
		  component_appid: ENV["open_app_id"],
		  component_appsecret: ENV["open_app_secrect"], 
		  component_verify_ticket: "ticket@@@tDIE_Xd664HIcQ7b0aYr13p1LO2uUpTBeS_3JGvyhcQP8zUyntBKGTmOJhoyA4iDtibPN7Cb3pHMKqtbnAIlLw"
      # redis.hget(ENV["key_name"],ENV['field_name'])
    }

		# component_token = JSON RestClient.post(ENV["component_url"], component_body.to_json).body["component_access_token"]
     component_token = "-zulm5LGd3PE3yvQQ9u_vdI525A2FnCncVJRamIZRGWjmoqzh9rpw00xOK7110nlmPGx3NWlkQQ6gDJduRhz8HbsAVtMBH7aIjwdcU7EMEoom2LCWBgHJK6hEj92YWzCKURaAIACMJ"
     redis.hset(ENV["key_name"],ENV['component_token'],component_token)
     pre_url = "https://api.weixin.qq.com/cgi-bin/component/api_create_preauthcode?component_access_token=#{component_token}"
     pre_body = {component_appid: ENV["open_app_id"]}
     # pre_auth_code = JSON RestClient.post(pre_url, pre_body.to_json).body["pre_auth_code"]
     auth_url = "https://mp.weixin.qq.com/cgi-bin/componentloginpage"
     # p auth_url + "?component_appid=#{ENV["open_app_id"]}&pre_auth_code=#{pre_auth_code}&redirect_uri=#{ENV['REDIRECTURI'].gsub('://','%3a%2f%2f')}"
	end

  # task 传递参数 ？
  desc "need authorization_code to get refresh token,can pass"
	task :get_refresh_token => :environment do
		redis = Redis.new(:url => "#{ENV['REDISURL']}")
		authorization_code = "queryauthcode@@@VkOuguLVVpG1vUesw7QuHFbXnvJ0NnUpmLSHhQZ4WzxHTF2qVvXw1UZHVCRsyHWef-ACuvax7jvBAVlwl6Q3dA"
		refresh_body = {
			component_appid: ENV["open_app_id"] ,
			authorization_code: authorization_code
    }
	 component_token = redis.hget(ENV["key_name"],ENV['component_token'])
   refresh = "https://api.weixin.qq.com/cgi-bin/component/api_query_auth?component_access_token=#{component_token}"
   # refresh_token  = JSON RestClient.post(refresh, refresh_body.to_json).body["authorizer_refresh_token"]
   refresh_token = "refreshtoken@@@hoeZK7D0-XtUr6hyTQWnsI6puMtBMQWAlSvSYc5B6lc"
   redis.hset(ENV["key_name"],ENV['refresh_name'],refresh_token) 
	end

  desc "refresh token"
	task :refresh_access_token => :environment do
	 redis = Redis.new(:url => "#{ENV['REDISURL']}")
	 # component_token = redis.hget(ENV["key_name"],ENV['component_token'])
	 # refresh_token = redis.hget(ENV["key_name"],ENV['refresh_name'])
	 refresh_token = "refreshtoken@@@hoeZK7D0-XtUr6hyTQWnsI6puMtBMQWAlSvSYc5B6lc"
	 component_token = "-zulm5LGd3PE3yvQQ9u_vdI525A2FnCncVJRamIZRGWjmoqzh9rpw00xOK7110nlmPGx3NWlkQQ6gDJduRhz8HbsAVtMBH7aIjwdcU7EMEoom2LCWBgHJK6hEj92YWzCKURaAIACMJ"
	 authorizer_refresh_url = "https://api.weixin.qq.com/cgi-bin/component/api_authorizer_token?component_access_token=#{component_token}"
	 authorizer_body = {
    component_appid: ENV["open_app_id"], #授权方appid
		authorizer_appid: ENV["WECHATID"],
		authorizer_refresh_token: refresh_token,
   }
   p JSON RestClient.post(authorizer_refresh_url, authorizer_body.to_json).body
	end
end