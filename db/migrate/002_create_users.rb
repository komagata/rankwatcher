class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :login,                     :string
      t.column :email,                     :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :payment,                   :boolean, :default => false
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
    end

    User.create(:login => 'admin', :email => 'komagata@gmail.com', :crypted_password => '388e46f5d7520d32044847e91fdeb28685e566bd', :salt => '11518f4881137561ef4e33cf1c0c8b3329f4cc0f')
    User.create(:login => 'komagata', :email => 'masaki@komagata.org', :crypted_password => '83c42f4ba6656e59d0d7ce52c64543c46e63315c', :salt => '70aa93bdc801b4becf47fdf01cce563255b363ff')
  end

  def self.down
    drop_table "users"
  end
end
