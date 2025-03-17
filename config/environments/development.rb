require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Configuración de Action Mailer con Letter Opener
  # Configuración de Action Mailer con Letter Opener
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true

  # Configurar el host para los enlaces en los correos
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
  config.action_mailer.asset_host = "http://localhost:3000"

  # Evita problemas con emails en segundo plano
  config.active_job.queue_adapter = :inline

  # Muestra errores detallados en desarrollo
  config.consider_all_requests_local = true

  # Configuración para ActiveJob (evita problemas con emails en segundo plano)
  config.active_job.queue_adapter = :inline

  # Configuración de recarga de código
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true

  # Configuración de caché
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.public_file_server.headers = { "cache-control" => "public, max-age=#{2.days.to_i}" }
  else
    config.action_controller.perform_caching = false
  end
  config.cache_store = :memory_store

  # Almacenamiento de archivos
  config.active_storage.service = :local

  # Configuración de errores en emails
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false

  # Logs y depuración
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.active_record.query_log_tags_enabled = true
  config.active_job.verbose_enqueue_logs = true
  config.action_view.annotate_rendered_view_with_filenames = true
  config.action_controller.raise_on_missing_callback_actions = true
end


