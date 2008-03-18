require 'gruff'

class GraphController < ApplicationController

  def index
  end

  def index_count
    site = current_user.sites.first
    date = {}
    google, yahoo, baidu, msn = [], [], [], [] 
    
    site.index_counts.each_with_index do |index_count, i|
      date[i] = index_count.date.strftime("%m-%d")
      google << index_count.google
      yahoo << index_count.yahoo
      baidu << index_count.baidu
      msn << index_count.msn
    end

    g = Gruff::Line.new(500)
    #g.theme_odeo
    g.font = FONT
    g.title = "インデックス数"

    g.data("Google", google)
    g.data("Yahoo!", yahoo)
    g.data("Baidu", baidu)
    g.data("MSN", msn)

    g.labels = date

    send_data(g.to_blob, :type => 'image/png')
  end

  def rank
  end
end
