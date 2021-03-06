Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "wechat#index"
  match 'connection', to: 'wechat#connection',via: [:get,:post]
  match 'mp_ticket', to: 'wechat#mp_ticket', via: [:get,:post]
  match 'author_code', to: 'wechat#author_code',via: [:get]
  match 'load_auth', to: 'wechat#load_config',via: [:get]
  match 'create_qrcode', to: 'assistants#create_qrcode', via: [:get]
  match ':appid/callback', to: 'wechat#callback', via: [:post]
  resources :wechat 
  resources :assistants
 
end
