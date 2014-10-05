class User < ActiveRecord::Base
  def kanji=(array)
    write_attribute(:kanji, array.join)
  end

  def kanji
    read_attribute(:kanji).split('')
  end
end
