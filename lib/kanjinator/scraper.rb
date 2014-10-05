require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.default_driver = :poltergeist
Capybara.run_server = false

module Kanjinator
  class Scraper
    include Capybara::DSL

    def initialize(url)
      @url = url
    end

    def get
      visit(@url)
      Nokogiri::HTML(page.html)
    end
  end
end

