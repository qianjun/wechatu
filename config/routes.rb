Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "wechat#index"
  match 'connection', to: 'wechat#connection',via: [:get,:post]
  match 'mp_ticket', to: 'wechat#mp_ticket', via: [:get,:post]
  match 'author_code', to: 'wechat#author_code',via: [:get]
  resources :wechat 
 
end
