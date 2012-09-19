class CreateSearchRooms < ActiveRecord::Migration
  def change
    create_table :search_rooms do |t|
      t.belongs_to :base, index: true, null: false
      t.integer :adults_count, default: 2, null: false
      t.integer :children, array: true, length: 2, default: [], null: false

      t.timestamps
    end
  end
end
