#!/usr/bin/env ruby

require 'nokogiri'
require 'httparty'
require 'json'
require 'pp'

WANIKANI_API_KEY = ARGV[0]
WANIKANI_URL = "https://www.wanikani.com/api/user/#{WANIKANI_API_KEY}/kanji"

file = File.open('article.html', 'r')
doc = Nokogiri::XML(file)
content = doc.css('body')
if content.css('rt')
  puts "There's some furigana"
else
  puts "No furigana"
end
content.css('rt').each do |node|
  node.remove
end
kanji = content.first.content.scan(/[一-龯]/).uniq
file.close
puts "There's #{kanji.count} different kanji in this text"
pp kanji.join('')

if File.exist? 'wanikani.json'
  data = File.read('wanikani.json')
else
  data = HTTParty.get(WANIKANI_URL).body
end
json = JSON.parse(data)

known = []
json['requested_information'].each do |item|
  if item['user_specific'] && %w(guru master enlightened burned).include?(item['user_specific']['srs'])
    known << item['character']
  end
end
puts "You know #{known.count} different kanji"
pp known.join('')
common = kanji & known
puts "You can read #{common.count} kanji in this text"
puts "Roughly #{'%d' % (common.count / kanji.count.to_f * 100)}%"
