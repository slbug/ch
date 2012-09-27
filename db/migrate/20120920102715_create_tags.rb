class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.boolean :live, null: false, default: false
      t.belongs_to :tag_type, index: true, null: false

      t.timestamps
    end
    add_index :tags, [:name, :tag_type_id], unique: true
  end
end
