class CreateRanks < ActiveRecord::Migration
  def self.up
    create_table :ranks do |t|
      t.integer :search_word_id, :google, :yahoo, :baidu, :msn
      t.date :date

      t.timestamps
    end
  end

  def self.down
    drop_table :ranks
  end
end
