# frozen_string_literal: true

require_relative 'station'
require_relative 'instance_counter'
require_relative 'accessors'

class Route
  include Accessors
  include InstanceCounter

  attr_reader :stations

  def initialize(first_station, last_station)
    @stations = [first_station, last_station]
    validate!
    register_instance
  end

  def add_station(station)
    stations.insert(-2, station)
  end

  def delete_station(station)
    if station_instance != stations.first && station_instance != stations.last
      stations.delete(station)
    end
  end

  def valid?
    validate!
    true
  rescue StandardError
    false
  end

  private

  def validate!
    if stations.first == stations.last
      raise StandardError, 'Необходимо указать разные станции!'
    end
  end
end
