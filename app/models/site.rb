class Site < ActiveRecord::Base
  belongs_to :user
  has_many :search_words
  has_many :index_counts
end
