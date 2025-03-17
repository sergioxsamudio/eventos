class CreateEventLabels < ActiveRecord::Migration[8.0]
  def change
    create_table :event_labels do |t|
      t.references :event, null: false, foreign_key: true
      t.references :label, null: false, foreign_key: true

      t.timestamps
    end
  end
end
