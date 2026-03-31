class AddLastBoardVisitToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :last_board_visit_at, :datetime
  end
end
