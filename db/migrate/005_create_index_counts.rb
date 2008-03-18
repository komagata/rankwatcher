class CreateIndexCounts < ActiveRecord::Migration
  def self.up
    create_table :index_counts do |t|
      t.integer :site_id, :google, :yahoo, :baidu, :msn
      t.date :date

      t.timestamps
    end
  end

  def self.down
    drop_table :index_counts
  end
end
