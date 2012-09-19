class Rule::MaxOccupancy < Rule::Base

  protected

    def self.availability_query(rooms, search)
      range = range_to_string(search.period)

      rooms.
        joins(%(
          LEFT OUTER JOIN "#{Rule::Base.table_name}" "mor_hotels"
          ON "mor_hotels"."conformable_id" = "#{Hotel.table_name}"."id"
          AND "mor_hotels"."type" = '#{self.name}'
          AND "mor_hotels"."conformable_type" = '#{Hotel.name}')).
        joins(%(
          LEFT OUTER JOIN "#{Rule::Property.table_name}" "mor_hotels_properties"
          ON "mor_hotels_properties"."rule_id" = "mor_hotels"."id")).
        where(%(
          "mor_hotels"."id" IS NULL
          OR (
            "mor_hotels"."id" IS NOT NULL
            AND "mor_hotels_properties"."name" = :name
            AND "mor_hotels"."period" && :range::daterange
            AND :max <= "mor_hotels_properties"."value"::int
            AND NOT EXISTS (
              SELECT 1 FROM "#{Rule::Base.table_name}" "rb", "#{Rule::Property.table_name}" "rp"
              WHERE "mor_hotels"."conformable_id" = "rb"."conformable_id"
              AND "mor_hotels"."type" = "rb"."type"
              AND "mor_hotels"."conformable_type" = "rb"."conformable_type"
              AND "rp"."rule_id" = "rb"."id"
              AND "rp"."name" = "mor_hotels_properties"."name"
              AND "rb"."period" && :range::daterange
              AND "rb"."period" <> '(,)'::daterange
              AND :max > "rp"."value"::int
            )
          )), name: 'max', range: range, max: search.max_total_count)
    end

end
