class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.integer :user_id
      t.text :url
      t.date :last_updated_on

      t.timestamps
    end
  end

  def self.down
    drop_table :sites
  end
end
