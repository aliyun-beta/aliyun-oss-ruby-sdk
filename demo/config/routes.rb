Rails.application.routes.draw do
  root 'home#index'
  get '/download/:key', to: 'home#download', as: :download
end
