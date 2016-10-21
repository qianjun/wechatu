class WechatController < ApplicationController
layout false
 
  def connection
  	if request.request_method == "POST" && verify_wechat_auth 
       info = Hash.from_xml(request.body.read)["xml"]
       if  info[:MsgType] == "event" && info[:Event] == "subscribe" 
       	render :xml => teplate_xml(message，info)
       end
  	elsif request.request_method == "GET" && tmp_encrypted_str == signature
  		render :text => tmp_encrypted_str == signature ? wechat_params["echostr"] :  false
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
