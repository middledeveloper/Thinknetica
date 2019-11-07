# frozen_string_literal: true

require_relative 'manufacturer'
require_relative 'instance_counter'

class Train
  NUMBER_FORMAT = /(^[a-z0-9]{3}\-?[a-z0-9]{2}$)/i.freeze

  include Manufacturer
  include InstanceCounter

  attr_reader :number, :type, :wagons, :speed, :route, :station
  ZERO_SPEED = 0
  @@all = {}

  def initialize(number, speed)
    @number = number
    @speed = speed
    validate!
    @wagons = []
    @@all[number] = self
    register_instance
  end

  def accelerate(speed)
    self.speed += speed if speed > ZERO_SPEED
  end

  def break
    self.speed = ZERO_SPEED
  end

  def add_wagon(wagon)
    validate_speed!
    wagons.push(wagon) if type == wagon.type
  end

  def remove_wagon(wagon)
    validate_speed!
    wagons.delete(wagon) if wagons.count > 0
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
    @@all[train_num]
  end

  def valid?
    validate!
    true
  rescue StandardError
    false
  end

  private

  attr_writer :speed, :route, :station

  def validate!
    if number !~ NUMBER_FORMAT
      raise StandardError, 'Некорректный формат номера поезда!'
    end
    raise StandardError, 'Скорость задана некорректно!' if speed < 0
  end

  def validate_speed!
    if speed > 0
      raise StandardError, 'Невозможно прицепить и отцепить вагон на скорости!'
    end
  end
end
