class CreateEmos < ActiveRecord::Migration
  def change
    create_table :emos do |t|
      t.string :text
      t.string :emoji_unicode
      t.integer :freq

      t.timestamps null: false
    end

    create_table :features do |t|
      t.belongs_to :emo, index:true
      t.text :words
      t.text :hashtags

      t.timestamps null: false
    end
  end
end
