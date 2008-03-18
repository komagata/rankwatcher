class SitesController < ApplicationController
  # GET /sites
  # GET /sites.xml
  def index
    @sites = Site.paginate(:page => params[:page], :per_page => 10,
      :conditions => ["user_id = ?", current_user.id])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sites }
    end
  end
=begin
  # GET /sites/1
  # GET /sites/1.xml
  def show
    @site = Site.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site }
    end
  end
=end
  # GET /sites/new
  # GET /sites/new.xml
  def new
    @site = Site.new(:user_id => current_user.id)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @site }
    end
  end

  # GET /sites/1/edit
  def edit
    @site = current_user.sites.find(params[:id])
    @word = []
    @site.search_words.each do |search_word|
      @word << {:id => search_word.id, :value => search_word.word}
    end
  end

  # POST /sites
  # POST /sites.xml
  def create
    @site = Site.new(params[:site])
    @site.user_id = current_user.id
    10.times do |i|
      unless params["word_#{i}"].empty?
        @site.search_words << SearchWord.create(:word => params["word_#{i}"])
      end
    end

    respond_to do |format|
      if @site.save
        flash[:notice] = 'URL・検索キーワードを登録しました。'
        format.html { redirect_to :controller => "sites" }
        format.xml  { render :xml => @site, :status => :created, :location => @site }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sites/1
  # PUT /sites/1.xml
  def update
    @site = Site.find(params[:id])
    @site.user_id = current_user.id
    10.times do |i|
      if params["word_#{i}"].empty?
        if @site.search_words[i]
          @site.search_words[i].destroy
        end
      else
        if @site.search_words[i]
          @site.search_words[i].word = params["word_#{i}"]
          @site.search_words[i].save
        else
          @site.search_words << SearchWord.create(:word => params["word_#{i}"])
        end
      end
    end

    respond_to do |format|
      if @site.update_attributes(params[:site])
        flash[:notice] = 'URL・検索キーワードを編集しました。'
        format.html { redirect_to :controller => "sites" }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.xml
  def destroy
    @site = current_user.sites.find(params[:id])
    @site.destroy

    flash[:notice] = 'URL・検索キーワードを削除しました。'
    respond_to do |format|
      format.html { redirect_to(sites_url) }
      format.xml  { head :ok }
    end
  end
end
