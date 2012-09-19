class RoomType < ActiveRecord::Base
  ALLOWED_RULES = [
    Rule::AdultOccupancy, Rule::ChildOccupancy,
    Rule::ExtraRate,      Rule::Fee,
    Rule::Markup,         Rule::MaxOccupancy,
    Rule::ServiceCharge,  Rule::StopSale
  ]

  belongs_to :hotel

  has_many :rules, as: :conformable, class_name: 'Rule::Base', dependent: :destroy

  ALLOWED_RULES.each do |klass|
    has_many :"#{klass.name.gsub('Rule::', '').underscore}_rules", -> { where(type: klass.name) }, as: :conformable, class_name: 'Rule::Base'
  end

  validates :name, presence: true, uniqueness: { scope: :hotel_id }

  validate :must_have_only_allowed_rules

  private

    def must_have_only_allowed_rules
      if rules.index { |rule| !ALLOWED_RULES.include?(rule.class) }.present?
        errors.add(:base, "Wrong set of rules used. Only #{ALLOWED_RULES.map(&:to_s).join(', ')} allowed")
      end
    end

end
