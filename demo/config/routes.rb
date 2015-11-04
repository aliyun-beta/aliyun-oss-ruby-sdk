Rails.application.routes.draw do
  root 'home#index'
  put '/download', to: 'home#download', as: :download
end
