class WorkersController < ApplicationController
  before_filter :authorize#, :only => :index
  def index
    @workers = Worker.order(:name).all
  end
  
  def addWorker
    result = "Error: Did not add worker because invalid parameters"
    if params.has_key?('name')
      worker = Worker.new
      worker.name = params['name']
      worker.save
      result = "Added #{params['name']}"
    end
    render text: result
  end
  
  def removeWorker
    result = "Error: Did not remove worker because invalid parameters"
    if params.has_key?('id')
      Worker.destroy(params['id'])
      result = "Removed Worker"
    end
    render text: result
  end
  
  def getWorkers
    @workers = Worker.order(:name).all
    render json: @workers 
  end
end
