# frozen_string_literal: true

require_relative 'manufacturer'
require_relative 'instance_counter'

class Train
  include Manufacturer
  include InstanceCounter

  attr_reader :number, :type, :wagons, :speed, :route, :station
  ZERO_SPEED = 0
  @@trains = []

  def initialize(number)
    @number = number
    @wagons = []
    @speed = ZERO_SPEED

    @@trains.push(self)
    register_instance
  end

  def accelerate(speed)
    self.speed += speed if speed > ZERO_SPEED
  end

  def break
    self.speed = ZERO_SPEED
  end

  def add_wagon(wagon)
    wagons.push(wagon) if type == wagon.type && speed.zero?
  end

  def remove_wagon(wagon)
    wagons.delete(wagon) if speed.zero? && wagons.count > 0
  end

  def set_route(route)
    self.route = route
    route.stations.first.add_train(self)
    self.station = route.stations.first
  end

  def move_forward
    return if route.nil?
    return if station == route.stations.last

    station.delete_train(self)
    self.station = route.stations[route.stations.index(station).to_i + 1]
    station.add_train(self)
  end

  def move_backward
    return if route.nil?
    return if train.station == train.route.stations.first

    station.delete_train(self)
    self.station = route.stations[route.stations.index(station).to_i - 1]
    station.add_train(self)
  end

  def self.find(train_num)
    @@trains.detect { |train| train.number == train_num }
  end

  private

  # Вынесено в private т.к. осуществляется прямое присваивание
  # значений переменным экземпляра класса.

  attr_writer :speed, :route, :station
end
