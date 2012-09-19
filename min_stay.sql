SELECT DISTINCT ON ("room_types"."id") "room_types".*, "hotels".*
  FROM "room_types"
  LEFT OUTER JOIN "hotels"
    ON "hotels"."id" = "room_types"."hotel_id"

  LEFT OUTER JOIN "rule_bases" "minimum_stay_rules_hotels"
    ON "minimum_stay_rules_hotels"."conformable_id" = "hotels"."id"
    AND "minimum_stay_rules_hotels"."type" = 'Rule::MinimumStay'
    AND "minimum_stay_rules_hotels"."conformable_type" = 'Hotel'

  LEFT OUTER JOIN "rule_properties" "minimum_stay_rules_hotels_properties"
    ON "minimum_stay_rules_hotels_properties"."rule_id" = "minimum_stay_rules_hotels"."id"

  WHERE "minimum_stay_rules_hotels"."id" IS NULL
    OR (
      "minimum_stay_rules_hotels"."id" IS NOT NULL
      AND "minimum_stay_rules_hotels".period && '[2012-11-25,2012-12-05)'::daterange
      AND (upper('[2012-11-25,2012-12-05)'::daterange) - lower('[2012-11-25,2012-12-05)'::daterange))::int >= "minimum_stay_rules_hotels_properties".value::int
      AND NOT EXISTS(
        SELECT 1
          FROM "rule_bases" "rb", "rule_properties" "rp"
          WHERE "minimum_stay_rules_hotels"."conformable_id" = "rb"."conformable_id"
            AND "minimum_stay_rules_hotels"."type" = "rb"."type"
            AND "minimum_stay_rules_hotels"."conformable_type" = "rb"."conformable_type"
            AND "rp"."rule_id" = "rb"."id"
            AND "rb".period  && '[2012-11-25,2012-12-05)'::daterange
            AND (upper('[2012-11-25,2012-12-05)'::daterange) - lower('[2012-11-25,2012-12-05)'::daterange))::int < "rp".value::int
          LIMIT 1
      )
    )
