class CreatePollOptions < ActiveRecord::Migration[7.2]
  def change
    create_table :poll_options do |t|
      t.references :message, null: false, foreign_key: true
      t.string :label, null: false

      t.timestamps
    end
  end
end
