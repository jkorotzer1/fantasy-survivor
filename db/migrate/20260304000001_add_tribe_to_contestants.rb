class AddTribeToContestants < ActiveRecord::Migration[7.2]
  # purple = Vatu, orange = Cila, teal = Calo
  TRIBES = {
    "vatu" => [
      "Colby Donaldson",
      "Kyle Fraser",
      "Quintavius Burdette",
      "Rizo Velovic",
      "Angelina Keeley",
      "Aubry Bracco",
      "Genevieve Mushaluk",
      "Stephenie LaGrossa Kendrick",
    ],
    "cila" => [
      "Christian Hubicki",
      "Joe Hunter",
      "Ozzy Lusth",
      "Rick Devens",
      "Cirie Fields",
      "Emily Flippen",
      "Jenna Lewis-Dougherty",
      "Savannah Louie",
    ],
    "calo" => [
      "Charlie Davis",
      "Benjamin Wade",
      "Jonathan Young",
      "Mike White",
      "Chrissy Hofbeck",
      "Dee Valladares",
      "Kamilla Karthigesu",
      "Tiffany Nicole Ervin",
    ],
  }.freeze

  def up
    add_column :contestants, :tribe, :string

    TRIBES.each do |tribe_name, names|
      names.each do |name|
        execute "UPDATE contestants SET tribe = '#{tribe_name}' WHERE name = '#{name.gsub("'", "''")}'"
      end
    end
  end

  def down
    remove_column :contestants, :tribe
  end
end
