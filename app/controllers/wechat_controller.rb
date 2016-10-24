class WechatController < ApplicationController
	protect_from_forgery with: :null_session
  layout false
 
  def connection
  	if request.request_method == "POST" && verify_wechat_auth 
       info = Hash.from_xml(request.body.read)["xml"]
       # if  info[:MsgType] == "event" && info[:Event] == "subscribe" 
      # message = "欢迎,最新活动&lt;a href='#{ENV["TESTURL"]}'&gt; 去看看,&lt;/a&gt;,详情猛戳查看"
       Rails.logger.debug WECHAT_CLIENT.mass_autoreply_rules.result
       Rails.logger.debug WECHAT_CLIENT.is_valid? 
       Rails.logger.debug WECHAT_CLIENT.user(params[:openid]).result
       response = WECHAT_CLIENT.create_menu(menu).result
       result = WECHAT_CLIENT.send_text_custom(info[:FromUserName], "hello")
       Rails.logger.debug result.full_error_message
       render plain: "success"
       # end
  	elsif request.request_method == "GET" && verify_wechat_auth
  		render plain:  wechat_params["echostr"]
  	end
  end

  def share
  end

  private

  def wechat_params
    params.permit(:timestamp, :nonce, :echostr,:signature)
  end

  def verify_wechat_auth
    return unless ENV["AUTHTOKEN"]
    arr = [ ENV["AUTHTOKEN"], wechat_params[:timestamp],
            wechat_params[:nonce] ].sort
    Digest::SHA1.hexdigest(arr.join) == wechat_params["signature"]
  end

  def menu
    {
     "button":[
     {	
          "type":"click",
          "name":"今日歌曲",
          "key":"V1001_TODAY_MUSIC"
      },
      {	
          "type":"click",
          "name":"他日歌曲",
          "key":"V1002_TODAY_MUSIC"
      }
      ]}
  end

end