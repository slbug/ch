class Rule::MinimumStay < Rule::Base
  # TODO
  # validates :season_id, presence: true

  protected

    def self.availability_query(rooms, search)
      nights = search.period.count
      range = range_to_string(search.period)

      rooms.
        joins(%(
          LEFT OUTER JOIN "#{Rule::Base.table_name}" "msr_hotels"
          ON "msr_hotels"."conformable_id" = "#{Hotel.table_name}"."id"
          AND "msr_hotels"."type" = '#{self.name}'
          AND "msr_hotels"."conformable_type" = '#{Hotel.name}')).
        joins(%(
          LEFT OUTER JOIN "#{Rule::Property.table_name}" "msr_hotels_properties"
          ON "msr_hotels_properties"."rule_id" = "msr_hotels"."id")).
        where(%(
          "msr_hotels"."id" IS NULL
          OR (
            "msr_hotels"."id" IS NOT NULL
            AND "msr_hotels_properties"."name" = :name
            AND "msr_hotels"."period" && :range::daterange
            AND :nights >= "msr_hotels_properties"."value"::int
            AND NOT EXISTS (
              SELECT 1 FROM "#{Rule::Base.table_name}" "rb", "#{Rule::Property.table_name}" "rp"
              WHERE "msr_hotels"."conformable_id" = "rb"."conformable_id"
              AND "msr_hotels"."type" = "rb"."type"
              AND "msr_hotels"."conformable_type" = "rb"."conformable_type"
              AND "rp"."rule_id" = "rb"."id"
              AND "rp"."name" = "msr_hotels_properties"."name"
              AND "rb"."period" && :range::daterange
              AND "rb"."period" <> '(,)'::daterange
              AND :nights < "rp"."value"::int
            )
          )), name: 'nights', range: range, nights: nights)
    end
end
