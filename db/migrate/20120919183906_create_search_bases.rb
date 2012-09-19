class CreateSearchBases < ActiveRecord::Migration
  def change
    create_table :search_bases do |t|
      t.string :where, null: false
      t.daterange :period, null: false
      t.string :uuid, limit: 32, null: false

      t.timestamps
    end
    add_index :search_bases, :uuid, unique: true
  end
end
