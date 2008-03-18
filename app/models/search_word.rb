class SearchWord < ActiveRecord::Base
  belongs_to :site
  has_many :ranks
end
