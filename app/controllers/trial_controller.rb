require 'search'

class TrialController < ApplicationController
  skip_before_filter :login_required

  def index
    return unless request.post?
    if params[:url] && params[:word]
      @index_counts = Search.all_index_count(params[:url])
      @index_counts[:google_url] =  Search::Google.search_url("site:"+params[:url], 1)
      @index_counts[:yahoo_url] = Search::Yahoo.search_url("site:"+params[:url].gsub(/^http:\/\//, ""), 1)
      @index_counts[:baidu_url] = Search::Baidu.search_url("site:("+params[:url]+")", 1)
      @index_counts[:msn_url] = Search::MSN.search_url("site:"+params[:url], 1)

      @ranks = params[:word].map do |word|
        rank = Search.all_rank(params[:url], word)
        rank[:word] = word
        rank[:google_url] = Search::Google.search_url(word)
        rank[:yahoo_url] = Search::Yahoo.search_url(word)
        rank[:baidu_url] = Search::Baidu.search_url(word)
        rank[:msn_url] = Search::MSN.search_url(word)
        rank
      end
    end
  end
end
