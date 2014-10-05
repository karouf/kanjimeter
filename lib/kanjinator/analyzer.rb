require_relative './scraper'

module Kanjinator
  module Analyzer
    def self.analyze(url)
      page = Page.new
      page.url = url
      content = Kanjinator::Scraper.new(url).get
      page.kanji = content.css('body').first.content.scan(/[一-龯]/).uniq.sort
      page.title = content.css('title').inner_text
      return page
    end
  end
end
