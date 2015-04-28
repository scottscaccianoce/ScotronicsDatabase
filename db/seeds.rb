# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.new
user.username= "admin"
user.password_hash = "1goodpw!"
user.role = "admin"
user.save

o = User.new
o.username = "office"
o.password_hash = "office123"
o.role = "office"
o.save