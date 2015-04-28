class Front < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :firstname, :lastname, :phone1, :phone2, :phone3, :phone4, :email, :address, :city, :state, :zipcode, :maildate, :ppm, :fedex, :worker1, :worker2

end
