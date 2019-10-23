require_relative 'route'
require_relative 'station'

class Train
  attr_accessor :number
  attr_accessor :type
  attr_accessor :wagon_count
  attr_accessor :speed
  attr_accessor :route
  attr_accessor :station

  attr_reader :type_repo

  def initialize(number, type, wagon_count)
    @type_repo = ['грузовой', 'пассажирский']
    if type_repo.include?(type) == false
      puts 'Некорректный тип!'
      return
    end
    @number = number
    @type = type
    @wagon_count = wagon_count

    @speed = 0
  end

  def accelerate(speed)
    self.speed += speed
  end

  def current_speed()
    self.speed
  end

  def break()
    self.speed = 0
  end

  def current_wagons()
    self.wagon_count
  end

  def change_wagon_count(operation)
    if self.speed == 0
      if operation.downcase == 'прицепить'
        self.wagon_count += 1
      elsif operation.downcase == 'отцепить'
        self.wagon_count -= 1 if self.wagon_count >= 1
      end
    end
  end

  def set_route(route)
    self.route = route
    self.station = route.stations.first
    self.station.add_train(self)
  end

  def move_station(direction)
   if self.route != nil
     if direction.downcase == 'вперед'
       if self.station != self.route.stations.last
         self.station.delete_train(self)
         self.station = self.route.stations[self.route.stations.index(self.station) + 1]
         self.station.add_train(self)
       end
     elsif direction.downcase == 'назад'
       if self.station != self.route.stations.first
         self.station.delete_train(self)
         self.station = self.route.stations[self.route.stations.index(self.station) - 1]
         self.station.add_train(self)
       end
     end
   end
 end

 def print_station(which_station)
   current_station_index = self.route.stations.index(self.station)
   if which_station.downcase == 'предыдущая'
     if self.station == self.route.stations.first
        puts 'Это начальная'
      else
        puts self.route.stations[current_station_index - 1].name
      end
   elsif which_station.downcase == 'текущая'
     puts self.station.name
   elsif which_station.downcase == 'следующая'
     if self.station == self.route.stations.last
        puts 'Это конечная'
      else
        puts self.route.stations[current_station_index + 1].name
      end
   end
 end

end
