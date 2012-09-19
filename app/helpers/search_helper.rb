module SearchHelper
  def check_in_lower_bound
    Time.zone.now.hour < Search::Base::CHECK_OUT_HOUR ? Date.today : Date.today + 1.day
  end

  def check_out_lower_bound
    check_in_lower_bound + 1.day
  end

end
