class WechatController < ApplicationController
	protect_from_forgery with: :null_session
  include Prpcrypt
  layout false
  before_action :auth_weixin, only: [:index]
 
  def connection
  	if request.request_method == "POST" && verify_wechat_auth 
      info = Hash.from_xml(request.body.read)["xml"]
      Rails.logger.debug info
      #普通关注之后再次扫描的推送event是scan
      if info["MsgType"] == "event" && info["Event"] == "subscribe" 
        if info["EventKey"] == ""
         message = "欢迎关注x！<a href='#{url}'>你想要显示的文字</a>"
	       WECHAT_CLIENT.send_text_custom(params[:openid], message)  #发送文本消息
	       Rails.logger.debug WECHAT_CLIENT.user(params[:openid]).result #get user info
       else
         qrcode = info["EventKey"].split("_")
        if qrcode[0] == "qrscene"  #场景二维码判断
          WECHAT_CLIENT.send_text_custom(params[:openid], qrcode[1])
        end
       end
	     
	    elsif info["MsgType"] == "text"
	    	  WECHAT_CLIENT.send_text_custom(params[:openid], "谢谢回复")
      end
      render plain: "success"
  	elsif request.request_method == "GET" && verify_wechat_auth
  		render plain:  wechat_params["echostr"]
  	end
  end

  def index
    $client = WECHAT_CLIENT
   Rails.logger.debug request.parameters
  end


  def mp_ticket
    info = Hash.from_xml(request.body.read)["xml"]
    Rails.logger.debug info
    if open_authorize(info["Encrypt"])
      decrypt(info["Encrypt"])
    end
    render plain: "success"
  end

  def author_code
    render json: {"success" =>request.parameters}
  end

  def callback
    info = Hash.from_xml(request.body.read)["xml"]
    Rails.logger.debug info
    render plain: "success"
  end

  def load_config
     client = WeixinAuthorize::Client.new(ENV["WECHATID"], ENV["WECHATSECRET"])
     render json: client.get_jssign_package(params[:url])
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
    chars = [*'A'..'Z'] + [*'a'..'z'] + [*0..9]
    return (1..number).map {chars[rand(chars.length)]}.join
  end

  def open_authorize(encrypt)
    arr = [ ENV["token"], wechat_params[:timestamp],wechat_params[:nonce],encrypt].sort
    Rails.logger.debug arr
    Rails.logger.debug Digest::SHA1.hexdigest(arr.join)
    Digest::SHA1.hexdigest(arr.join) == wechat_params["msg_signature"]
  end

end