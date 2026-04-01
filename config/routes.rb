Rails.application.routes.draw do
  root "pages#home"
  get "rules", to: "pages#rules"
  get "board", to: "pages#board"

  resources :messages, only: [:create, :destroy] do
    member { patch :pin }
    resources :likes, only: [:create, :destroy]
  end
  resources :poll_votes, only: [:create]
  devise_for :users

  resources :seasons, only: [:index, :show] do
    member do
      get :standings
      get :my_picks
      get :scores
    end
    resources :participations, only: [:create, :update, :destroy]
    resources :winner_picks, only: [:new, :create]
    resources :weeks, only: [:show] do
      resources :weekly_picks, only: [:new, :create, :update, :destroy]
    end
  end

  namespace :admin do
    root "dashboard#index"

    resources :seasons do
      member do
        patch :activate
        patch :complete
        get   :scores
      end
      resources :contestants, except: [:show] do
        collection do
          post :bulk_assign_tribe
        end
      end
      resources :weeks do
        member { patch :mark_scored }
        resources :scoring_events, except: [:show] do
          collection { post :bulk_create }
        end
      end
    end

    resources :users, only: [:index, :show, :edit, :update] do
      member { patch :toggle_role }
    end

    resources :participations, only: [:index, :create, :update, :destroy]
    resources :weekly_picks, only: [:new, :create, :edit, :update, :destroy]
    resources :winner_picks, only: [:new, :create, :edit, :update, :destroy]
    resources :scoring_event_types
  end
end
