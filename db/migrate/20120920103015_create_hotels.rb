class CreateHotels < ActiveRecord::Migration
  def change
    create_table :hotels do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :hotels, :name
  end
end
