#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/boot'

BikeShop.connection.create_table "bike_shops", :force => true do |t|
  t.column "name", :string
  t.column "phone", :string
end

BikeShop.create(:name => 'The Bike Nook', :phone => '(415) 221-4774')
BikeShop.create(:name => 'Sellwood Cycle Repair', :phone => '(503) 232-1212')

