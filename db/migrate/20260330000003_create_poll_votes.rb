class CreatePollVotes < ActiveRecord::Migration[7.2]
  def change
    create_table :poll_votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :poll_option, null: false, foreign_key: true
      t.integer :message_id, null: false

      t.timestamps
    end

    add_index :poll_votes, [:user_id, :message_id], unique: true
    add_foreign_key :poll_votes, :messages
  end
end
