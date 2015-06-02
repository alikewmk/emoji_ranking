class CreateDicts < ActiveRecord::Migration
  def change
    create_table :dicts do |t|
      t.string :word
      t.integer :freq

      t.timestamps null: false
    end
  end
end
