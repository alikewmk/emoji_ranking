class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :text
      t.string :emoji_unicode
      t.string :source
      t.datetime :create_time

      t.timestamps null: false
    end
    add_index :tweets, :create_time
  end
end
