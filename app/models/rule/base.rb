class Rule::Base < ActiveRecord::Base
  belongs_to :conformable, polymorphic: true
  belongs_to :season

  has_many :properties, class_name: 'Rule::Property', foreign_key: :rule_id

  scope :active_for_today, -> {
    where(%("#{table_name}"."period" @> ?::date), Date.today).
      order(%(upper_inf("#{table_name}"."period") ASC)).
      limit(1)
  }

  def active?
    period.include(Date.today) # TODO check if there is another active
  end

  # TODO do not overlap dates
  #  validate :periods_must_not_overlap
  #  index on period

  def self.get_results(search)
    raise 'Something went wrong' if descendants.blank?

    # fetching room_types based on rules
    rooms = base_query(RoomType.select(%(DISTINCT ON ("#{RoomType.table_name}"."id") "#{RoomType.table_name}".*)), search)
    descendants.each do |rule|
      rooms = rule.availability_query(rooms, search)
    end
    # TODO as prepared statement
    # NOTE currently we don't have rules with inheritance for availablity. if we will add, then adjust search
    rooms
  end

  protected

    def self.availability_query(rooms, search)
      rooms
    end

    def self.base_query(rooms, search)
      hotels_tags = [Hotel.table_name, Tag.table_name].sort.join('_')
      rooms.
        joins(%(
          LEFT OUTER JOIN "#{Hotel.table_name}" ON "#{Hotel.table_name}"."id" = "#{RoomType.table_name}"."hotel_id"
          LEFT OUTER JOIN "#{hotels_tags}" ON "#{hotels_tags}"."hotel_id" = "#{Hotel.table_name}"."id"
          LEFT OUTER JOIN "#{Tag.table_name}" ON "#{Tag.table_name}"."id" = "#{hotels_tags}"."tag_id")).
        where(%("#{Hotel.table_name}"."name" = :where OR "#{Tag.table_name}"."name" = :where), where: search.where)
    end

    def self.range_to_string(range)
      ActiveRecord::ConnectionAdapters::PostgreSQLColumn.range_to_string(range)
    end

    def range_to_string(range)
      self.range_to_string(range)
    end
end

