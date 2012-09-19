class Rule::Property < ActiveRecord::Base
  belongs_to :rule, class_name: 'Rule::Base'

  validates :value, presence: true
  validates :name, presence: true, uniqueness: { scope: :rule_id }

end
