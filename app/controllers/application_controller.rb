class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

 def auth_weixin
    return redirect_to(WECHAT_CLIENT.authorize_url(request.original_url, "snsapi_base")
    sns_info = WECHAT_CLIENT.get_oauth_access_token(params[:code])
    return redirect_to(:error) if sns_info.code != 0
    _result = sns_info.result
    Rails.logger.info("auth_code: #{_result["openid"]}")
    Rails.logger.info("_result: #{_result.inspect}")
    session[:openid] = _result["openid"]
  end
 
end
