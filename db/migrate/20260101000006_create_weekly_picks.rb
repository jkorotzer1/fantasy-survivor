class CreateWeeklyPicks < ActiveRecord::Migration[7.1]
  def change
    create_table :weekly_picks do |t|
      t.references :participation, null: false, foreign_key: true
      t.references :week,          null: false, foreign_key: true
      t.references :contestant,    null: false, foreign_key: true

      t.timestamps
    end

    add_index :weekly_picks, [:participation_id, :week_id], unique: true
  end
end
