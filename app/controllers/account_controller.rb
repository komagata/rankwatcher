class AccountController < ApplicationController
  skip_before_filter :login_required, :only => [:signup, :login]

  # say something nice, you goof!  something sweet.
  def index
    redirect_to(:action => 'login') unless logged_in? || User.count > 0
  end

  def login
    redirect_to :controller => :sites if logged_in?
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => 'sites', :action => 'index')
    end
  end

  def signup
    @user = User.new(params[:user])
    return unless request.post?
    @user.save!
    self.current_user = @user
    redirect_back_or_default(:controller => 'sites', :action => 'index')
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end

  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    redirect_back_or_default(:controller => 'account', :action => 'login')
  end

  def edit
    @user = current_user
    return unless request.post?

    if current_user.update_attributes(params[:user])
      flash[:notice] = "アカウントを編集しました。"
      redirect_to :controller => "account", :action => "edit"
    end
  end
end
