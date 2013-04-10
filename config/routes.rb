LssUsdlEditor::Application.routes.draw do

  resources :service_systems do

    resources :interactions do
      put "add_entity"
      delete "delete_entity"
      get "edit_time"
    end

    resources :business_entities
    resources :roles
    resources :goals
    resources :locations
    resources :process_entities, path: "processes"
    resources :resources

    get 'export_to_lss_usdl'

  end

  devise_for :users

  root to: "service_systems#index"

end
