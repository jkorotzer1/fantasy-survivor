class CreateScoringEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :scoring_events do |t|
      t.references :contestant, null: false, foreign_key: true
      t.references :week,       null: false, foreign_key: true
      t.string     :event_type, limit: 50, null: false
      t.text       :notes

      t.timestamps
    end

    add_index :scoring_events, [:contestant_id, :week_id, :event_type]
  end
end
