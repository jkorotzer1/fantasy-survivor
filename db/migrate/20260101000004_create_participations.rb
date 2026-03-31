class CreateParticipations < ActiveRecord::Migration[7.1]
  def change
    create_table :participations do |t|
      t.references :user,   null: false, foreign_key: true
      t.references :season, null: false, foreign_key: true
      t.boolean    :paid_in, default: false, null: false

      t.timestamps
    end

    add_index :participations, [:user_id, :season_id], unique: true
  end
end
