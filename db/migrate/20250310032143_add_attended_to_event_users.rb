class AddAttendedToEventUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :event_users, :attended, :boolean
  end
end
