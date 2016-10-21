class WechatController < ApplicationController
	protect_from_forgery with: :null_session
  layout false
 
  def connection
  	if request.request_method == "POST" && verify_wechat_auth 
       info = Hash.from_xml(request.body.read)["xml"]
       if  info[:MsgType] == "event" && info[:Event] == "subscribe" 
      # message = "欢迎,最新活动&lt;a href='#{ENV["TESTURL"]}'&gt; 去看看,&lt;/a&gt;,详情猛戳查看"
        message = "11222"
       	WECHAT_CLIENT.send_text_custom(to_user, message)
       end
  	elsif request.request_method == "GET" && verify_wechat_auth
  		render text:  wechat_params["echostr"]
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

  #文本回复模板
  def teplate_xml(message,info)
    template_xml =
      <<Text
          <xml>
            <ToUserName><![CDATA[#{info[:FromUserName]}]]></ToUserName>
            <FromUserName><![CDATA[#{info[:ToUserName]}]]></FromUserName>
            <CreateTime>#{Time.now.to_i}</CreateTime>
            <MsgType><![CDATA[text]]></MsgType>
            <Content>#{message}</Content>
            <FuncFlag>0</FuncFlag>
          </xml>
Text
    template_xml
  end

end