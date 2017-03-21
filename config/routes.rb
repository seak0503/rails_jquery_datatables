Rails.application.routes.draw do
  resources :events do
    collection do
      get :list
    end
  end
end
