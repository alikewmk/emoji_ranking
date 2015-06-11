# One need manually change the table storage format in mysql!
# ALTER TABLE tweets CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
# same thing with emo table, since it needs store 2 byte emoji too.

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
