# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  init_gettext 'rank'
  include AuthenticatedSystem
  include ApplicationHelper

  helper :all # include all helpers, all the time
  before_filter :login_required
  before_filter :sidebar

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => '5b1d6f9c37898796fa9f23d0d1149a29'

  def sidebar
    @sidebar = render_to_string :partial => "sidebar"
  rescue
  end
end
