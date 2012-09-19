require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    window_size: [1920, 1080],
    debug: ENV['debug'],
    phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes', '--local-to-remote-url-access=no'],
    timeout: 90
  )
end

Capybara.javascript_driver = :poltergeist

