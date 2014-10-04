require_relative './scraper'

module Kanjinator
  class Analyzer
    def initialize(url)
      @url = url
      @content = Kanjinator::Scraper.new(@url).get
    end

    def kanji
      @content.first.content.scan(/[一-龯]/).uniq.sort
    end
  end
end
