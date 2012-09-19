class CreateRuleProperties < ActiveRecord::Migration
  def change
    create_table :rule_properties do |t|
      t.belongs_to :rule, index: true, null: false
      t.string :name, null: false
      t.string :value, null: false

      t.timestamps
    end

    add_index :rule_properties, [:rule_id, :name]
  end
end
