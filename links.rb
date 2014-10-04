#!/usr/bin/env ruby

require 'nokogiri'
require 'pp'

file = File.open('index.html', 'r')
doc = Nokogiri::XML(file)

links = doc.css('a')
puts "There's #{links.count} links"
links.each do |link|
  puts "\"#{link.inner_text}\": #{link['href']}"
end
