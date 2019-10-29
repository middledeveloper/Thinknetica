# frozen_string_literal: true

require_relative 'station'

class Route
  attr_reader :stations

  def initialize(first_station, last_station)
    @stations = [first_station, last_station]
  end

  def add_station(station)
    stations.insert(-2, station)
  end

  def delete_station(station)
    stations.delete(station) if
      station_instance != stations.first &&
      station_instance != stations.last
  end
end
