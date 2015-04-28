class ApplicationController < ActionController::Base
 # protect_from_forgery with: :exception
  
  
  def authorize
    if session[:current_user_id].nil?
      flash[:notice] = "Please log in before entering website"
      flash[:notify] = "error"
      redirect_to '/main/login'
    end
    @current_user = User.find_by_id(session[:current_user_id]) 
  end
  
  private
  def current_user
    @_current_user ||= session[:current_user_id] && User.find_by(id: session[:current_user_id])  
  end
  
end
