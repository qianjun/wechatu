class WechatController < ApplicationController
	protect_from_forgery with: :null_session
  layout false
 
  def connection
  	if request.request_method == "POST" && verify_wechat_auth 
      info = Hash.from_xml(request.body.read)["xml"]
      if info["MsgType"] == "event" && info["Event"] == "subscribe" 
         message = "欢迎关注x！<a href='#{url}'>你想要显示的文字</a>"
         Rails.logger.debug message
	       WECHAT_CLIENT.send_text_custom(params[:openid], message)  #发送文本消息
	       Rails.logger.debug WECHAT_CLIENT.user(params[:openid]).result #get user info
	       response = WECHAT_CLIENT.create_menu(menu)  #create menu
	     
	    elsif info["MsgType"] == "text"
	    	  WECHAT_CLIENT.send_text_custom(params[:openid], "谢谢回复")
      end
      render plain: "success"
  	elsif request.request_method == "GET" && verify_wechat_auth
  		render plain:  wechat_params["echostr"]
  	end
  end

  def mp_ticket
    p rand_map(43)
    render nothing: true
  end

  private

  def wechat_params
    params.permit(:timestamp, :nonce, :echostr,:signature)
  end

  def verify_wechat_auth
    return unless ENV["AUTHTOKEN"]
    arr = [ ENV["AUTHTOKEN"], wechat_params[:timestamp],wechat_params[:nonce] ].sort
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
          "type":"view",
          "name":"他日歌曲",
          "url":"http://www.baidu.com"
      }
      ]}
  end

  def url
    parms = {
  	 appid: ENV["WECHATID"],
     redirect_uri: ENV["REDIRECTURI"],
     response_type: "code",
     scope: "snsapi_userinfo",
     status: "123"
  	}
   URI.parse(ENV["OPENURL"]+parms.to_query+"#wechat_redirect")
  end

  def rand_map(number)
    code_array = []
    chars = ('A'..'Z').to_a + ('a'..'z').to_a + (0..9).to_a
    number.times {code_array << chars[rand(chars.length)]}
    return code_array.join("")
  end

end