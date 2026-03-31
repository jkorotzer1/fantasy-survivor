class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :parent_id
      t.text :body, null: false
      t.boolean :pinned, default: false, null: false
      t.boolean :anonymous, default: false, null: false

      t.timestamps
    end

    add_index :messages, :parent_id
    add_index :messages, [:pinned, :created_at]
  end
end
