module Kanjinator
  module Matcher
    def self.match(user, pages)
      raise ArgumentError if user.nil?
      return {} if pages.empty? || pages.nil?

      rated = {}
      pages.each do |page|
        common = user.kanji & page.kanji
        rating = common.count / page.kanji.count.to_f
        rated[page] = rating
      end
      rated
    end
  end
end
