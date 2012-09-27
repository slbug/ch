class Rule::AdultOccupancy < Rule::Base

  protected

    def self.availability_query(rooms, search)
      range = range_to_string(search.period)

      rooms.
        joins(%(
          LEFT OUTER JOIN "#{Rule::Base.table_name}" "aor_rooms"
          ON "aor_rooms"."conformable_id" = "#{RoomType.table_name}"."id"
          AND "aor_rooms"."type" = '#{self.name}'
          AND "aor_rooms"."conformable_type" = '#{RoomType.name}')).
        joins(%(
          LEFT OUTER JOIN "#{Rule::Property.table_name}" "aor_rooms_properties"
          ON "aor_rooms_properties"."rule_id" = "aor_rooms"."id")).
        where(%(
          "aor_rooms"."id" IS NULL
          OR (
            "aor_rooms"."id" IS NOT NULL
            AND "aor_rooms_properties"."name" = :name
            AND "aor_rooms"."period" && :range::daterange
            AND :max <= "aor_rooms_properties"."value"::int
            AND NOT EXISTS (
              SELECT 1 FROM "#{Rule::Base.table_name}" "rb", "#{Rule::Property.table_name}" "rp"
              WHERE "aor_rooms"."conformable_id" = "rb"."conformable_id"
              AND "aor_rooms"."type" = "rb"."type"
              AND "aor_rooms"."conformable_type" = "rb"."conformable_type"
              AND "rp"."rule_id" = "rb"."id"
              AND "rp"."name" = "aor_rooms_properties"."name"
              AND "rb"."period" && :range::daterange
              AND "rb"."period" <> '(,)'::daterange
              AND :max > "rp"."value"::int
            )
          )), name: 'max', range: range, max: search.max_adults_count)
    end

end
