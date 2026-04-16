class CreateEmailLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :email_logs do |t|
      t.string :recipient_email, null: false
      t.references :week, null: false, foreign_key: true
      t.string :mailer, null: false
      t.string :status, null: false   # "sent" or "failed"
      t.text :error_message

      t.timestamps
    end

    add_index :email_logs, [:recipient_email, :week_id, :mailer]
    add_index :email_logs, :status
  end
end
