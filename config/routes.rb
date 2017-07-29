Rails.application.routes.draw do
  resources :people
  root "people#home"
end
