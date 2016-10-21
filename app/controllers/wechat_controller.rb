class WechatController < ApplicationController
layout false
 
  def connection
    if  verify_wechat_auth
      render text: 'success'
    else
    	render text: 'fail'
    end
  end

  def share
  end

  private

  def wechat_message_params
    params.permit(:timestamp, :nonce, :msg_signature)
  end

  def verify_wechat_auth
    return unless ENV["AUTHTOKEN"]
    arr = [ ENV["AUTHTOKEN"], wechat_message_params[:timestamp],
            wechat_message_params[:nonce] ].sort
    Digest::SHA1.hexdigest(arr.join) == wechat_message_params["msg_signature"]
  end
end
