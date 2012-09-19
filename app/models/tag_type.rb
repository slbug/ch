class TagType < ActiveRecord::Base
  has_many :tags, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validates :priority, presence: true, numericality: { greater_than: 0 }

  # priority - integer. higher is most important
end
