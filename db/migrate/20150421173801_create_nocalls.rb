class CreateNocalls < ActiveRecord::Migration
  def change
    create_table :nocalls do |t|
      t.string :firstname
      t.string :lastname
      t.string :phone
      t.timestamps
    end
  end
end
