Leads::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
  
  root :to => 'main#index'
  get "main", :to => "main#index"
  get 'main/index'
  get "main/login"
  post "main/loginattempt"
  get "main/logout"
  
  
  get "fronts", :to => "fronts#index"
  get "fronts/index"
  get "fronts/serverprocessing"
  post "fronts/serverprocessing"
  get "fronts/newfront"
  get "fronts/createfront"
  post "fronts/checkperson"
  post "fronts/add"
  get "fronts/edit"
  post "fronts/update"
  post "fronts/exportfronts"
  get "fronts/import"
  post "fronts/upload"
  post "fronts/doimport"
  
  
  
  get "nocalls", :to => "nocalls#index"
  get "nocalls/index"
  post "nocalls/serverprocessing"
  post "nocalls/add"
  post "nocalls/exportnocalls"
  get "nocalls/import"
  post "nocalls/upload"
  post "nocalls/doimport"
  
  get "scrubs", :to => "scrubs#import"
  post "scrubs/upload"
  post "scrubs/doscrub"
  get "scrubs/import"
  
  get "workers", :to => "workers#index"
  get "workers/index"
  post "workers/addWorker"
  post "workers/removeWorker"
  get "workers/getWorkers"
  
  
  get "admin", :to => "admin#index"
  get "admin/index"
  post "admin/clearfronts"
  post "admin/clearnocalls"
  
  get "downloads/file"
  
  
end
