require 'search'

class Crawler
  def crawl(site_id)
    time = Time.new.strftime("%Y-%m-%d")

    return if Site.find_by_id_and_last_updated_on(site_id, time)

    site = Site.find(site_id)
    index_count = Search.all_index_count(site.url)
    index_count[:site_id] = site.id
    index_count[:date] = time

    search_words = []
    Site.transaction do
      IndexCount.create(index_count)

      site.search_words.each do |search_word|
        rank = Search.all_rank(site.url, search_word.word)
        rank[:search_word_id] = search_word.id
        rank[:date] = time
        Rank.create(rank)

        search_words << {:word => search_word.word, :rank => rank}
      end

      site.last_updated_on = time
      site.save
    end

    {:site => site,
     :url => site.url,
     :index_count => index_count,
     :search_words => search_words}
  end

  def crawl_all
    time = Time.new.strftime("%Y-%m-%d")

    User.find(:all).each do |user|
      sites = []
      user.sites.each do |site|
        sites << self.crawl(site.id)
      end

      report = {:user => user,
        :login => user.login,
        :sites => sites,
        :date => time}
      ReportMailer.deliver_report(user.email, report) if user.report
    end
  end
end
