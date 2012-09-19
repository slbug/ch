class CreateRoomTypes < ActiveRecord::Migration
  def change
    create_table :room_types do |t|
      t.string :name, null: false
      t.belongs_to :hotel, index: true, null: false

      t.timestamps
    end
  end
end
