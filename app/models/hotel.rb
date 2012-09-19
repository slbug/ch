class Hotel < ActiveRecord::Base
  ALLOWED_RULES = [
    Rule::ExtraRate,     Rule::Fee,
    Rule::FreeChildren,  Rule::MarkupCalculation,
    Rule::Markup,        Rule::MinimumStay,
    Rule::ServiceCharge, Rule::TaxInclusion,
    Rule::Tax
  ]

  has_many :room_types
  has_many :rules, as: :conformable, class_name: 'Rule::Base', dependent: :destroy
  has_and_belongs_to_many :tags

  ALLOWED_RULES.each do |klass|
    has_many :"#{klass.name.gsub('Rule::', '').underscore}_rules", -> { where(type: klass.name) }, as: :conformable, class_name: 'Rule::Base'
  end

  validates :name, presence: true

  validate :must_not_have_tags_with_same_type
  validate :must_have_only_allowed_rules
  validate :must_have_only_one_tax_inclusion_rule

  private

    def must_not_have_tags_with_same_type
      types = tags.map(&:tag_type)
      errors.add(:base, 'Only one tag per tag type allowed') unless types.size == types.uniq.size
    end

    def must_have_only_allowed_rules
      if rules.index { |rule| !ALLOWED_RULES.include?(rule.class) }.present?
        errors.add(:base, "Wrong set of rules used. Only #{ALLOWED_RULES.map(&:to_s).join(', ')} allowed")
      end
    end

    def must_have_only_one_tax_inclusion_rule
      if rules.select { |rule| rule.class == Rule::TaxInclusion }.count > 1
        errors.add(:base, 'Only one TaxInclusion allowed')
      end
    end

end
