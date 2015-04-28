class CreateFronts < ActiveRecord::Migration
  def change
    create_table :fronts do |t|
      t.string :firstname
      t.string :lastname
      t.string :phone1
      t.string :phone2
      t.string :phone3
      t.string :phone4
      t.string :email
      t.string :address
      t.string :city
      t.string :state
      t.string :zipcode
      t.datetime :maildate
      t.string :ppm
      t.string :fedex
      t.string :worker1
      t.string :worker2
      t.timestamps
    end
  end
end
