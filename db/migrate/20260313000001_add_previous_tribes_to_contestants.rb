class AddPreviousTribesToContestants < ActiveRecord::Migration[7.2]
  def change
    add_column :contestants, :previous_tribes, :text
  end
end
