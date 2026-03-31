class CreateWeeks < ActiveRecord::Migration[7.1]
  def change
    create_table :weeks do |t|
      t.references :season,         null: false, foreign_key: true
      t.integer    :number,         null: false
      t.date       :air_date
      t.datetime   :picks_locked_at, null: false
      t.boolean    :scored,          default: false, null: false

      t.timestamps
    end

    add_index :weeks, [:season_id, :number], unique: true
  end
end
