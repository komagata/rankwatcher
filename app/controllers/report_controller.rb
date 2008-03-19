class ReportController < ApplicationController

  def index
    @site = params[:site_id] ? current_user.sites.find(params[:site_id]) : current_user.sites.first
  end
end
