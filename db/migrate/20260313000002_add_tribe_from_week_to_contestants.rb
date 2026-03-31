class AddTribeFromWeekToContestants < ActiveRecord::Migration[7.2]
  def up
    add_column :contestants, :tribe_from_week, :integer

    # Convert any existing previous_tribes entries from plain strings to
    # {name, from, to} hashes so the richer format is consistent from here on.
    Contestant.reset_column_information
    Contestant.find_each do |c|
      tribes = Array(c.previous_tribes).compact
      next if tribes.empty? || tribes.first.is_a?(Hash)

      c.update_column(
        :previous_tribes,
        JSON.generate(tribes.map { |t| { "name" => t.to_s, "from" => nil, "to" => nil } })
      )
    end
  end

  def down
    remove_column :contestants, :tribe_from_week
  end
end
