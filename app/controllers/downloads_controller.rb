class DownloadsController < ApplicationController
  before_filter :authorize
  
  def file
    @filename = params['name']
    send_file Rails.root.to_s + "/private/generated/#{@filename}", :type=>"application/excel"
    
  end
  
end
