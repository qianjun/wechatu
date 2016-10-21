class WechatController < ApplicationController
layout false
 
  def create
 p "===="
    body = Hash.from_xml(request.body.read)["xml"]
    if request.request_method == "POST" && verify_wechat_auth(ENV["AUTHTOKEN"], body["Encrypt"])
      render text: 'success'
    end
  end

  def share
  end

  private

  def wechat_message_params
    params.permit(:timestamp, :nonce, :msg_signature)
  end

  def verify_wechat_auth(token, encrypt)
    return unless token
    arr = [ token, wechat_message_params[:timestamp],
            wechat_message_params[:nonce], encrypt ].sort
    Digest::SHA1.hexdigest(arr.join) == wechat_message_params["msg_signature"]
  end
end
