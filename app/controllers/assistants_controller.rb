class AssistantsController < ApplicationController
  protect_from_forgery with: :null_session

  def create_qrcode
    response = WECHAT_CLIENT.create_qr_limit_str_scene({sscene_str: params[:s] ||= "qrcode"})
    redirect_to WECHAT_CLIENT.qr_code_url(response.result["ticket"])
  end
end