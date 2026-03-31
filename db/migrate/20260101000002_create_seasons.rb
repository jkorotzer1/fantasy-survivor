class CreateSeasons < ActiveRecord::Migration[7.1]
  def change
    create_table :seasons do |t|
      t.string  :name,          limit: 100, null: false
      t.integer :number,        null: false
      t.integer :year,          null: false
      t.integer :buy_in_cents,  default: 1000
      t.integer :merge_week
      t.integer :status,        default: 0, null: false

      t.timestamps
    end

    add_index :seasons, :number, unique: true
  end
end
