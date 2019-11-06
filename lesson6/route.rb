# frozen_string_literal: true

require_relative 'station'
require_relative 'instance_counter'

class Route
  include InstanceCounter

  attr_reader :stations

  def initialize(first_station, last_station)
    @stations = [first_station, last_station]
    valid?
    register_instance
  end

  def add_station(station)
    stations.insert(-2, station)
  end

  def delete_station(station)
    stations.delete(station) if
      station_instance != stations.first &&
      station_instance != stations.last
  end

  def valid?
    validate!
    true
  end

  private

  def validate!
    if stations.first == stations.last
      raise StandardError, 'Необходимо указать разные станции!'
    end
  end
end
