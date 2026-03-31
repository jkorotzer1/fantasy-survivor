class CreateWinnerPicks < ActiveRecord::Migration[7.1]
  def change
    create_table :winner_picks do |t|
      t.references :participation, null: false, foreign_key: true, index: false
      t.references :contestant,    null: false, foreign_key: true
      t.integer    :week_locked,   null: false

      t.timestamps
    end

    add_index :winner_picks, :participation_id, unique: true
  end
end
