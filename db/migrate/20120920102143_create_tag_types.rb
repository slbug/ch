class CreateTagTypes < ActiveRecord::Migration
  def change
    create_table :tag_types do |t|
      t.string :name, null: false
      t.integer :priority, default: 0, null: false

      t.timestamps
    end
    add_index :tag_types, :name, unique: true
  end
end
