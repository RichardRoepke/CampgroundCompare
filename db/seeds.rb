# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
User.create!({email: 'richard@missionmgmt.com', password: 'asdfasdf', password_confirmation: 'asdfasdf', admin: true})
User.create!({email: 'admin@admin.org', password: 'asdfasdf', password_confirmation: 'asdfasdf', admin: true})
User.create!({email: 'user@user.org', password: 'asdfasdf', password_confirmation: 'asdfasdf', admin: false})

100.times do |num|
  mail = (0...(3 + rand(12))).map { (65 + rand(26)).chr }.join
  User.create!({email: 'SEED_' + mail + '@jibberish.org', password: 'asdfasdf', password_confirmation: 'asdfasdf', admin: false})
end

10.times do |num|
  MarkedPark.create!({uuid: num.to_s, name: 'PARK:' + num.to_s, status: 'FINE'})
end
