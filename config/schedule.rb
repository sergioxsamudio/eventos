set :output, "log/cron.log" # Guardar logs para depuración

every 1.day, at: '00:00 am' do
  rake "users:deduct_points"
end

