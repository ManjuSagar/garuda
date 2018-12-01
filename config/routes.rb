Rails.application.routes.draw do
  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

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

  resources :transactions, :only => [:create, :new, :index, :show, :update]
  resources :transaction_items, :only => [:index]
  resources :vouchers, :only => [:index, :show]
  resources :customers, :only => [:index,:show]
  resources :winners, :only => [:new,:create]
  resources :stores, :only => [:index,:show,:new,:create]
  get "/reports" => "reports#index", as: :reports
  get "customers/get_cutomer/:id" => "customers#get_customer", as: :customer_info

  get "/get_highest_shopper" => "customers#get_highest_shopper"
  get "/silver_customer" => 'customers#list_silver_customers'
  post "/issue_silver" => 'customers#issue_silver'
  get "/top_five_customers" => 'customers#top_five_customers'
  get '/transactions_download/:from_date/:to_date', to: "transactions#csv_download"
  get '/customers_download/:from_date/:to_date', to: "customers#csv_download"
  get '/transaction_items_download/:from_date/:to_date', to: "transaction_items#csv_download"
  get '/stores_download/:from_date/:to_date', to: "stores#csv_download"
  get '/vouchers_download/:from_date/:to_date', to: "vouchers#csv_download"
  post "/customers", to: "customers#index"
  post "/upload_stores",  to: "stores#import"
end
  