Swapmeet::Application.routes.draw do

  devise_for :users

  devise_scope :user do
    get "signup", :to => "devise/registrations#new"
    get "login", :to => "devise/sessions#new"
    get "logout", :to => "devise/sessions#destroy"
  end

  resources :offers do
    match 'bid', :on => :member, as: 'bid_on'                    # GET|POST /offers/2/bid
    post 'accept/:bid_id'   => "offers#accept",   as: 'accept'   # /offers/2/accept/3
    post 'complete/:bid_id' => "offers#complete", as: 'complete' # /offers/2/complete/3
    post 'rate/:bid_id'     => "offers#rate",     as: 'rate'     # /offers/2/rate/3
  end
  match 'dashboard' => 'offers#dashboard', as: 'dashboard'

  resources :users


  root :to => 'offers#index'

  # Route page not found to 404 page
  # match '*a' => 'static#not_found'

end
