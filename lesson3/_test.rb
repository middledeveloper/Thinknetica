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
puts route1.stations.count

train = Train.new('0100101', 'пассажирский', 17)
train.set_route(route1)

#puts train.station.name
#train.move_station('Вперед')
#puts train.station.name

train.print_station('предыдущая')
train.print_station('текущая')
train.print_station('следующая')
