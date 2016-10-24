class WechatController < ApplicationController
	protect_from_forgery with: :null_session
  layout false
 
  def connection
  	if request.request_method == "POST" && verify_wechat_auth 
      info = Hash.from_xml(request.body.read)["xml"]
      # if  info[:MsgType] == "event"
      #  	if info[:Event] == "subscribe" 
         Rails.logger.debug request.body
         message = "欢迎,最新活动&lt;a href='#{ENV["TESTURL"]}'&gt; 去看看,&lt;/a&gt;,详情猛戳查看"
         Rails.logger.debug message
	       result = WECHAT_CLIENT.send_text_custom(params[:openid], message)
	       Rails.logger.debug result.result
	       Rails.logger.debug result.full_error_messages
	       Rails.logger.debug WECHAT_CLIENT.user(params[:openid]).result #get user info
	       response = WECHAT_CLIENT.create_menu(menu)  #create menu
	     
	     #  elsif info[:MsgType] == "text"
	     # 	  WECHAT_CLIENT.send_text_custom(params[:openid], "谢谢回复")
      #   end
      # end
      render plain: "success"
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
    return {
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