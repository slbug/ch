class Rule::StopSale < Rule::Base

  protected

    def self.availability_query(rooms, search)
      range = range_to_string(search.period)

      rooms.
        where(%(
          NOT EXISTS(
            SELECT 1 FROM "#{Rule::Base.table_name}" "ssr_rooms"
            WHERE "ssr_rooms"."conformable_id" = "#{RoomType.table_name}"."id"
            AND "ssr_rooms"."type" = '#{self.name}'
            AND "ssr_rooms"."conformable_type" = '#{RoomType.name}'
            AND "ssr_rooms"."period" && :range::daterange
          )), range: range)

    end
end
