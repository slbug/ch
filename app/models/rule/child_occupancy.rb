class Rule::ChildOccupancy < Rule::Base

  protected

    def self.availability_query(rooms, search)
      return rooms if search.max_children_count == 0

      range = range_to_string(search.period)

      rooms.
        joins(%(
          LEFT OUTER JOIN "#{Rule::Base.table_name}" "cor_hotels"
          ON "cor_hotels"."conformable_id" = "#{Hotel.table_name}"."id"
          AND "cor_hotels"."type" = '#{self.name}'
          AND "cor_hotels"."conformable_type" = '#{Hotel.name}')).
        joins(%(
          LEFT OUTER JOIN "#{Rule::Property.table_name}" "cor_hotels_properties"
          ON "cor_hotels_properties"."rule_id" = "cor_hotels"."id")).
        where(%(
          "cor_hotels"."id" IS NULL
          OR (
            "cor_hotels"."id" IS NOT NULL
            AND "cor_hotels_properties"."name" = :name
            AND "cor_hotels"."period" && :range::daterange
            AND :max <= "cor_hotels_properties"."value"::int
            AND NOT EXISTS (
              SELECT 1 FROM "#{Rule::Base.table_name}" "rb", "#{Rule::Property.table_name}" "rp"
              WHERE "cor_hotels"."conformable_id" = "rb"."conformable_id"
              AND "cor_hotels"."type" = "rb"."type"
              AND "cor_hotels"."conformable_type" = "rb"."conformable_type"
              AND "rp"."rule_id" = "rb"."id"
              AND "rp"."name" = "cor_hotels_properties"."name"
              AND "rb"."period" && :range::daterange
              AND "rb"."period" <> '(,)'::daterange
              AND :max > "rp"."value"::int
            )
          )), name: 'max', range: range, max: search.max_children_count)
    end

end
