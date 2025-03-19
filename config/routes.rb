Rails.application.routes.draw do
  devise_for :users
  resources :labels
 
  devise_scope :user do
    root to: "devise/sessions#new"  # Página de inicio en el login de Devise
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
  

  # ✅ Usuarios
  resources :users do
    collection do
      get 'edit_labels'     # Ruta para editar etiquetas de interés
      patch 'update_labels' # Ruta para actualizar etiquetas de interés
      get :export_xlsx      # Exportar usuarios
      get 'scan_qr', to: 'users#scan_qr'
    end

    member do
      delete 'remove_label/:label_id', to: 'users#remove_label', as: 'remove_label'
      
    end
  end

  # ✅ Ruta independiente para `my_events`
  get 'my_events', to: 'events#my_events', as: 'my_events'

  # ✅ Eventos
  resources :events do
    collection do
      get 'export_xlsx'  # Exportar eventos
      get 'my_events'
    end

    member do
      post 'confirm_attendance', to: 'events#confirm_attendance'
      post 'register'     # Inscribirse a un evento
      delete 'unregister' # Desinscribirse del evento
      get 'users', to: 'events#users', as: 'event_users'
      get 'export_users_xlsx'
      post 'update_points'
    end
  end

  # ✅ Etiquetas
  resources :labels, only: [:index, :new, :create, :destroy]
end



