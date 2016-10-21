Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :wechat do |
  	 collection do 
  	 	get 'connection'
  	 	
  	 end  	
  end
  root to: "wechat#index"
end
