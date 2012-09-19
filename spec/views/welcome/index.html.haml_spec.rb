require 'spec_helper'

describe "welcome/index.html.haml" do
  it 'displays search' do
    mock(view).search { Search::Base.new }
    render

    expect(view).to render_template(partial: '_search_form', count: 1)
  end
end
