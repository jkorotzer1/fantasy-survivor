class CreateContestants < ActiveRecord::Migration[7.1]
  def change
    create_table :contestants do |t|
      t.references :season,         null: false, foreign_key: true
      t.string     :name,           limit: 100, null: false
      t.integer    :status,         default: 0, null: false
      t.integer    :eliminated_week

      t.timestamps
    end

    add_index :contestants, [:season_id, :name], unique: true
  end
end
