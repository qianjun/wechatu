#rake调用方法
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
	
  #获取component_token 在刷新access_token和获取pre_auth_code的时候都需要获取
  task :get_component_token => :environment do
    component_url = "https://api.weixin.qq.com/cgi-bin/component/api_component_token"
		redis = Redis.new(:url => "#{ENV['REDISURL']}")
    component_body = {
		  component_appid: ENV["open_app_id"],
		  component_appsecret: ENV["open_app_secrect"], 
		  component_verify_ticket: redis.hget(ENV["key_name"],ENV['field_name'])
    }
		 component_token = (JSON RestClient.post(component_url, component_body.to_json).body)["component_access_token"]
     redis.hset(ENV["key_name"],ENV['component_token'],component_token)
  end


  desc "apply pre auth code from task"
	task :pre_auth_code => :environment do
	  Rake::Task['aplly:get_component_token'].invoke  #获取新的component_token
    component_token = redis.hget(ENV["key_name"],ENV['component_token'])
    pre_url = "https://api.weixin.qq.com/cgi-bin/component/api_create_preauthcode?component_access_token=#{component_token}"
    pre_body = {component_appid: ENV["open_app_id"]}
    pre_auth_code = (JSON RestClient.post(pre_url, pre_body.to_json).body)["pre_auth_code"]
    auth_url = "https://mp.weixin.qq.com/cgi-bin/componentloginpage"
    p auth_url + "?component_appid=#{ENV["open_app_id"]}&pre_auth_code=#{pre_auth_code}&redirect_uri=#{ENV['auth_code_url'].gsub(':','%3a').gsub('/','%2f')}"
	end


  # task 传递参数 ？ 或者通过pre_auth的传递获取authorizeation_code
  desc "need authorization_code to get refresh token,can pass"
	task :get_refresh_token,[:authorization_code] => :environment do |t,args|
		redis = Redis.new(:url => "#{ENV['REDISURL']}")
		args.with_defaults("authorization_code" => "queryauthcode@@@VkOuguLVVpG1vUesw7QuHFbXnvJ0NnUpmLSHhQZ4WzxHTF2qVvXw1UZHVCRsyHWef-ACuvax7jvBAVlwl6Q3dA")
		refresh_body = {
			component_appid: ENV["open_app_id"] ,
			authorization_code: args["authorization_code"]
    }
	 component_token = redis.hget(ENV["key_name"],ENV['component_token'])
   refresh = "https://api.weixin.qq.com/cgi-bin/component/api_query_auth?component_access_token=#{component_token}"
   request_body = JSON RestClient.post(refresh, refresh_body.to_json).body
   refresh_token  = request_body["authorizer_refresh_token"]
   access_token = request_body["authorizer_access_token"]
   redis.hset(ENV["key_name"],ENV['refresh_name'],refresh_token) 
   redis.hset(ENV["key_name"],ENV['access_token'],access_token) 
	end


  desc "refresh token"
	task :refresh_access_token => :environment do
	 Rake::Task['aplly:get_component_token'].invoke  #获取新的component_token
	 redis = Redis.new(:url => "#{ENV['REDISURL']}")
	 component_token = redis.hget(ENV["key_name"],ENV['component_token'])
	 refresh_token = redis.hget(ENV["key_name"],ENV['refresh_name'])
	 authorizer_refresh_url = "https://api.weixin.qq.com/cgi-bin/component/api_authorizer_token?component_access_token=#{component_token}"
	 authorizer_body = {
    component_appid: ENV["open_app_id"], #授权方appid
		authorizer_appid: ENV["authorrizer_id"],
		authorizer_refresh_token: refresh_token,
   }
   access_token = (JSON RestClient.post(authorizer_refresh_url, authorizer_body.to_json).body)["authorizer_access_token"]
   redis.hset(ENV["key_name"],ENV['access_token'],access_token) 
	end


	task :test_redis => :environment do
   redis = Redis.new(:url => "#{ENV['REDISURL']}")
   # redis.hset(ENV["key_name"],"test",123)
   # authorization_code = "queryauthcode@@@VkOuguLVVpG1vUesw7QuHFbXnvJ0NnUpmLSHhQZ4WzxHTF2qVvXw1UZHVCRsyHWef-ACuvax7jvBAVlwl6Q3dA"
   # refresh_token = "refreshtoken@@@hoeZK7D0-XtUr6hyTQWnsI6puMtBMQWAlSvSYc5B6lc"
   # redis.hset(ENV["key_name"],ENV['refresh_name'],refresh_token) 
   # component_token = "-zulm5LGd3PE3yvQQ9u_vdI525A2FnCncVJRamIZRGWjmoqzh9rpw00xOK7110nlmPGx3NWlkQQ6gDJduRhz8HbsAVtMBH7aIjwdcU7EMEoom2LCWBgHJK6hEj92YWzCKURaAIACMJ"
   # redis.hset(ENV["key_name"],ENV['component_token'],component_token)
   p redis.hgetall(ENV["key_name"])
	end

end

	desc "parameters to rake task"
  task :blah2, (:authorization_code) do |t,args|
    puts args.inspect
  end
  task :blah1, [:a] do |t,args|
    puts args.inspect
  end

  # desc "passing 2 parameters to rake task"
  # task :blah2, [:a, :b] do |t,args|
  #   puts args.inspect
  # end

  desc "passing parameters with default values to rake task"
  task :blah3, [:a, :b] do |t,args|
    args.with_defaults(:a => 'foobar', :b => 1)
    puts args.inspect
  end 
#  此時執行 rake blah3 則是輸出 {:a=>"foobar", :b=>1}
# rake blah3['ok']   ===>   {:a=>"ok", :b=>1}
# rake blah3['ee',"rr"]   ===>   {:a=>"ee", :b=>"rr"}
# config/environment.rb 里面加了一行 Agent::Application.load_tasks,可以再controller里面调用Rake::Task['aplly:test_redis'].invoke
# 通过times,invoke 只能执行一次  execute 可以重复执行
