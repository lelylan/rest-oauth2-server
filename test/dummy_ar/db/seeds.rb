# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

OAuth2::Provider.client_class.create! :name => 'Example Client', :oauth_identifier => 'abcdefgh12345678', :oauth_secret => 'secret'

ActiveRecord::Base.connection.execute("copy users from '#{Rails.root.join('db','user_seed.txt')}'")
