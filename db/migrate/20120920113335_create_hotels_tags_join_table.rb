class CreateHotelsTagsJoinTable < ActiveRecord::Migration
  def change
    create_join_table 'hotels', 'tags' do |t|
      # t.index [:hotel_id, :tag_id]
      t.index [:tag_id, :hotel_id]
    end
  end
end
