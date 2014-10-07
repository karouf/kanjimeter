module Kanjinator
  module Matcher
    def self.match(kanji, pages)
      raise ArgumentError if kanji.nil?
      return [] if pages.empty? || pages.nil?

      rated = []
      pages.each do |page|
        common = kanji & page.kanji
        rating = common.count / page.kanji.count.to_f
        rated << RatedPage.new(page, rating)
      end
      rated
    end

    class RatedPage
      attr_reader :rating

      def initialize(page, rating)
        @url = page.url
        @title = page.title
        @rating = rating
      end
    end
  end
end
