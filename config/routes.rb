Ch::Application.routes.draw do

  post 'search' => 'search#create', as: :create_search
  get  'search/:uuid' => 'search#show', as: :search

  root to: 'welcome#index'

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

end
