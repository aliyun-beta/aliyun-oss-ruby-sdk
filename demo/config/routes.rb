Rails.application.routes.draw do
  root 'home#index'
  put 'download', to: 'home#download'

  get 'new_put', to: 'home#new_put'
  post 'new_put', to: 'home#create_put'

  get 'new_post', to: 'home#new_post'
  get 'post_return', to: 'home#post_return'
end
