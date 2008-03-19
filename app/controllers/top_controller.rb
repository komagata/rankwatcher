class TopController < ApplicationController
  skip_before_filter :login_required

  def index
  end

  def trial
  end
end
