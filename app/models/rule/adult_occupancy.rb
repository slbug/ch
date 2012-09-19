class Rule::AdultOccupancy < Rule::Base

  protected

    def self.availability_query(rooms, search)
      range = range_to_string(search.period)

      rooms.
        joins(%(
          LEFT OUTER JOIN "#{Rule::Base.table_name}" "aor_hotels"
          ON "aor_hotels"."conformable_id" = "#{Hotel.table_name}"."id"
          AND "aor_hotels"."type" = '#{self.name}'
          AND "aor_hotels"."conformable_type" = '#{Hotel.name}')).
        joins(%(
          LEFT OUTER JOIN "#{Rule::Property.table_name}" "aor_hotels_properties"
          ON "aor_hotels_properties"."rule_id" = "aor_hotels"."id")).
        where(%(
          "aor_hotels"."id" IS NULL
          OR (
            "aor_hotels"."id" IS NOT NULL
            AND "aor_hotels_properties"."name" = :name
            AND "aor_hotels"."period" && :range::daterange
            AND :max <= "aor_hotels_properties"."value"::int
            AND NOT EXISTS (
              SELECT 1 FROM "#{Rule::Base.table_name}" "rb", "#{Rule::Property.table_name}" "rp"
              WHERE "aor_hotels"."conformable_id" = "rb"."conformable_id"
              AND "aor_hotels"."type" = "rb"."type"
              AND "aor_hotels"."conformable_type" = "rb"."conformable_type"
              AND "rp"."rule_id" = "rb"."id"
              AND "rp"."name" = "aor_hotels_properties"."name"
              AND "rb"."period" && :range::daterange
              AND "rb"."period" <> '(,)'::daterange
              AND :max > "rp"."value"::int
            )
          )), name: 'max', range: range, max: search.max_adults_count)
    end

end
