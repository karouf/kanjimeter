#!/usr/bin/env ruby

require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.default_driver = :poltergeist
Capybara.run_server = false

module GetPrice
  class WebScraper
    include Capybara::DSL

    def get_page_data(url)
      visit(url)
      doc = Nokogiri::HTML(page.html)
      doc.css('body')
    end
  end
end

scraper = GetPrice::WebScraper.new
links = scraper.get_page_data('http://www3.nhk.or.jp/news/easy/').css('a')
puts links.count
links.each do |link|
  puts "\"#{link.inner_text}\": #{link['href']}"
end
