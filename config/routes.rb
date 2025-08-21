Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :auth do
        post :login
        post :register
        post :google
        post :refresh
        delete :logout
      end
      
      # Vos autres routes API ici
      resources :users, only: [:show, :update]
    end
  end
end