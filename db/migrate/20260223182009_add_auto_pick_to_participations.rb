class AddAutoPickToParticipations < ActiveRecord::Migration[7.2]
  def change
    add_column :participations, :auto_pick, :boolean, default: false, null: false
  end
end
