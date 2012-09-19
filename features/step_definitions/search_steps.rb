When /^I submit search form with valid data$/ do
  fill_in 'Where', with: 'Barbados (all)'
  fill_in 'Check In', with: (Date.today + 1.day).to_s
  fill_in 'Check Out', with: (Date.today + 10.days).to_s
  select '1', from: 'Rooms'
  within('div[data-room="0"]') do
    select '2', from: 'Adults'
    select '0', from: 'Children'
  end
  click_button 'Search Hotels'
end

Then /^I should see the page for search results$/ do
  pending
end

Then /^I should see the list of hotels$/ do
  pending
end
