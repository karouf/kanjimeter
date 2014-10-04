class AddKanjiToPages < ActiveRecord::Migration
  def change
    add_column :pages, :kanji, :string
  end
end
