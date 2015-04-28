class MainController < ApplicationController
  before_filter :authorize
  skip_before_filter :authorize, :only => :login
  skip_before_filter :authorize, :only => :loginattempt
  
  
  layout 'loginlayout', :only => :login
  def index
    
  end
  
  def login
    
    
  end
  
  def logout
    session[:current_user_id] = nil
    flash[:notice] = "Successfully Logged out"
    flash[:notify] = "Success"
    redirect_to '/main/login'
  end
  
  def loginattempt
    if user = User.authenticate(params['username'], params['password'])
      session[:current_user_id] = user.id
      session[:current_user_role] = user.role
      session[:current_username] = user.username
      redirect_to '/main/index'
    else
      flash[:notice] = "Incorrect username and or password"
      flash[:notify] = "Error"
      redirect_to '/main/login'
    end
  end
end
