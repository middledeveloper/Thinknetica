# frozen_string_literal: true

require_relative 'route'
require_relative 'station'
require_relative 'train'

station1 = Station.new('Station #1')
station2 = Station.new('Station #2')
station3 = Station.new('Station #3')

route = Route.new(station1, station3)
puts route.stations.first.name
puts route.stations.last.name
route.add_station(station2)

puts route.stations
puts

train = Train.new('0100101', 'passenger', 17)
train.set_route(route)
train.add_wagon
train.accelerate(70)
puts "Train speed is #{train.speed}"

puts 'Stations train count:'
puts "Station1: #{station1.trains}"
puts "Station2: #{station2.trains}"
puts "Station3: #{station3.trains}"

train.move_forward
puts train.station

puts 'Stations train count:'
puts "Station1: #{station1.trains}"
puts "Station2: #{station2.trains}"
puts "Station3: #{station3.trains}"

train.move_backward
puts train.station

puts 'Stations train count:'
puts "Station1: #{station1.trains}"
puts "Station2: #{station2.trains}"
puts "Station3: #{station3.trains}"

train.break
puts "Train speed is #{train.speed}"
