# frozen_string_literal: true

require_relative 'route'
require_relative 'station'
require_relative 'train'

station1 = Station.new('Station #1')
station2 = Station.new('Station #2')
station3 = Station.new('Station #3')
station4 = Station.new('Station #4')
station5 = Station.new('Station #5')

route1 = Route.new(station1, station5)
puts route1.stations.first.name
puts route1.stations.last.name
route1.add_station(station4)

puts route1.station_repo
puts

train1 = Train.new('0100101', 'passenger', 17)
train1.set_route(route1)

train1.move_forward
puts train1.station

train1.move_backward
puts train1.station
