class SearchController < ApplicationController
  expose(:search) { params[:uuid] ? Search::Base.find_by_uuid(params[:uuid]) : Search::Base.new(search_params) }

  def create
    if search.save
      redirect_to search_url(search)
    else
      render 'welcome/index'
    end
  end

  def show
    search.perform.load
    if search.results.map(&:hotel_id).uniq.size == 1
      render 'rooms'
    else
      render 'hotels'
    end
  end

  private

    def search_params
      params.require(:search).permit(*search_attributes)
    end

    def search_attributes
      [:where, :check_in, :check_out, :rooms_count].tap do |attributes|
        attributes << { rooms_attributes: room_attributes }
      end
    end

    def room_attributes
      [:adults_count, :children_count, :children]
    end

end
