class UpdateContestantNicknames < ActiveRecord::Migration[7.2]
  def up
    execute "UPDATE contestants SET name = 'Benjamin \"Coach\" Wade' WHERE name = 'Benjamin Wade'"
    execute "UPDATE contestants SET name = 'Quintavius \"Q\" Burdette' WHERE name = 'Quintavius Burdette'"
  end

  def down
    execute "UPDATE contestants SET name = 'Benjamin Wade' WHERE name = 'Benjamin \"Coach\" Wade'"
    execute "UPDATE contestants SET name = 'Quintavius Burdette' WHERE name = 'Quintavius \"Q\" Burdette'"
  end
end
