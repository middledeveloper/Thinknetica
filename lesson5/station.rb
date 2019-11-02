# frozen_string_literal: true

require_relative 'train'
require_relative 'route'
require_relative 'instance_counter'

class Station
  include InstanceCounter

  @@station_repo = []
  attr_reader :name, :trains

  def initialize(name)
    @name = name
    @trains = []

    @@station_repo.push(self)
    register_instance
  end

  def add_train(train)
    trains.push(train)
  end

  def delete_train(train)
    trains.delete(train)
  end

  def self.all
    @@station_repo
  end
end
