class Tag < ActiveRecord::Base
  ALLOWED_RULES = [
    Rule::Markup, Rule::Tax
  ]

  has_many :rules, as: :conformable, dependent: :destroy, class_name: 'Rule::Base'
  has_and_belongs_to_many :hotels
  belongs_to :tag_type

  ALLOWED_RULES.each do |klass|
    has_many :"#{klass.name.gsub('Rule::', '').underscore}_rules", -> { where(type: klass.name) }, as: :conformable, class_name: 'Rule::Base'
  end

  validates :name, presence: true, uniqueness: { scope: :tag_type_id }

  validate :must_have_only_allowed_rules

  private

    def must_have_only_allowed_rules
      if rules.index { |rule| !ALLOWED_RULES.include?(rule.class) }.present?
        errors.add(:base, "Wrong set of rules used. Only #{ALLOWED_RULES.map(&:to_s).join(', ')} allowed")
      end
    end
end
