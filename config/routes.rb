Rails.application.routes.draw do
  devise_for :users, :skip => [:registrations]
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'main#home'
  get '/password', to: 'main#password'
  get '/check', to: 'main#check'
  post '/check/since', to: 'main#check_since'

  get '/user/search', to: 'user#search'

  # bootstrap_form_for goes to users, not user, so this reroutes it to the proper place.
  get '/users', to: 'user#new'
  post '/users', to: 'user#new'

  get '/marked_park/:id/quick', to: 'marked_park#quick', as: :marked_park_quick
  post '/marked_park/:id/quick', to: 'marked_park#submit_changes'
  get '/marked_park/:id/delete', to: 'marked_park#delete', as: :marked_park_delete
  post '/marked_park/:id/delete', to: 'marked_park#delete'
  get '/marked_park/status', to: 'marked_park#status'
  get '/marked_park/autocomplete', to: 'marked_park#autocomplete', as: :marked_park_auto
  post '/marked_park/autocomplete', to: 'marked_park#autologic'
  post '/marked_park/filter', to: 'marked_park#filter_logic'

  # Must be last, otherwise it considers /user/search as user/show with id: search.
  resources :user
  resources :marked_park

  Rails.application.routes.draw do
    mount ReportsKit::Engine, at: '/'
  end

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
