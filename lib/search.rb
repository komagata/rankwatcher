require 'rubygems'
require 'cgi'
require 'uri'
require 'kconv'
require 'open-uri'
require 'hpricot'
require 'net/http'

class String
  def to_readable
    CGI.unescapeHTML(self.toutf8)
  end

  def html2text
    self.gsub(/<.*?>/, "")
  end
end

module Search
  def self.all_index_count(url)
    threads = []
    threads << Thread.new { [:google, Google.index_count(url)] }
    threads << Thread.new { [:yahoo, Yahoo.index_count(url)] }
    threads << Thread.new { [:baidu, Baidu.index_count(url)] }
    threads << Thread.new { [:msn, MSN.index_count(url)] }

    results = {}
    threads.each do |t|
      key, value = t.value
      results[key] = value
    end
    results
  end

  def self.all_rank(url, word)
    threads = []
    threads << Thread.new { [:google, Google.rank(url, word)] }
    threads << Thread.new { [:yahoo, Yahoo.rank(url, word)] }
    threads << Thread.new { [:baidu, Baidu.rank(url, word)] }
    threads << Thread.new { [:msn, MSN.rank(url, word)] }

    results = {}
    threads.each do |t|
      key, value = t.value
      results[key] = value
    end
    results
  end

  class Google
    def self.search_url(word, count = 100)
      "http://www.google.co.jp/search?hl=ja" +
        "&num=#{count}&start=0&q=#{URI.escape(word)}"
    end

    def self.search(word, count = 100)
      url = search_url(word, count)
      results = []

      Hpricot(open(url)).search("div.g").each_with_index do |el, n|
        (el/"td.j span.a").remove
        (el/"td.j nobr").remove
        (el/"td.j a.fl").remove

        if el.at("h2.r a.l")
          results << {:order => n+1,
            :title => el.at("h2.r a.l").inner_html.to_readable.html2text,
            :url => el.at("h2.r a.l").attributes["href"],
            :description => el.at("td.j").inner_html.to_readable.html2text}
        else
          break
        end
      end
      results
    end

    def self.rank(url, word)
      url = URI(url).normalize.to_s
      res = self.search(word).find do |result|
        /^#{url}/ =~ result[:url] ? true : false
      end
      res ? res[:order] : nil
    end

    def self.index_count(url)
      f = open(search_url("site:#{url}", 1))
      Hpricot(f).search("/html/body/table[3]//td//b[2]").inner_html.gsub(",", "").to_i
    rescue
      0
    end
  end

  class Yahoo
    def self.search_url(word, count = 100)
      "http://search.yahoo.co.jp/search?ei=UTF-8" + 
        "&n=#{count}&p=#{URI.escape(word)}"
    end

    def self.search(word, count = 100)
      url = search_url(word, count)
      results = []
      Hpricot(open(url)).search("div#yschweb ol li").each_with_index do |el, n|
        if el.at("a.yschttl")
          results << {:order => n+1,
            :title => el.at("a.yschttl").inner_html.to_readable.html2text,
            :url => "http:"+el.at("a.yschttl").attributes["href"].split("*-http%3A")[-1],
            :description => el.at("div.yschabstr").inner_html.to_readable.html2text}
        else
          break
        end
      end
      results
    end

    def self.rank(url, word)
      url = URI(url).normalize.to_s
      res = self.search(word).find do |result|
        /^#{url}/ =~ result[:url] ? true : false
      end
      res ? res[:order] : nil
    end

    def self.index_count(url)
      html = open(search_url("site:#{url.gsub(/^http:\/\//, "")}", 1)) {|f| f.read }
      html.match(/<strong>([0-9,]+)<\/strong>/).to_a.values_at(1)[0].gsub(",", "").to_i
    rescue
      0
    end

  end

  class Baidu
    def self.search_url(word, count = 100)
      "http://www.baidu.jp/s?ie=utf-8&wd=#{URI.escape(word)}"
    end

    def self.search(word, count = 100)
      results = []
      Net::HTTP.start("www.baidu.jp", 80) do |w|
        res = w.get("/s?ie=utf-8&wd=#{URI.escape(word)}",
          "Cookie" => "BAIDUID=792E86FB1095123F787088F1B6BF34AA" +
            ":SL=0:NR=#{count}:NW=N:NEWS=Y:CONTNT=Y:HOTKEY=Y:HOTIMG=T" +
            ":HOTVDO=L:HOTBLG=Y")
        Hpricot(res.body).search("table.n tr td").each_with_index do |el, n|
          el.search("font[2]/span").remove
          el.search("font[2]/a").remove
          results << {:order => n+1,
            :title => el.at("font/a").inner_html.to_readable.html2text,
            :url => el.at("font/a").attributes["href"],
            :description => el.at("font[2]").inner_html.gsub(/^<br \/>/, "").gsub(/<br \/> <br \/>$/, "")}
        end
      end

      results
    end

    def self.rank(url, word)
      url = URI(url).normalize.to_s
      res = self.search(word).find do |result|
        /^#{url}/ =~ result[:url] ? true : false
      end
      res ? res[:order] : nil
    end

    def self.index_count(url)
      html = open(search_url("site:(#{URI(url).host})", 1)) {|f| f.read }
      Hpricot(html).at("h1/span").inner_html.match(/関連ウェブは約([0-9,]+)件/)[1].gsub(",", "").to_i
    rescue
      0
    end
  end

  class MSN
    def self.search_url(word, count = 100)
      "http://search.msn.co.jp/results.aspx?q=#{URI.escape(word)}"
    end

    def self.search(word, count = 100)
      results = []
      Net::HTTP.start("search.msn.co.jp", 80) do |w|
        res = w.get("/results.aspx?q=#{URI.escape(word)}",
          "Cookie" => "SRCHHPGUSR=NEWWND=1&ADLT=DEMOTE&" +
            "NRSLT=#{count}&NRSPH=2&LOC=LAT%3d35.68|LON%3d139.77" +
            "|DISP%3dtokyo%2c%20tokyo&SRCHLANG=")

        Hpricot(res.body).search("div#results > ul > li").each_with_index do |el, n|
          results << {:order => n+1,
            :title => el.at("h3 > a").inner_html.to_readable.html2text,
            :url   => el.at("h3 > a")["href"],
            :description => el.at("p") ? el.at("p").inner_html.to_readable.html2text : ""}
        end
      end

      results
    end

    def self.rank(url, word)
      url = URI(url).normalize.to_s
      res = self.search(word).find do |result|
        /^#{url}/ =~ result[:url] ? true : false
      end
      res ? res[:order] : nil
    end

    def self.index_count(url)
      html = open(search_url("site:#{url}", 1)) {|f| f.read }
      Hpricot(html).at("span#count").inner_html.match(/([0-9,]+) 件中/)[1].gsub(",", "").to_i
    rescue
      0
    end
  end
end
