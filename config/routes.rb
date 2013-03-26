LssUsdlEditor::Application.routes.draw do

  resources :service_systems do

    resources :interactions do
      put "update_roles"
      delete "delete_roles"
    end

    resources :business_entities
    resources :roles
    resources :goals
    resources :locations
    resources :process_entities, path: "processes"
    resources :resources

  end

  devise_for :users

  root to: "service_systems#index"

end
