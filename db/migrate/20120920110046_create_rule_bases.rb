class CreateRuleBases < ActiveRecord::Migration
  def change
    create_table :rule_bases do |t|
      t.references :conformable, polymorphic: true, index: true, null: false
      t.string :type, null: false, index: true
      t.belongs_to :season, default: nil
      t.daterange :period, default: Range.new(-1.0/0, 1.0/0), null: false

      t.timestamps
    end
  end
end
