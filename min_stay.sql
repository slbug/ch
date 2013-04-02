SELECT DISTINCT ON ("room_types"."id") "room_types".*
FROM "room_types"

LEFT OUTER JOIN "hotels" ON "hotels"."id" = "room_types"."hotel_id"
LEFT OUTER JOIN "hotels_tags" ON "hotels_tags"."hotel_id" = "hotels"."id"
LEFT OUTER JOIN "tags" ON "tags"."id" = "hotels_tags"."tag_id"

LEFT OUTER JOIN "rule_bases" "mor_rooms" ON "mor_rooms"."conformable_id" = "room_types"."id"
  AND "mor_rooms"."type" = 'Rule::MaxOccupancy'
  AND "mor_rooms"."conformable_type" = 'RoomType'
LEFT OUTER JOIN "rule_properties" "mor_rooms_properties" ON "mor_rooms_properties"."rule_id" = "mor_rooms"."id"

LEFT OUTER JOIN "rule_bases" "msr_hotels" ON "msr_hotels"."conformable_id" = "hotels"."id"
  AND "msr_hotels"."type" = 'Rule::MinimumStay'
  AND "msr_hotels"."conformable_type" = 'Hotel'
LEFT OUTER JOIN "rule_properties" "msr_hotels_properties" ON "msr_hotels_properties"."rule_id" = "msr_hotels"."id"

LEFT OUTER JOIN "rule_bases" "cor_rooms" ON "cor_rooms"."conformable_id" = "room_types"."id"
  AND "cor_rooms"."type" = 'Rule::ChildOccupancy'
  AND "cor_rooms"."conformable_type" = 'RoomType'
LEFT OUTER JOIN "rule_properties" "cor_rooms_properties" ON "cor_rooms_properties"."rule_id" = "cor_rooms"."id"

LEFT OUTER JOIN "rule_bases" "aor_rooms" ON "aor_rooms"."conformable_id" = "room_types"."id"
  AND "aor_rooms"."type" = 'Rule::AdultOccupancy'
  AND "aor_rooms"."conformable_type" = 'RoomType'
LEFT OUTER JOIN "rule_properties" "aor_rooms_properties" ON "aor_rooms_properties"."rule_id" = "aor_rooms"."id"

WHERE "hotels"."live" = 't' AND "tags"."live" = 't' AND ("hotels"."name" = 'Barbados' OR "tags"."name" = 'Barbados')
  AND ( "mor_rooms"."id" IS NULL
    OR ("mor_rooms"."id" IS NOT NULL
      AND "mor_rooms_properties"."name" = 'max'
      AND "mor_rooms"."period" && '[2012-10-31,2012-11-15)'::daterange
      AND 4 <= "mor_rooms_properties"."value"::int
      AND NOT EXISTS (
        SELECT 1 FROM "rule_bases" "rb", "rule_properties" "rp"
        WHERE "mor_rooms"."conformable_id" = "rb"."conformable_id"
          AND "mor_rooms"."type" = "rb"."type"
          AND "mor_rooms"."conformable_type" = "rb"."conformable_type"
          AND "rp"."rule_id" = "rb"."id"
          AND "rp"."name" = "mor_rooms_properties"."name"
          AND "rb"."period" && '[2012-10-31,2012-11-15)'::daterange
          AND "rb"."period" <> '(,)'::daterange
          AND 4 > "rp"."value"::int
      )
    )
  ) AND (
    NOT EXISTS(
      SELECT 1 FROM "rule_bases" "ssr_rooms"
      WHERE "ssr_rooms"."conformable_id" = "room_types"."id"
        AND "ssr_rooms"."type" = 'Rule::StopSale'
        AND "ssr_rooms"."conformable_type" = 'RoomType'
        AND "ssr_rooms"."period" && '[2012-10-31,2012-11-15)'::daterange
    )
  ) AND ("msr_hotels"."id" IS NULL
      OR ("msr_hotels"."id" IS NOT NULL
        AND "msr_hotels_properties"."name" = 'nights'
        AND "msr_hotels"."period" && '[2012-10-31,2012-11-15)'::daterange
        AND 15 >= "msr_hotels_properties"."value"::int
        AND NOT EXISTS (
          SELECT 1 FROM "rule_bases" "rb", "rule_properties" "rp"
          WHERE "msr_hotels"."conformable_id" = "rb"."conformable_id"
            AND "msr_hotels"."type" = "rb"."type"
            AND "msr_hotels"."conformable_type" = "rb"."conformable_type"
            AND "rp"."rule_id" = "rb"."id"
            AND "rp"."name" = "msr_hotels_properties"."name"
            AND "rb"."period" && '[2012-10-31,2012-11-15)'::daterange
            AND "rb"."period" <> '(,)'::daterange
            AND 15 < "rp"."value"::int
        )
      )
  ) AND ("cor_rooms"."id" IS NULL
      OR ("cor_rooms"."id" IS NOT NULL
        AND "cor_rooms_properties"."name" = 'max'
        AND "cor_rooms"."period" && '[2012-10-31,2012-11-15)'::daterange
        AND 1 <= "cor_rooms_properties"."value"::int
        AND NOT EXISTS (
          SELECT 1 FROM "rule_bases" "rb", "rule_properties" "rp"
          WHERE "cor_rooms"."conformable_id" = "rb"."conformable_id"
            AND "cor_rooms"."type" = "rb"."type"
            AND "cor_rooms"."conformable_type" = "rb"."conformable_type"
            AND "rp"."rule_id" = "rb"."id"
            AND "rp"."name" = "cor_rooms_properties"."name"
            AND "rb"."period" && '[2012-10-31,2012-11-15)'::daterange
            AND "rb"."period" <> '(,)'::daterange
            AND 1 > "rp"."value"::int
        )
      )
  ) AND ("aor_rooms"."id" IS NULL
      OR ("aor_rooms"."id" IS NOT NULL
        AND "aor_rooms_properties"."name" = 'max'
        AND "aor_rooms"."period" && '[2012-10-31,2012-11-15)'::daterange
        AND 3 <= "aor_rooms_properties"."value"::int
        AND NOT EXISTS (
          SELECT 1 FROM "rule_bases" "rb", "rule_properties" "rp"
          WHERE "aor_rooms"."conformable_id" = "rb"."conformable_id"
            AND "aor_rooms"."type" = "rb"."type"
            AND "aor_rooms"."conformable_type" = "rb"."conformable_type"
            AND "rp"."rule_id" = "rb"."id"
            AND "rp"."name" = "aor_rooms_properties"."name"
            AND "rb"."period" && '[2012-10-31,2012-11-15)'::daterange
            AND "rb"."period" <> '(,)'::daterange
            AND 3 > "rp"."value"::int
        )
      )
  )

