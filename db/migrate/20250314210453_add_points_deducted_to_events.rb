class AddPointsDeductedToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :points_deducted, :boolean
  end
end
