class CreateSeasons < ActiveRecord::Migration
  def up
    create_table :seasons do |t|
      t.string :name, default: nil
      t.daterange :period, default: Range.new(-1.0/0, 1.0/0), null: false
      t.belongs_to :hotel, index: true, null: false, null: false

      t.timestamps
    end

    execute <<-SQL
      CREATE OR REPLACE FUNCTION update_rules_for_season() RETURNS trigger AS $$
      BEGIN
        UPDATE "#{Rule::Base.table_name}" SET "period" = NEW."period" WHERE "#{Rule::Base.table_name}"."season_id" = NEW."id";
        RETURN NEW;
      END
      $$ LANGUAGE 'plpgsql';

      CREATE OR REPLACE FUNCTION set_period_for_rules() RETURNS trigger AS $$
      BEGIN
        UPDATE "#{Rule::Base.table_name}"
          SET "period" = (SELECT "period" FROM "#{Season.table_name}" WHERE "id" = NEW."season_id" LIMIT 1)
          WHERE "#{Rule::Base.table_name}"."season_id" = NEW."season_id";
        RETURN NEW;
      END
      $$ LANGUAGE 'plpgsql';

      CREATE TRIGGER "update_rules_period" AFTER UPDATE OF "period" ON "#{Season.table_name}"
        FOR EACH ROW
        WHEN (OLD."period" IS DISTINCT FROM NEW."period")
        EXECUTE PROCEDURE update_rules_for_season();

      CREATE TRIGGER "update_rules_period" AFTER INSERT ON "#{Rule::Base.table_name}"
        FOR EACH ROW
        WHEN (NEW."season_id" IS NOT NULL)
        EXECUTE PROCEDURE set_period_for_rules();

    SQL
  end

  def down
    drop_table :seasons

    execute <<-SQL
      DROP TRIGGER IF EXISTS "update_rules_period" ON "seasons";
      DROP TRIGGER IF EXISTS "update_rules_period" ON "rules";
    SQL
  end
end
