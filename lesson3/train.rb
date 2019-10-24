# frozen_string_literal: true

require_relative 'route'
require_relative 'station'

$train_type_repo = %w[cargo passenger]

class Train
  attr_reader :number, :type
  attr_accessor :wagon_count, :speed, :route, :station

  def initialize(number, type, wagon_count)
    @number = number
    @type = type
    @wagon_count = wagon_count
    @speed = 0
  end

  def accelerate(speed)
    self.speed += speed if speed > 0
  end

  def current_speed
    speed
  end

  def break
    speed = 0
  end

  def current_wagons
    wagon_count
  end

  def add_wagon
    wagon_count += 1 if speed == 0
  end

  def remove_wagon
    wagon_count -= 1 if speed == 0
  end

  def set_route(route)
    @route = route
    @station = route.stations.first
    station.add_train(self)
  end

  def move_forward
    unless route.nil?
      if station != route.stations.last
        station.delete_train(self)
        current_station_index = route.stations.index(station)
        self.station = route.stations[current_station_index += 1]
        station.add_train(self)
      end
    end
  end

  def move_backward
    current_station_index = route.stations.index(station)
    unless route.nil?
      if station != route.stations.first
        station.delete_train(self)
        self.station = route.stations[current_station_index -= 1]
        station.add_train(self)
      end
    end
  end
end
