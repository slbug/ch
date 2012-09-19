class Search::Base < ActiveRecord::Base
  CHECK_OUT_HOUR  = 12
  MAX_ROOMS_COUNT = 4

  has_many :rooms, class_name: 'Search::Room', dependent: :destroy
  accepts_nested_attributes_for :rooms, limit: MAX_ROOMS_COUNT
  attr_reader :check_in, :check_out, :rooms_count, :exclude_end

  after_find :load_attributes

  before_validation :drop_rooms
  before_validation :assign_period

  validates :where, presence: true, length: { minimum: 1 }
  validates :rooms_count, presence: true, inclusion: { in: 1..MAX_ROOMS_COUNT }

  validate :must_have_valid_period
  validate :must_have_valid_hotel_or_tag
  validate :must_have_valid_number_of_rooms

  after_validation :calculate_uuid

  def check_in=(date)
    @check_in = convert_date(date)
  end

  def check_out=(date)
    @check_out = convert_date(date)
  end

  def rooms_count=(c)
    @rooms_count = c.to_i
  end

  def perform
    save

    @results ||= {}
    # TODO ask cache for results
    @results[uuid] = Rule::Base.get_results(self)
    # TODO put async jobs for API searches
    # TODO cache results
    @results[uuid]
  end

  def results
    @results[uuid] || (raise 'call perform first')
  end

  def hotels
    Hotel.find(results.map(&:hotel_id).uniq)
  end

  def to_param
    uuid
  end

  def max_adults_count
    rooms.map(&:adults_count).max
  end

  def max_children_count
    rooms.map(&:children_count).max
  end

  def max_total_count
    rooms.map{ |r| r.adults_count + r.children_count }.max
  end

  protected

    def create_or_update
      search = Search::Base.find_by_uuid(uuid)

      if search
        # we don't want to have unsaved rooms which came from search form
        self.rooms = search.rooms if search.new_record?
        self.rooms.reload unless search.new_record?
      end

      # threat new record as saved if uuid exists. will update just updated_at
      # if no records found (can happen on loaded record, because uuid will be recalculated)
      # ensure that id is nil, so loaded record won't be overwritten on update
      @new_record = search.nil?
      self.id = @new_record ? nil : search.id

      super
    end

  private

    def load_attributes
      @check_in, @check_out, @rooms_count, @exclude_end = period.begin, period.end, rooms.count, period.exclude_end?
    end

    def drop_rooms
      if rooms_count < rooms.size
        self.rooms = rooms.first(rooms_count)
      end
    end

    def assign_period
      self.period = Range.new(check_in, check_out, exclude_end || true)
    rescue ArgumentError
      errors.add(:base, "Check In or Check Out is invalid")
    end

    def must_have_valid_period
      return if period.blank?

      if check_in.blank? || check_out.blank?
        errors.add(:base, "Check In and Check Out can't be blank")
        return
      end

      start = Time.zone.now.hour < CHECK_OUT_HOUR ? Date.today : Date.today + 1.day

      errors.add(:check_in, "Check In date must be after #{check_in}") if period.begin < start
      errors.add(:check_out, "Check Out date must be after #{check_out}") if period.end < start + 1.day
      errors.add(:check_out, "Check Out date must be after Check In date") if period.end <= period.begin
    end

    def must_have_valid_hotel_or_tag
      hotel = Hotel.find_by_name(where)
      tag = Tag.find_by_name(where)

      errors.add(:base, "No such place") if hotel.nil? && tag.nil?
    end

    def must_have_valid_number_of_rooms
      errors.add(:base, "Rooms count is invalid") unless (1..MAX_ROOMS_COUNT).include?(rooms.size)
      errors.add(:base, "Not all rooms filled") unless rooms_count == rooms.size
    end

    def calculate_uuid
      return if errors.any?

      attrs = attributes_for_uuid
      attrs[:rooms] = rooms.map(&:attributes_for_uuid)

      self.uuid = Digest::MD5.hexdigest(attrs.to_s)
    end

    def attributes_for_uuid
      attributes.symbolize_keys.except(:id, :created_at, :updated_at, :uuid, :period).merge(
        { period_begin: period.begin, period_count: period.count }
      )
    end

    def convert_date(date)
      date.respond_to?(:to_date) ? date.to_date : Date.parse(date)
    rescue
      nil
    end
end
