class Search::Room < ActiveRecord::Base
  MAX_ADULTS_COUNT = 4
  MAX_CHILDREN_COUNT = 4
  CHILD_AGE_RANGE = (0...18) # age of 'i' means under 'i'. 0 can be 6 month, or 10 month

  belongs_to :base, class_name: 'Search::Base'

  attr_reader :children_count

  after_find :load_attributes

  before_validation :drop_children

  validates :adults_count, presence: true, numericality: true, inclusion: { in: 1..MAX_ADULTS_COUNT }
  validates :children_count, presence: true, numericality: true, inclusion: { in: 0..MAX_CHILDREN_COUNT }

  validate :must_have_valid_array_of_child_ages

  def attributes_for_uuid
    attributes.symbolize_keys.except(:id, :base_id, :created_at, :updated_at)
  end

  def children_count=(c)
    @children_count = (c || 0).to_i
  end

  private

    def load_attributes
      @children_count = children.size
    end

    def drop_children
      if children_count.to_i < children.size
        self.children = children.first(children_count)
      end
    end

    def must_have_valid_array_of_child_ages
      errors.add(:base, 'Child ages not filled') unless children_count == children.size

      return if children.empty?

      errors.add(:base, 'Too many children') if children.size > MAX_CHILDREN_COUNT

      errors.add(:base, 'Child too young') unless CHILD_AGE_RANGE.include?(children.min)
      errors.add(:base, 'Child too old') unless CHILD_AGE_RANGE.include?(children.max)
    end
end
