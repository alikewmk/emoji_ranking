class CreateEmos < ActiveRecord::Migration
  def change
    create_table :emos do |t|
      t.string :text
      t.string :unicode
      t.string :name
      t.string :short_name
      t.integer :freq

      t.timestamps null: false
    end

    create_table :features do |t|
      t.belongs_to :emo, index:true
      t.belongs_to :dict, index:true
      t.integer :label
      t.text :word
      t.integer :freq

      t.timestamps null: false
    end

    create_table :tweet_features do |t|
      t.belongs_to :tweet, index:true
      t.belongs_to :emo, index:true
      t.text :word_ids
      t.text :hashtag_ids

      t.timestamps null: false
    end
  end
end
