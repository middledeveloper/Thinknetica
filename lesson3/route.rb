require_relative 'station'

class Route
  attr_accessor :stations

  def initialize(first_station, last_station)
    @stations = [first_station, last_station]
  end

  def add_station(station)
    self.stations.insert(-2, station)
  end

  def delete_station(station)
      self.stations.delete(station) if
        station != self.stations.first && station != self.stations.last
  end

  def list_stations()
    puts self.stations.each
  end
end
