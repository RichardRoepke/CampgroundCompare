# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
User.create!({ email: 'richard@missionmgmt.com',
               password: 'asdfasdf',
               password_confirmation: 'asdfasdf',
               admin: true})
User.create!({ email: 'admin@admin.org',
               password: 'asdfasdf',
               password_confirmation: 'asdfasdf',
               admin: true})
User.create!({ email: 'user@user.org',
               password: 'asdfasdf',
               password_confirmation: 'asdfasdf',
               admin: false})

10.times do |num|
  mail = (0...(3 + rand(12))).map { (65 + rand(26)).chr }.join
  User.create!({email: 'SEED_' + mail + '@jibberish.org',
                password: 'asdfasdf',
                password_confirmation: 'asdfasdf',
                admin: false})
end

MarkedPark.create!({ uuid: 'b9dd9a9d-8629-4591-a8fb-760a24e2a37e',
                     name: 'Rochester Place Resort',
                     status: 'TEST' })
