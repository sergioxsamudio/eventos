namespace :users do
    desc "Restar puntos a usuarios que no asistieron a eventos pasados"
    task deduct_points: :environment do
      Event.where("end_time < ?", Time.current).each do |event|
        event.users.where(event_users: { attended: false }).find_each do |user|
          user.decrement!(:score, 300) # ❌ Restar 300 puntos si no asistió
          puts "Se restaron 300 puntos a #{user.email} por no asistir al evento #{event.title}"
        end
      end
    end
  end
  