Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  resource :onboarding, only: [:show, :update], controller: "onboarding"

  get "dashboard", to: "dashboard#index", as: :dashboard
  get "grammar_references", to: "grammar_references#index", as: :grammar_references
  get "settings",           to: "settings#index",           as: :settings

  resources :vocabulary, only: [:index, :new, :create, :destroy]

  resource :session, only: [], path: "session" do
    get  :introduce
    post :introduce,          action: :create_introduce
    get  :flashcards
    post :flashcards,         action: :rate_flashcard
    get  :speaking
    post :speaking_exchange
    post :speaking_complete
    get  :listening
    post :listening,          action: :answer_listening
    get  :reading
    post :reading,            action: :answer_reading
    get  :complete
  end

  root to: "dashboard#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
