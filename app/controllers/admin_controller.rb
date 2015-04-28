class AdminController < ApplicationController
  before_filter :authorize
  def index
     if session[:current_user_role] != "admin"
     redirect_to '/main/index'
    end
  end
  
  def clearfronts
    if session[:current_user_role] != "admin"
      render text: "DENIED"
    end
    
    sql = "DELETE FROM fronts"
    results = ActiveRecord::Base.connection.execute(sql)
    render text: "success"
  end
  
  def clearnocalls
    if session[:current_user_role] != "admin"
      render text: "DENIED"
    end
    
    sql = "DELETE FROM nocalls"
    results = ActiveRecord::Base.connection.execute(sql)
    render text: "success"
  end
  
end
