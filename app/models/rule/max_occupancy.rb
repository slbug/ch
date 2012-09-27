class Rule::MaxOccupancy < Rule::Base

  protected

    def self.availability_query(rooms, search)
      range = range_to_string(search.period)

      rooms.
        joins(%(
          LEFT OUTER JOIN "#{Rule::Base.table_name}" "mor_rooms"
          ON "mor_rooms"."conformable_id" = "#{RoomType.table_name}"."id"
          AND "mor_rooms"."type" = '#{self.name}'
          AND "mor_rooms"."conformable_type" = '#{RoomType.name}')).
        joins(%(
          LEFT OUTER JOIN "#{Rule::Property.table_name}" "mor_rooms_properties"
          ON "mor_rooms_properties"."rule_id" = "mor_rooms"."id")).
        where(%(
          "mor_rooms"."id" IS NULL
          OR (
            "mor_rooms"."id" IS NOT NULL
            AND "mor_rooms_properties"."name" = :name
            AND "mor_rooms"."period" && :range::daterange
            AND :max <= "mor_rooms_properties"."value"::int
            AND NOT EXISTS (
              SELECT 1 FROM "#{Rule::Base.table_name}" "rb", "#{Rule::Property.table_name}" "rp"
              WHERE "mor_rooms"."conformable_id" = "rb"."conformable_id"
              AND "mor_rooms"."type" = "rb"."type"
              AND "mor_rooms"."conformable_type" = "rb"."conformable_type"
              AND "rp"."rule_id" = "rb"."id"
              AND "rp"."name" = "mor_rooms_properties"."name"
              AND "rb"."period" && :range::daterange
              AND "rb"."period" <> '(,)'::daterange
              AND :max > "rp"."value"::int
            )
          )), name: 'max', range: range, max: search.max_total_count)
    end

end
