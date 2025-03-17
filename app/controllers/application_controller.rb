class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end

  protected

  # Configurar a dónde redirigir después del login
  def after_sign_in_path_for(resource)
    if resource.has_role?(:admin)
      users_path  # Si es admin, lo lleva a la lista de usuarios
    else
      events_path  # Si es usuario normal, lo lleva a la lista de eventos
    end
  end
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path  # Redirige al login de Devise
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone_number])
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone_number])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone_number])
  end
end

