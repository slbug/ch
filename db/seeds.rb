# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#

tag_types = TagType.create!([{ name: 'Island', priority: 3 }, { name: 'Country', priority: 2 }, { name: 'City', priority: 1 }]) do |t|
  30.times{ |i| t.tags.new(name: "#{t.name} #{i + 1}") }
end

9.times do |i|
  Hotel.create!(name: "Hotel #{i + 1}") do |h|
    rand(3).times do |k|
      h.tags << Tag.where(tag_type_id: tag_types[k].id).shuffle.first
    end

    9.times { |j| h.room_types.new(name: "Room #{i + 1}#{j + 1}") }
  end
end

