require 'gruff'

class GraphController < ApplicationController

  def index
  end

  def index_count
    site = current_user.sites.find(params[:site_id])

    date, google, yahoo, baidu, msn = {}, [], [], [], []
    site.index_counts.each_with_index do |index_count, i|
      date[i] = index_count.date.strftime("%d")
      google << index_count.google
      yahoo << index_count.yahoo
      baidu << index_count.baidu
      msn << index_count.msn
    end

    g = graph("インデックス数")
    g.data("Google", google, "blue")
    g.data("Yahoo!", yahoo, "red")
    g.data("Baidu", baidu, "orange")
    g.data("MSN", msn, "green")
    g.labels = date

    send_data(g.to_blob, :type => 'image/png')
  end

  def rank
    site = current_user.sites.find(params[:site_id])
    search_word = site.search_words.find(params[:search_word_id])

    date, google, yahoo, baidu, msn = {}, [], [], [], []
    search_word.ranks.each_with_index do |rank, i|
      date[i] = rank.date.strftime("%d")
      google << (rank.google || 100)
      yahoo << (rank.yahoo || 100)
      baidu << (rank.baidu || 100)
      msn << (rank.msn || 100)
    end

    g = graph("「#{search_word.word}」での検索ランク")
    g.maximum_value = 100
    g.minimum_value = 1
    g.data("Google", google, "blue")
    g.data("Yahoo!", yahoo, "red")
    g.data("Baidu", baidu, "orange")
    g.data("MSN", msn, "green")
    g.labels = date

    send_data(g.to_blob, :type => 'image/png')
  end

  private
  def graph(title)
    g = Gruff::Line.new("750x400")
#    g.theme = {:background_colors => ["#FF0084", "#FF0084"]}
#    g.font_color = "#ffffff"
    g.theme_37signals
    g.font = FONT
    g.title = title
    g.title_font_size = 22
    g.marker_font_size = 14
    g.legend_font_size = 16
    g
  end
end
