class Season < ActiveRecord::Base
  belongs_to :hotel

  has_many :rules, dependent: :destroy, class_name: 'Rule::Base'
end
