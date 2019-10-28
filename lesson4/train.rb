# frozen_string_literal: true

require_relative 'route'
require_relative 'station'

# $train_type_repo = %w[cargo passenger]

class Train
  attr_reader :number, :type, :wagon_count
  attr_accessor :speed, :route, :station

  def initialize(number, type, wagon_count)
    @number = number
    @type = type
    @wagon_count = wagon_count
    @speed = 0
  end

  def accelerate(speed)
    self.speed += speed if speed > 0
  end

  def break
    self.speed = 0
  end

  def add_wagon
    self.wagon_count += 1 unless speed.zero?
  end

  def remove_wagon
    self.wagon_count -= 1 if !speed.zero? && wagon_count > 0
  end

  def set_route(route)
    self.route = route
    route.stations.first.add_train(self)
    self.station = route.stations.first
  end

  def move_forward
    return if route.nil?
    return if station != route.stations.last

    station.delete_train(self)
    self.station = route.stations[route.stations.index(station).to_i + 1]
    station.add_train(self)
  end

  def move_backward
    return if route.nil?
    return if station != route.stations.first

    station.delete_train(self)
    self.station = route.stations[route.stations.index(station).to_i - 1]
    station.add_train(self)
  end
end
