# frozen_string_literal: true

require_relative 'manufacturer'
require_relative 'instance_counter'

class Train
  NUMBER_FORMAT = /(^[a-z0-9]{3}\-?[a-z0-9]{2}$)/i.freeze

  include Manufacturer
  include InstanceCounter

  attr_reader :number, :type, :wagons, :speed, :route, :station
  ZERO_SPEED = 0
  @all = {}

  def initialize(number, speed)
    @number = number
    @speed = speed
    validate!
    @wagons = []
    self.class.all[number] = self
    puts "self.class.all: #{self.class.all}"
    register_instance
  end

  class << self
    attr_accessor :all
  end

  def accelerate(speed)
    self.speed += speed if speed.positive?
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
    wagons.delete(wagon) if wagons.count.positive?
  end

  def bind_route(route)
    self.route = route
    route.stations.first.add_train(self)
    self.station = route.stations.first
  end

  def move_forward
    return if route.nil?
    return if station == route.stations.last

    move_train_forward(self)
  end

  def move_backward
    return if route.nil?
    return if station == route.stations.first

    move_train_backward(self)
  end

  def self.find(train_num)
    @all[train_num]
  end

  def wagons_in_train
    wagons.each { |wagon| yield(wagon) } if block_given?
  end

  def valid?
    validate!
    true
  rescue StandardError
    false
  end

  private

  attr_writer :speed, :route, :station

  def move_train_forward(train)
    station.delete_train(train)
    next_station_index = route.stations.index(station) + 1
    train.station = route.stations[next_station_index]
    station.add_train(train)
  end

  def move_train_backward(train)
    station.delete_train(train)
    prev_station_index = route.stations.index(station) - 1
    train.station = route.stations[prev_station_index]
    station.add_train(train)
  end

  def validate!
    if number !~ NUMBER_FORMAT
      raise StandardError, 'Некорректный формат номера поезда!'
    end
    raise StandardError, 'Скорость задана некорректно!' if speed.negative?
  end

  def validate_speed!
    if speed.positive?
      raise StandardError, 'Невозможно прицепить и отцепить вагон на скорости!'
    end
  end
end
