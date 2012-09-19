class WelcomeController < ApplicationController
  expose(:search) { Search::Base.new.tap{|s| s.rooms.build } }
end
